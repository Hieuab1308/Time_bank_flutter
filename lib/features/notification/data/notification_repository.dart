import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/auth_api_client.dart';
import '../domain/models/notification_models.dart';

abstract class INotificationRepository {
  Future<List<AppNotification>> getActivity({String? cursor});
  Future<void> markRead(List<String> ids);
  Future<void> setFcmToken(String token);
  Future<void> deactivateFcmToken(String token);
  Future<int> getUnreadCount();
  Future<List<AppNotification>> listGeneralNotifications({String? cursor});
}

class NotificationRepository implements INotificationRepository {
  NotificationRepository(this._api);
  final AuthApiClient _api;

  @override
  Future<List<AppNotification>> getActivity({String? cursor}) async {
    final http.Response res = await _api.get(
      '/notifications/activity',
      query: { if (cursor != null) 'cursor': cursor },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load activity: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markRead(List<String> ids) async {
    final http.Response res = await _api.patch('/notifications/mark-read', body: {'ids': ids});
    if (res.statusCode != 200) {
      throw Exception('Failed to mark read: ${res.statusCode}');
    }
  }

  @override
  Future<void> setFcmToken(String token) async {
    final http.Response res = await _api.patch('/notifications/fcm-token', body: {'token': token});
    if (res.statusCode != 200) {
      throw Exception('Failed to set fcm token: ${res.statusCode}');
    }
  }

  @override
  Future<void> deactivateFcmToken(String token) async {
    try {
      await _api.patch('/notifications/fcm-token/deactivate', body: {'token': token});
    } catch (e) {
      print('Failed to deactivate FCM token (ignoring): $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    final http.Response res = await _api.get('/notifications/unread-count');
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch unread count: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['count'] as int;
  }
  @override
  Future<List<AppNotification>> listGeneralNotifications({String? cursor}) async {
    final http.Response res = await _api.get(
      '/notifications/general',
      query: { if (cursor != null) 'cursor': cursor },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load general activity: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }
}