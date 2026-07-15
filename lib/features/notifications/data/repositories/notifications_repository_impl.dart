import '../../../../core/error/failures.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_firebase_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dataSource, this._authRepository);

  final NotificationsFirebaseDataSource _dataSource;
  final AuthRepository _authRepository;

  Future<String> _requireUid() async {
    final uid = await _authRepository.getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      throw const AuthFailure(
        message: 'Duhet të jeni të kyçur.',
        code: 'NOT_SIGNED_IN',
      );
    }
    return uid;
  }

  @override
  Stream<List<AppNotification>> watchUserNotifications({int limit = 20}) async* {
    final uid = await _authRepository.getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      yield const [];
      return;
    }
    yield* _dataSource
        .watchUserNotifications(userId: uid, limit: limit)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  /// Unread badge: stream recent notifications (limit 50) and count unread
  /// client-side so we do not need a composite index across `isRead`/`read`.
  @override
  Stream<int> watchUnreadCount() {
    return watchUserNotifications(limit: 50).map((items) {
      return items.where((n) => !n.isRead).length;
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final uid = await _requireUid();
    await _dataSource.markAsRead(userId: uid, notificationId: notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    final uid = await _requireUid();
    await _dataSource.markAllAsRead(userId: uid);
  }

  @override
  Future<void> createNotificationForUser({
    required String recipientUid,
    required String title,
    required String body,
    required NotificationType type,
  }) {
    return _dataSource.createNotificationForUser(
      recipientUid: recipientUid,
      title: title,
      body: body,
      type: type,
    );
  }
}
