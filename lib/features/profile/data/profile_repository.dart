import 'package:dio/dio.dart';

import '../../../core/error/app_failure.dart';
import 'sppg_profile.dart';

class ProfileRepository {
  const ProfileRepository(this._dio);
  final Dio _dio;

  Future<SppgProfile> getProfile() async {
    try {
      final response = await _dio.get<Object?>('/sppg/profile');
      return SppgProfile.fromJson(_object(response.data));
    } catch (error) {
      throw _failure(error);
    }
  }

  Future<SppgProfile> updateProfile(SppgProfile profile) async {
    try {
      final response = await _dio.put<Object?>(
        '/sppg/profile',
        data: profile.toJson(),
      );
      final body = _object(response.data, allowEmpty: true);
      return body.isEmpty ? profile : SppgProfile.fromJson(body);
    } catch (error) {
      throw _failure(error);
    }
  }

  Map<String, dynamic> _object(Object? body, {bool allowEmpty = false}) {
    if (body is Map) {
      Object? value = body['data'] ?? body['profile'] ?? body['sppg'] ?? body;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    if (allowEmpty) return {};
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
