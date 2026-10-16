import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/core/error/app_failure.dart';
import 'package:nutrisafe_mitra/core/network/api_config.dart';
import 'package:nutrisafe_mitra/core/network/dio_factory.dart';
import 'package:nutrisafe_mitra/features/auth/data/auth_repository.dart';

class _AuthAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/login') {
      return ResponseBody.fromString(
        '{"data":{"access_token":"api-token"}}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      '{"message":"logged out"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('login reads nested token and logout sends bearer token', () async {
    String? token;
    final dio = createDio(
      config: const ApiConfig(baseUrl: 'https://api.nutrisafe.id'),
      token: () => token,
      onUnauthorized: (_) async {},
    );
    addTearDown(() => dio.close());
    final adapter = _AuthAdapter();
    dio.httpClientAdapter = adapter;
    final repository = AuthRepository(dio);

    token = await repository.login(
      const LoginCredentials(email: 'sarah@sppg.id', password: 'password123'),
    );
    expect(token, 'api-token');
    expect(adapter.requests.first.path, '/login');
    expect(adapter.requests.first.headers['Authorization'], isNull);
    expect(adapter.requests.first.data, {
      'email': 'sarah@sppg.id',
      'password': 'password123',
    });

    await repository.logout();
    expect(adapter.requests.last.path, '/logout');
    expect(adapter.requests.last.headers['Authorization'], 'Bearer api-token');
  });

  test('login rejects non-SPPG email before calling the API', () async {
    final dio = createDio(
      config: const ApiConfig(baseUrl: 'https://api.nutrisafe.id'),
      token: () => null,
      onUnauthorized: (_) async {},
    );
    addTearDown(() => dio.close());
    final adapter = _AuthAdapter();
    dio.httpClientAdapter = adapter;
    final repository = AuthRepository(dio);

    await expectLater(
      repository.login(
        const LoginCredentials(
          email: 'sekolah@example.sch.id',
          password: 'password123',
        ),
      ),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'Gunakan email mitra dengan domain @sppg.id.',
        ),
      ),
    );
    expect(adapter.requests, isEmpty);
  });
}
