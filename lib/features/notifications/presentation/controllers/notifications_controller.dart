import 'dart:async';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../utils/notification_presentation.dart';
import 'notifications_unread_notifier.dart';

class NotificationsController extends BaseController {
  NotificationsController(this._repository);

  final NotificationsRepository _repository;

  List<AppNotification> items = const [];
  int unreadCount = 0;
  int unreadTodayCount = 0;

  StreamSubscription<List<AppNotification>>? _subscription;

  Future<void> load() => startListening();

  Future<void> startListening() {
    return runLoad(() async {
      await _subscription?.cancel();
      final completer = Completer<void>();
      _subscription = _repository.watchUserNotifications(limit: 20).listen(
        (list) {
          items = list;
          unreadCount = list.where((n) => !n.isRead).length;
          unreadTodayCount = list
              .where(
                (n) => !n.isRead && NotificationPresentation.isToday(n.createdAt),
              )
              .length;
          if (sl.isRegistered<NotificationsUnreadNotifier>()) {
            sl<NotificationsUnreadNotifier>().updateCount(unreadCount);
          }
          notifyListeners();
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (Object error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );
      await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {},
      );
    });
  }

  Future<void> markRead(String id) {
    return runAction(() => _repository.markAsRead(id));
  }

  Future<void> markAllRead() {
    return runAction(() => _repository.markAllAsRead());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

NotificationsController createNotificationsController() {
  configureDependencies();
  return sl<NotificationsController>();
}
