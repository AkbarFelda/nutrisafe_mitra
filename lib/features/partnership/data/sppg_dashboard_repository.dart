import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/error/app_failure.dart';
import '../../schools/domain/school.dart';
import '../../allergy_monitoring/domain/allergy_monitoring.dart';
import '../../food_report/domain/food_report.dart';
import '../../food_issues/domain/food_issue.dart';

class SppgStatus {
  const SppgStatus({
    required this.status,
    required this.name,
    required this.address,
    required this.capacity,
    required this.schoolCount,
  });

  final String status;
  final String name;
  final String address;
  final int capacity;
  final int schoolCount;

  factory SppgStatus.fromJson(Map<String, dynamic> json) {
    final list = json['sppg_list'];
    final detail = list is List && list.isNotEmpty && list.first is Map
        ? Map<String, dynamic>.from(list.first as Map)
        : json;
    return SppgStatus(
      status:
          '${detail['status'] ?? (json['is_partner'] == true ? 'active' : 'pending')}',
      name: '${detail['name'] ?? detail['sppg_name'] ?? 'SPPG'}',
      address: '${detail['address'] ?? detail['lokasi'] ?? ''}',
      capacity: _integer(detail['production_capacity'] ?? detail['capacity']),
      schoolCount: _integer(
        json['school_count'] ?? detail['school_count'] ?? json['total_schools'],
      ),
    );
  }
}

class DetectedIngredient {
  const DetectedIngredient({required this.name, required this.isAllergen});
  final String name;
  final bool isAllergen;
}

class ScanResult {
  const ScanResult({required this.payload});
  final Map<String, dynamic> payload;

  factory ScanResult.fromResponse(Object? body) {
    Object? value = body;
    if (value is String) {
      try {
        value = jsonDecode(value);
      } on FormatException {
        value = null;
      }
    }
    while (value is Map) {
      final nested = value['data'] ?? value['result'];
      if (nested is! Map) break;
      value = nested;
    }
    return ScanResult(
      payload: value is Map
          ? Map<String, dynamic>.from(value)
          : const <String, dynamic>{},
    );
  }

  List<DetectedIngredient> get ingredients {
    final value = payload['bahan_terdeteksi'] ?? payload['ingredients'];
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) {
          return DetectedIngredient(
            name: '${item['name'] ?? item['nama'] ?? ''}',
            isAllergen: item['is_allergen'] == true,
          );
        })
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  List<String> get allergyWarnings {
    final value = payload['peringatan_alergi'] ?? payload['allergens'];
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is Map) {
            return '${item['name'] ?? item['allergen'] ?? item['message'] ?? ''}';
          }
          return '$item';
        })
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String get nutritionStatus => '${payload['status_gizi'] ?? ''}';
  bool get geminiFailed => payload['gemini_failed'] == true;
  int get totalPortions =>
      _integer(payload['total_porsi'] ?? payload['total_portions']);
  num? get caloriesPerPortion =>
      number(const ['kalori_per_porsi', 'calories_per_portion']);
  String get photoRef => '${payload['photo_ref'] ?? payload['photo_path'] ?? ''}';

  num? nutrientPerPortion(String key) {
    if (key == 'kalori' && caloriesPerPortion != null) {
      return caloriesPerPortion;
    }
    final detail = payload['menu_detail'];
    if (detail is! Map) return null;
    final total = totalPortions;
    final value = detail[key];
    final parsed = value is num ? value : num.tryParse('$value');
    if (parsed == null) return null;
    return total > 0 ? parsed / total : parsed;
  }

  num? nutrientTotal(String key) {
    final detail = payload['menu_detail'];
    if (detail is! Map) return null;
    final value = detail[key];
    return value is num ? value : num.tryParse('$value');
  }

  num? number(List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value.replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  List<String> strings(List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is List) return value.map((item) => '$item').toList();
    }
    return const [];
  }
}

class TodayMenuReport {
  const TodayMenuReport({required this.submitted, this.data});
  final bool submitted;
  final Map<String, dynamic>? data;
}

class MenuRecommendation {
  const MenuRecommendation({
    required this.active,
    required this.items,
    this.message = '',
  });
  final bool active;
  final List<Map<String, dynamic>> items;
  final String message;
}

class SchoolDirectory {
  const SchoolDirectory({required this.available, required this.assigned});
  final List<School> available;
  final List<School> assigned;
}

