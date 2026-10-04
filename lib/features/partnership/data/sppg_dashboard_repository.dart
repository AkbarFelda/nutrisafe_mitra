import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/error/app_failure.dart';
import '../../schools/domain/school.dart';
import '../../allergy_monitoring/domain/allergy_monitoring.dart';

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

  factory SppgStatus.fromJson(Map<String, dynamic> json) => SppgStatus(
    status: '${json['status'] ?? 'Aktif'}',
    name: '${json['name'] ?? json['sppg_name'] ?? 'SPPG'}',
    address: '${json['address'] ?? json['lokasi'] ?? ''}',
    capacity: _integer(json['production_capacity'] ?? json['capacity']),
    schoolCount: _integer(json['school_count'] ?? json['total_schools']),
  );
}

class ScanResult {
  const ScanResult({required this.payload});
  final Map<String, dynamic> payload;
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
              ];
              return SchoolAllergyData(
                name: '${json['name'] ?? json['school_name'] ?? ''}',
                students: _integer(json['students'] ?? json['student_count']),
                studentAllergies: studentAllergies,
              );
            })
            .toList(growable: false),
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<ScanResult> scanFood({required Uint8List imageBytes}) async {
    try {
      final response = await _dio.post<Object?>(
        '/sppg/scan',
        data: FormData.fromMap({
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: 'menu.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        }),
      );
      return ScanResult(payload: _object(response.data, allowEmpty: true));
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

int _integer(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text) ?? 0,
  _ => 0,
};
