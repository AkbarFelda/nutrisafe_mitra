import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/core/error/app_failure.dart';
import 'package:nutrisafe_mitra/core/network/api_config.dart';
import 'package:nutrisafe_mitra/core/network/dio_factory.dart';

class TestAdapter implements HttpClientAdapter {
  int status = 200;
  int requests = 0;
  RequestOptions? lastRequest;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    lastRequest = options;
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'authorization, opt-out, JSON response and unauthorized callback',
    () async {
      String? rejected;
      final dio = createDio(
        config: const ApiConfig(baseUrl: 'https://example.test'),
        token: () => 'test-token',
        onUnauthorized: (token) async {
          rejected = token;
        },
      );
      addTearDown(() => dio.close());
      final adapter = TestAdapter();
      dio.httpClientAdapter = adapter;
      final response = await dio.get<Object?>('/test-only');
      expect(response.data, isA<Map>());
      expect(
        adapter.lastRequest!.headers['Authorization'],
        'Bearer test-token',
      );
      expect(adapter.lastRequest!.followRedirects, isFalse);
      adapter.status = 401;
      await expectLater(
        dio.get<Object?>('/test-only'),
        throwsA(
          isA<DioException>().having(
            (e) => (e.error! as AppFailure).kind,
            'kind',
            FailureKind.unauthorized,
          ),
        ),
      );
      expect(rejected, 'test-token');
      rejected = null;
      await expectLater(
        dio.get<Object?>(
          '/test-only',
          options: Options(extra: {'requiresAuth': false}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.lastRequest!.headers['Authorization'], isNull);
      expect(rejected, isNull);
    },
  );
  test(
    'missing configuration and foreign origins never reach transport',
    () async {
      for (final baseUrl in ['', 'https://example.test']) {
        final dio = createDio(
          config: ApiConfig(baseUrl: baseUrl),
          token: () => 'secret',
          onUnauthorized: (_) async {},
        );
        final adapter = TestAdapter();
        dio.httpClientAdapter = adapter;
        await expectLater(
          dio.get<Object?>('https://other.test/test-only'),
          throwsA(isA<DioException>()),
        );
        expect(adapter.requests, 0);
        dio.close();
      }
    },
  );
  test('network, timeout, server and unexpected mapping', () {
    final request = RequestOptions(path: '/test-only');
    expect(
      AppFailure.from(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      ).kind,
      FailureKind.network,
    );
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      expect(
        AppFailure.from(DioException(requestOptions: request, type: type)).kind,
        FailureKind.timeout,
      );
    }
    expect(
      AppFailure.from(
        DioException(
          requestOptions: request,
          response: Response<void>(requestOptions: request, statusCode: 503),
        ),
      ).kind,
      FailureKind.server,
    );
    expect(
      AppFailure.from(StateError('technical detail')).message,
      isNot(contains('technical detail')),
    );
  });
}