class SppgDashboardRepository {
  const SppgDashboardRepository(this._dio);
  final Dio _dio;

  Future<SppgStatus> getStatus() async {
    try {
      final response = await _dio.get<Object?>('/sppg/status');
      return SppgStatus.fromJson(_object(response.data));
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<List<School>> getAvailableSchools() async {
    return _getSchools('/sppg/available-schools');
  }

  Future<List<School>> getAssignedSchools() async {
    return _getSchools('/sppg/schools');
  }

  Future<SchoolDirectory> getSchoolDirectory() async {
    final results = await Future.wait([
      getAvailableSchools(),
      getAssignedSchools(),
    ]);
    return SchoolDirectory(available: results[0], assigned: results[1]);
  }

  Future<List<School>> _getSchools(String path) async {
    try {
      final response = await _dio.get<Object?>(path);
      final items = _list(response.data);
      return items
          .map((item) {
            final json = Map<String, dynamic>.from(item as Map);
            final level =
                '${json['Grade'] ?? json['grade'] ?? json['level'] ?? json['jenjang'] ?? ''}'
                    .toLowerCase();
            final allergyTypes = json['allergy_types'];
            return School(
              id: _integer(json['id'] ?? json['school_id']),
              name: '${json['name'] ?? json['school_name'] ?? ''}',
              address: '${json['address'] ?? json['lokasi'] ?? ''}',
              level: level.contains('smp') || level.contains('junior')
                  ? SchoolLevel.juniorHigh
                  : SchoolLevel.elementary,
              students: _integer(json['students'] ?? json['student_count']),
              teachers: _integer(json['teachers'] ?? json['teacher_count']),
              allergyTypes: allergyTypes is List
                  ? allergyTypes
                        .map((value) => '$value')
                        .toList(growable: false)
                  : const [],
            );
          })
          .toList(growable: false);
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<void> assignSchools(List<int> schoolIds) async {
    if (schoolIds.isEmpty) {
      throw const AppFailure(
        FailureKind.unexpected,
        messageOverride: 'Pilih minimal satu sekolah.',
      );
    }
    try {
      await _dio.post<Object?>(
        '/sppg/assign-schools',
        data: {'school_ids': schoolIds},
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<AllergyMonitoringData> getAllergyDashboard() async {
    try {
      final response = await _dio.get<Object?>('/sppg/allergy-dashboard');
      final body = response.data;
      final items = body is Map && body['data'] is Map
          ? (body['data'] as Map)['schools']
          : body is Map
          ? body['schools'] ?? body['data']
          : body;
      if (items is! List) {
        throw const AppFailure(FailureKind.unexpected);
      }
      final breakdown = <StudentAllergy, int>{};
      if (body is Map && body['data'] is Map) {
        final rawBreakdown = (body['data'] as Map)['allergy_breakdown'];
        if (rawBreakdown is List) {
          for (final item in rawBreakdown.whereType<Map>()) {
            final name = '${item['allergy_type'] ?? item['name'] ?? ''}'
                .toLowerCase();
            final type = name.contains('kacang') || name.contains('peanut')
                ? StudentAllergy.peanut
                : name.contains('telur') || name.contains('egg')
                ? StudentAllergy.egg
                : name.contains('susu') || name.contains('milk')
                ? StudentAllergy.milk
                : null;
            if (type != null) breakdown[type] = _integer(item['count']);
          }
        }
      }
      return AllergyMonitoringData(
        items
            .whereType<Map>()
            .map((item) {
              final json = Map<String, dynamic>.from(item);
              final allergies = json['allergies'] is Map
                  ? Map<String, dynamic>.from(json['allergies'] as Map)
                  : const <String, dynamic>{};
              int count(List<String> keys) {
                for (final key in keys) {
                  final value = allergies[key] ?? json[key];
                  if (value != null) return _integer(value);
                }
                return 0;
              }

              final documentedCount = _integer(json['allergy_count']);
              final studentAllergies = <Set<StudentAllergy>>[
                for (
                  var i = 0;
                  i < count(['peanut', 'kacang', 'peanut_count']);
                  i++
                )
                  {StudentAllergy.peanut},
                for (var i = 0; i < count(['egg', 'telur', 'egg_count']); i++)
                  {StudentAllergy.egg},
                for (var i = 0; i < count(['milk', 'susu', 'milk_count']); i++)
                  {StudentAllergy.milk},
                if (allergies.isEmpty)
                  for (var i = 0; i < documentedCount; i++)
                    {StudentAllergy.peanut},
              ];
              return SchoolAllergyData(
                name: '${json['name'] ?? json['school_name'] ?? ''}',
                students: _integer(
                  json['total_students'] ??
                      json['students'] ??
                      json['student_count'],
                ),
                studentAllergies: studentAllergies,
              );
            })
            .toList(growable: false),
        breakdown: breakdown,
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<ScanResult> scanFood({
    required Uint8List imageBytes,
    int totalPortions = 1,
    String? menuName,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/sppg/scan',
        data: FormData.fromMap({
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: 'menu.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
          'total_portions': totalPortions,
          if (menuName?.trim().isNotEmpty == true) 'menu_name': menuName!.trim(),
        }),
      );
      if (kDebugMode) {
        debugPrint('[SPPG SCAN] HTTP ${response.statusCode}');
        debugPrint('[SPPG SCAN] Raw response: ${_debugJson(response.data)}');
      }
      final result = ScanResult.fromResponse(response.data);
      if (kDebugMode) {
        debugPrint('[SPPG SCAN] Parsed payload: ${_debugJson(result.payload)}');
        debugPrint(
          '[SPPG SCAN] Bahan (${result.ingredients.length}): '
          '${result.ingredients.map((item) => item.name).join(', ')}',
        );
      }
      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SPPG SCAN] Error: $error');
        if (error is DioException) {
          debugPrint(
            '[SPPG SCAN] Error response: '
            '${_debugJson(error.response?.data)}',
          );
        }
        debugPrintStack(stackTrace: stackTrace);
      }
      throw _failure(error);
    }
  }

  Future<void> submitMenuReport({
    required String menuName,
    required num calories,
    required num caloriesPerPortion,
    required num protein,
    required num carbohydrates,
    required num fat,
    required int totalPortions,
    required String nutritionStatus,
    String photoRef = '',
    List<DetectedIngredient> ingredients = const [],
    bool usedRecommendation = false,
    List<Map<String, dynamic>> recommendations = const [],
  }) async {
    try {
      await _dio.post<Object?>(
        '/sppg/menu-reports',
        data: {
          'menu_name': menuName,
          'kalori': calories,
          'protein': protein,
          'karbohidrat': carbohydrates,
          'lemak': fat,
          'total_porsi': totalPortions,
          'kalori_per_porsi': caloriesPerPortion,
          'status_gizi': nutritionStatus,
          'photo_ref': photoRef,
          'ingredients': [for (final item in ingredients) {'name': item.name}],
          'used_recommendation': usedRecommendation,
          'recommendations': recommendations,
        },
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<TodayMenuReport> getTodayMenuReport() async {
    try {
      final response = await _dio.get<Object?>('/sppg/menu-reports/today');
      final body = response.data;
      if (body is! Map) throw const AppFailure(FailureKind.unexpected);
      final data = body['data'];
      return TodayMenuReport(
        submitted: body['submitted'] == true || data is Map,
        data: data is Map ? Map<String, dynamic>.from(data) : null,
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<MenuRecommendation> recommendMenu({
    required String menuName,
    required List<String> ingredients,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/sppg/scan/recommend',
        data: {'menu_name': menuName, 'ingredients': ingredients},
      );
      final body = _object(response.data, allowEmpty: true);
      final raw = body['recommendations'] ?? body['rekomendasi'] ?? const [];
      return MenuRecommendation(
        active: body['rekomendasi_aktif'] != false,
        items: raw is List
            ? raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
            : const [],
        message: '${body['message'] ?? ''}',
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 503) {
        final data = error.response?.data;
        return MenuRecommendation(
          active: false,
          items: const [],
          message: data is Map ? '${data['message'] ?? ''}' : '',
        );
      }
      throw _failure(error);
    }
  }

  Future<List<FoodReport>> getDeliveryReports({int? month, int? year}) async {
    try {
      final response = await _dio.get<Object?>(
        '/sppg/delivery-reports',
        queryParameters: {'month': month, 'year': year}
          ..removeWhere((_, value) => value == null),
      );
      return _flattenMaps(response.data)
          .map(_foodReportFromJson)
          .where((item) => item != null)
          .cast<FoodReport>()
          .toList(growable: false);
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<FoodReport> getDeliveryReportDetail(int id) async {
    try {
      final response = await _dio.get<Object?>('/sppg/delivery-reports/$id');
      final report = _foodReportFromJson(_object(response.data));
      if (report == null) throw const AppFailure(FailureKind.unexpected);
      return report;
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<void> submitDeliveryReport({
    required int schoolId,
    required DateTime deliveryDate,
    required int totalPortions,
    int? distributedPortions,
    required List<Map<String, dynamic>> menuItems,
    Uint8List? photo1,
    Uint8List? photo2,
  }) async {
    try {
      final fields = <String, dynamic>{
        'school_id': schoolId,
        'delivery_date': deliveryDate.toIso8601String().split('T').first,
        'total_portions': totalPortions,
        'distributed_portions': distributedPortions,
        'menu_items': jsonEncode(menuItems),
      }..removeWhere((_, value) => value == null);
      if (photo1 != null) {
        fields['photo1'] = MultipartFile.fromBytes(
          photo1,
          filename: 'photo1.jpg',
        );
      }
      if (photo2 != null) {
        fields['photo2'] = MultipartFile.fromBytes(
          photo2,
          filename: 'photo2.jpg',
        );
      }
      await _dio.post<Object?>(
        '/sppg/delivery-reports',
        data: FormData.fromMap(fields),
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<void> submitFoodProblem({
    required String schoolName,
    required String foodName,
    required String issueType,
    required int affectedPortions,
    required String description,
    String priority = 'Sedang',
    Uint8List? photo,
  }) async {
    try {
      final fields = <String, dynamic>{
        'namaSekolah': schoolName,
        'namaMakanan': foodName,
        'jenisMasalah': issueType,
        'porsiTerdampak': affectedPortions,
        'deskripsiMasalah': description,
        'prioritas': priority,
      };
      if (photo != null) {
        fields['fotoMasalah'] = MultipartFile.fromBytes(
          photo,
          filename: 'bukti.jpg',
        );
      }
      await _dio.post<Object?>(
        '/sppg/food-problems',
        data: FormData.fromMap(fields),
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<List<FoodIssue>> getSchoolComplaints({int? month, int? year}) async {
    try {
      final response = await _dio.get<Object?>(
        '/sppg/food-reports',
        queryParameters: {'month': month, 'year': year}
          ..removeWhere((_, value) => value == null),
      );
      return _flattenMaps(response.data)
          .map(_foodIssueFromJson)
          .where((item) => item != null)
          .cast<FoodIssue>()
          .toList(growable: false);
    } catch (error) {
      throw _failure(error);
    }
  }

  Map<String, dynamic> _object(Object? body, {bool allowEmpty = false}) {
    if (body is Map) {
      final value = body['data'] ?? body['result'] ?? body;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    if (allowEmpty) return {};
    throw const AppFailure(FailureKind.unexpected);
  }

  List<dynamic> _list(Object? body) {
    if (body is List) return body;
    if (body is Map) {
      final data = body['data'];
      final value = data is Map
          ? data['schools'] ?? data['available_schools']
          : data ?? body['schools'] ?? body['available_schools'];
      if (value is List) return value;
    }
    throw const AppFailure(FailureKind.unexpected);
  }

  AppFailure _failure(Object error) {
    if (error is DioException && error.response?.data is Map) {
      final message = (error.response!.data as Map)['message'];
      if (message is String && message.isNotEmpty) {
        return AppFailure(
          FailureKind.unexpected,
          cause: error,
          messageOverride: message,
        );
      }
    }
    return AppFailure.from(error);
  }
}

String _debugJson(Object? value) {
  try {
    return jsonEncode(value);
  } catch (_) {
    return '$value';
  }
}

List<Map<String, dynamic>> _flattenMaps(Object? body) {
  Object? value = body;
  while (value is Map &&
      (value.containsKey('data') || value.containsKey('result'))) {
    final nested = value['data'] ?? value['result'];
    if (nested is! Map && nested is! List) break;
    value = nested;
  }
  if (value is Map) {
    value = value['reports'] ?? value['deliveries'] ?? value['items'] ?? value;
  }
  if (value is List) {
    final output = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final nested =
            map['reports'] ?? map['deliveries'] ?? map['items'] ?? map['schools'];
        if (nested is List) {
          for (final child in nested.whereType<Map>()) {
            final childMap = Map<String, dynamic>.from(child);
            childMap.putIfAbsent(
              'delivery_date',
              () => map['date'] ?? map['delivery_date'],
            );
            output.add(childMap);
          }
        } else {
          output.add(map);
        }
      }
    }
    return output;
  }
  return const [];
}

FoodReport? _foodReportFromJson(Map<String, dynamic> json) {
  final rawDate = json['delivery_date'] ?? json['date'] ?? json['created_at'];
  final date = DateTime.tryParse('$rawDate');
  if (date == null) return null;
  final school = json['school'];
  final schoolMap = school is Map ? school : const <String, dynamic>{};
  final rawMenu = json['menu_items'] ?? json['menus'];
  final rawAllergies = json['allergies'] ?? json['allergy_details'];
  final rawPhotos = json['documentation_photos'] ?? json['photos'];
  final photosMap = rawPhotos is Map ? rawPhotos : const <String, dynamic>{};
  final allergyStudents = json['allergy_students'];
  final statusText = '${json['status'] ?? ''}'.toLowerCase();
  return FoodReport(
    id: _integer(json['id'] ?? json['report_id']),
    date: date.toLocal(),
    school: '${json['school_name'] ?? schoolMap['name'] ?? 'Sekolah'}',
    address:
        '${json['school_address'] ?? json['address'] ?? schoolMap['address'] ?? ''}',
    portions: _integer(json['total_portions'] ?? json['portions']),
    distributedPortions: _integer(
      json['distributed_portions'] ?? json['portions_distributed'],
    ),
    studentsWithAllergies: _integer(
      json['students_with_allergies'] ??
          json['allergy_student_count'] ??
          (allergyStudents is Map ? allergyStudents['total'] : null),
    ),
    status: statusText.contains('receive') || statusText.contains('diterima')
        ? FoodReportStatus.received
        : statusText.contains('reject') || statusText.contains('ditolak')
        ? FoodReportStatus.rejected
        : FoodReportStatus.pending,
    allergies: rawAllergies is List
        ? rawAllergies.whereType<Map>().map((item) => FoodReportAllergy(
            name: '${item['name'] ?? item['allergy_type'] ?? ''}',
            students: _integer(item['students'] ?? item['count']),
          )).toList(growable: false)
        : const [],
    menuItems: rawMenu is List
        ? rawMenu.whereType<Map>().map((item) => FoodReportMenuItem(
            name: '${item['menu_name'] ?? item['name'] ?? ''}',
            category: '${item['category'] ?? ''}',
            portions: _integer(item['portions']),
          )).toList(growable: false)
        : const [],
    documentationPhotos: rawPhotos is List
        ? rawPhotos.map((item) => '$item').where((item) => item.isNotEmpty).toList()
        : [
            json['photo1_url'],
            json['photo2_url'],
            json['photo1'],
            json['photo2'],
            photosMap['photo1'],
            photosMap['photo2'],
          ]
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .toList(growable: false),
  );
}

FoodIssue? _foodIssueFromJson(Map<String, dynamic> json) {
  final rawDate = json['reported_at'] ?? json['created_at'] ?? json['date'];
  final date = DateTime.tryParse('$rawDate');
  if (date == null) return null;
  final rawPhotos = json['photo_urls'] ?? json['photos'];
  final status = '${json['status'] ?? ''}'.toLowerCase();
  return FoodIssue(
    id: '${json['id'] ?? ''}',
    school: '${json['school_name'] ?? json['school'] ?? 'Sekolah'}',
    date: date.toLocal(),
    menu: '${json['food_name'] ?? json['menu_name'] ?? json['food'] ?? '-'}',
    description: '${json['description'] ?? json['details'] ?? ''}',
    affectedPortions: _integer(
      json['affected_portions'] ?? json['portions_affected'],
    ),
    status: status.contains('resolve') || status.contains('selesai')
        ? FoodIssueStatus.resolved
        : status.contains('progress') || status.contains('proses')
        ? FoodIssueStatus.inProgress
        : FoodIssueStatus.pending,
    reporter: '${json['reporter_name'] ?? json['reporter'] ?? 'Sekolah'}',
    problem: '${json['issue_type'] ?? json['problem_type'] ?? 'Lainnya'}',
    photoUrls: rawPhotos is List
        ? rawPhotos.map((item) => '$item').toList(growable: false)
        : [json['photo_url'], json['photo_path']]
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .toList(growable: false),
  );
}

int _integer(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text) ?? 0,
  _ => 0,
};
