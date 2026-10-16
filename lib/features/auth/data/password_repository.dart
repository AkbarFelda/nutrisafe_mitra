import 'package:dio/dio.dart';

import '../../../core/error/app_failure.dart';

class PasswordRepository {
  const PasswordRepository(this._dio);
  final Dio _dio;

  Future<void> requestResetCode(String email) =>
      _post('/forgot-password/request', {'email': email}, requiresAuth: false);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _post('/forgot-password/verify', {
    'email': email,
    'code': code,
    'new_password': newPassword,
  }, requiresAuth: false);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) => _post('/change-password', {
    'old_password': oldPassword,
    'new_password': newPassword,
  });

  Future<void> _post(
    String path,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      await _dio.post<Object?>(
        path,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map ? body['message'] : null;
      if (message is String && message.isNotEmpty) {
        throw AppFailure(
          FailureKind.unexpected,
          cause: error,
          messageOverride: message,
        );
      }
      throw AppFailure.from(error);
    }
  }
}
