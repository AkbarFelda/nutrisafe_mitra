import 'package:dio/dio.dart';

import '../../../core/error/app_failure.dart';

class AppNotification {
  const AppNotification({required this.id, required this.type, required this.title, required this.body, required this.isRead, required this.createdAt, this.timeLabel = ''});
  final int id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String timeLabel;

  AppNotification copyWith({bool? isRead}) => AppNotification(id: id, type: type, title: title, body: body, isRead: isRead ?? this.isRead, createdAt: createdAt, timeLabel: timeLabel);

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: _integer(json['id']),
    type: '${json['type'] ?? ''}',
    title: '${json['title'] ?? 'Notifikasi'}',
    body: '${json['body'] ?? json['message'] ?? ''}',
    isRead: json['is_read'] == true || json['read_at'] != null,
    createdAt: DateTime.tryParse('${json['created_at'] ?? ''}')?.toLocal() ?? DateTime.now(),
    timeLabel: '${json['time_label'] ?? ''}',
  );
}

class NotificationPageData {
  const NotificationPageData({required this.items, required this.total, required this.unreadCount});
  final List<AppNotification> items;
  final int total;
  final int unreadCount;
}

class NotificationRepository {
  const NotificationRepository(this._dio);
  final Dio _dio;

  Future<NotificationPageData> getNotifications({int limit = 20, int offset = 0, bool unreadOnly = false}) async {
    try {
      final response = await _dio.get<Object?>('/notifications', queryParameters: {'limit': limit, 'offset': offset, if (unreadOnly) 'unread_only': true});
      final body = response.data;
      if (body is! Map || body['data'] is! List) throw const AppFailure(FailureKind.unexpected);
      return NotificationPageData(
        items: (body['data'] as List).whereType<Map>().map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
        total: _integer(body['total']),
        unreadCount: _integer(body['unread_count']),
      );
    } catch (error) { throw AppFailure.from(error); }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get<Object?>('/notifications/unread-count');
      if (response.data case final Map body) return _integer(body['unread_count']);
      throw const AppFailure(FailureKind.unexpected);
    } catch (error) { throw AppFailure.from(error); }
  }

  Future<void> markAsRead(int id) async {
    try { await _dio.patch<Object?>('/notifications/$id/read'); } catch (error) { throw AppFailure.from(error); }
  }

  Future<void> markAllAsRead() async {
    try { await _dio.patch<Object?>('/notifications/read-all'); } catch (error) { throw AppFailure.from(error); }
  }
}

int _integer(Object? value) => switch (value) { int number => number, num number => number.toInt(), String text => int.tryParse(text) ?? 0, _ => 0 };
