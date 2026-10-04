import 'package:dio/dio.dart';

import '../../../core/error/app_failure.dart';

class LoginCredentials {
  const LoginCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<String> login(LoginCredentials credentials) async {
    try {
      final response = await _dio.post<Object?>(
        '/login',
        data: {'email': credentials.email, 'password': credentials.password},
        options: Options(extra: const {'requiresAuth': false}),
      );
      final token = _readToken(response.data);
      if (token == null || token.trim().isEmpty) {
        throw const AppFailure(FailureKind.unexpected);
      }
      return token;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 422) {
        throw AppFailure(FailureKind.invalidCredentials, cause: error);
      }
      throw AppFailure.from(error);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<Object?>('/logout');
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  String? _readToken(Object? body) {
    if (body is! Map) return null;
    final direct = body['token'] ?? body['access_token'];
    if (direct is String) return direct;
    final data = body['data'];
    if (data is Map) {
      final nested = data['token'] ?? data['access_token'];
      if (nested is String) return nested;
    }
    return null;
  }
}
