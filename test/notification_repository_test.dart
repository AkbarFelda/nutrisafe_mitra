import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/core/network/api_config.dart';
import 'package:nutrisafe_mitra/core/network/dio_factory.dart';
import 'package:nutrisafe_mitra/features/notifications/data/notification_repository.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = options.path == '/notifications'
        ? '{"data":[{"id":2,"type":"laporan_terkirim","title":"Laporan Terkirim!","body":"Berhasil","is_read":false,"time_label":"13:07","created_at":"2026-10-16T13:07:52Z"}],"total":1,"unread_count":1}'
        : options.path == '/notifications/unread-count'
        ? '{"unread_count":1}'
        : '{"status":"success"}';
    return ResponseBody.fromString(
      body,
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
  test('fetches and marks notifications through documented endpoints', () async {
    final dio = createDio(
      config: const ApiConfig(baseUrl: 'https://api.nutrisafe.id'),
      token: () => 'token',
      onUnauthorized: (_) async {},
    );
    final adapter = _Adapter();
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);
    final repository = NotificationRepository(dio);

    final page = await repository.getNotifications(unreadOnly: true);
    final count = await repository.getUnreadCount();
    await repository.markAsRead(2);
    await repository.markAllAsRead();

    expect(page.items.single.title, 'Laporan Terkirim!');
    expect(page.items.single.isRead, isFalse);
    expect(page.unreadCount, 1);
    expect(count, 1);
    expect(adapter.requests.map((item) => '${item.method} ${item.path}'), [
      'GET /notifications',
      'GET /notifications/unread-count',
      'PATCH /notifications/2/read',
      'PATCH /notifications/read-all',
    ]);
    expect(adapter.requests.first.queryParameters['unread_only'], isTrue);
  });
}
