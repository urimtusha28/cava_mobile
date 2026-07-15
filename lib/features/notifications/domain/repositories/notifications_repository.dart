import '../entities/app_notification.dart';
import '../entities/notification_type.dart';

abstract class NotificationsRepository {
  /// Recent notifications for the signed-in user (newest first).
  Stream<List<AppNotification>> watchUserNotifications({int limit = 20});

  /// Unread count derived client-side from a recent notifications stream
  /// (limit 50) to avoid dual-field (`isRead` / legacy `read`) composite
  /// index issues. Badge accuracy is limited to the loaded window.
  Stream<int> watchUnreadCount();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  /// Admin-only: write a notification into `users/{uid}/notifications`.
  Future<void> createNotificationForUser({
    required String recipientUid,
    required String title,
    required String body,
    required NotificationType type,
  });
}
