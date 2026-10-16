import 'package:dio/dio.dart';

/// Offline API used by the demo APK. Every supported endpoint returns
/// deterministic data so the UI can be demonstrated without a backend.
class MockApiInterceptor extends Interceptor {
  MockApiInterceptor({this.latency = const Duration(milliseconds: 350)});

  final Duration latency;

  Map<String, dynamic> _profile = {
    'name': 'Dapur Sehat Subang',
    'email': 'mitra@sppg.id',
    'phone': '0812-3456-7890',
    'lokasi': 'Jl. Otto Iskandardinata No. 48, Subang, Jawa Barat',
    'institution_name': 'Yayasan Gizi Anak Indonesia',
  };

  final List<Map<String, dynamic>> _schools = [
    {
      'id': 1,
      'name': 'SDN 1 Subang',
      'address': 'Jl. H.O. Iskandar No. 60, Subang, Jawa Barat',
      'level': 'SD',
      'students': 187,
      'teachers': 9,
      'allergy_types': ['Kacang', 'Telur', 'Susu'],
    },
    {
      'id': 2,
      'name': 'SMPN 1 Subang',
      'address': 'Jl. Letjen Suprapto No. 105, Subang, Jawa Barat',
      'level': 'SMP',
      'students': 340,
      'teachers': 20,
      'allergy_types': ['Kacang', 'Telur', 'Susu'],
    },
    {
      'id': 3,
      'name': 'SDN Karanganyar 2',
      'address': 'Jl. Palabuan No. 18, Subang, Jawa Barat',
      'level': 'SD',
      'students': 214,
      'teachers': 12,
      'allergy_types': ['Telur', 'Susu'],
    },
    {
      'id': 4,
      'name': 'SMPN 3 Subang',
      'address': 'Jl. K.S. Tubun No. 12, Subang, Jawa Barat',
      'level': 'SMP',
      'students': 428,
      'teachers': 27,
      'allergy_types': ['Kacang', 'Susu'],
    },
  ];

  final Set<int> _assignedSchoolIds = {1, 2};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);

    final path = options.path;
    final method = options.method.toUpperCase();
    Object? data;

    if (method == 'POST' && path == '/login') {
      data = {'token': 'nutrisafe-demo-token'};
    } else if (method == 'POST' && path == '/logout') {
      data = {'message': 'Berhasil keluar'};
    } else if (method == 'GET' && path == '/sppg/profile') {
      data = {'data': _profile};
    } else if (method == 'PUT' && path == '/sppg/profile') {
      final update = options.data;
      if (update is Map) {
        _profile = {..._profile, ...Map<String, dynamic>.from(update)};
      }
      data = {'data': _profile, 'message': 'Profil berhasil diperbarui'};
    } else if (method == 'GET' && path == '/sppg/status') {
      data = {
        'data': {
          'status': 'Aktif',
          'name': 'SPPG Dapur Sehat Subang',
          'address': 'Jl. Otto Iskandardinata No. 48, Subang, Jawa Barat',
          'production_capacity': 1200,
          'school_count': _assignedSchoolIds.length,
        },
      };
    } else if (method == 'GET' && path == '/sppg/available-schools') {
      data = {
        'data': _schools
            .where((school) => !_assignedSchoolIds.contains(school['id']))
            .toList(growable: false),
      };
    } else if (method == 'GET' && path == '/sppg/schools') {
      data = {
        'data': _schools
            .where((school) => _assignedSchoolIds.contains(school['id']))
            .toList(growable: false),
      };
    } else if (method == 'POST' && path == '/sppg/assign-schools') {
      final body = options.data;
      if (body is Map && body['school_ids'] is List) {
        _assignedSchoolIds.addAll(
          (body['school_ids'] as List).whereType<int>(),
        );
      }
      data = {'message': 'Sekolah berhasil ditambahkan'};
    } else if (method == 'GET' && path == '/sppg/allergy-dashboard') {
      data = {
        'data': {
          'schools': [
            {
              'name': 'SDN 1 Subang',
              'students': 196,
              'allergies': {'peanut': 5, 'egg': 4, 'milk': 0},
            },
            {
              'name': 'SMPN 1 Subang',
              'students': 360,
              'allergies': {'peanut': 5, 'egg': 4, 'milk': 0},
            },
          ],
        },
      };
    } else if (method == 'POST' && path == '/sppg/scan') {
      data = {
        'data': {
          'is_safe': true,
          'calories': 485,
          'ingredients': ['Nasi', 'Ayam', 'Wortel', 'Brokoli', 'Jeruk'],
          'allergens': <String>[],
        },
      };
    } else if (method == 'POST' && path == '/sppg/menu-reports') {
      data = {'message': 'Laporan menu berhasil disimpan'};
    } else if (method == 'POST' &&
        (path == '/register/sppg' ||
            path == '/forgot-password/request' ||
            path == '/forgot-password/verify' ||
            path == '/change-password')) {
      data = {'message': 'Berhasil diproses dalam mode demo'};
    } else {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            statusCode: 404,
            data: {'message': 'Endpoint demo belum tersedia: $method $path'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    handler.resolve(
      Response<Object?>(requestOptions: options, statusCode: 200, data: data),
    );
  }
}
