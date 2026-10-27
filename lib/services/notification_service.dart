import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _localNotifications = [];

  int get unreadCount => _localNotifications.where((n) => !n.isRead).length;

  /// Fetch notifications from backend
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await ApiClient().get('/notifications');
      if (response['success'] == true && response['notifications'] is List) {
        final list = (response['notifications'] as List)
            .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _localNotifications.clear();
        _localNotifications.addAll(list);
        return list;
      }
    } catch (e) {
      debugPrint('[NotificationService] Get notifications fallback: $e');
    }

    if (_localNotifications.isEmpty) {
      _localNotifications.addAll(NotificationItem.sampleNotifications);
    }
    return _localNotifications;
  }

  /// Mark single notification as read
  Future<bool> markAsRead(String id) async {
    try {
      final response = await ApiClient().put('/notifications/$id/read', body: {});
      if (response['success'] == true) {
        _updateLocalReadStatus(id, true);
        return true;
      }
    } catch (e) {
      debugPrint('[NotificationService] Mark as read fallback: $e');
    }

    _updateLocalReadStatus(id, true);
    return true;
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await ApiClient().put('/notifications/read-all', body: {});
      if (response['success'] == true) {
        for (int i = 0; i < _localNotifications.length; i++) {
          _localNotifications[i] = _localNotifications[i].copyWith(isRead: true);
        }
        return true;
      }
    } catch (e) {
      debugPrint('[NotificationService] Mark all as read fallback: $e');
    }

    for (int i = 0; i < _localNotifications.length; i++) {
      _localNotifications[i] = _localNotifications[i].copyWith(isRead: true);
    }
    return true;
  }

  /// Delete notification
  Future<bool> deleteNotification(String id) async {
    try {
      final response = await ApiClient().delete('/notifications/$id');
      if (response['success'] == true) {
        _localNotifications.removeWhere((n) => n.id == id);
        return true;
      }
    } catch (e) {
      debugPrint('[NotificationService] Delete notification fallback: $e');
    }

    _localNotifications.removeWhere((n) => n.id == id);
    return true;
  }

  void _updateLocalReadStatus(String id, bool isRead) {
    for (int i = 0; i < _localNotifications.length; i++) {
      if (_localNotifications[i].id == id) {
        _localNotifications[i] = _localNotifications[i].copyWith(isRead: isRead);
        break;
      }
    }
  }
}
