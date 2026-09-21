import 'package:dio/dio.dart';

import '../error/app_failure.dart';
import 'api_config.dart';

/// Features decode their own response payloads. No credential logging.
Dio createDio({
  required ApiConfig config,
  required String? Function() token,
  required Future<void> Function(String) onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.isConfigured ? config.baseUrl : '',
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!config.isConfigured ||
            options.uri.origin != Uri.parse(config.baseUrl).origin) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: const AppFailure(FailureKind.configuration),
            ),
          );
          return;
        }
        options.followRedirects = false;
        options.headers.remove('Authorization');
        options.extra.remove('_sessionToken');
        final currentToken = token();
        if (options.extra['requiresAuth'] != false && currentToken != null) {
          options.headers['Authorization'] = 'Bearer $currentToken';
          options.extra['_sessionToken'] = currentToken;
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final sentToken = error.requestOptions.extra['_sessionToken'];
        if (error.response?.statusCode == 401 && sentToken is String) {
          await onUnauthorized(sentToken);
        }
        handler.next(error.copyWith(error: AppFailure.from(error)));
      },
    ),
  );
  return dio;
}
