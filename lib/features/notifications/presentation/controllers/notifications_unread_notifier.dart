import 'dart:async';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Lightweight singleton that keeps the app-bar unread badge in sync.
class NotificationsUnreadNotifier extends BaseController {
  NotificationsUnreadNotifier(this._repository, this._authRepository);

  final NotificationsRepository _repository;
  final AuthRepository _authRepository;

  int unreadCount = 0;

  StreamSubscription<int>? _countSub;
  StreamSubscription<bool>? _authSub;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _authSub = _authRepository.watchAuthState().listen((loggedIn) {
      if (loggedIn) {
        _listenCount();
      } else {
        _countSub?.cancel();
        _countSub = null;
        unreadCount = 0;
        notifyListeners();
      }
    });
    // Kick off immediately if already signed in.
    _authRepository.isLoggedIn().then((loggedIn) {
      if (loggedIn) {
        _listenCount();
      }
    });
  }

  void _listenCount() {
    _countSub?.cancel();
    _countSub = _repository.watchUnreadCount().listen(
      (count) {
        unreadCount = count;
        notifyListeners();
      },
      onError: (_) {
        unreadCount = 0;
        notifyListeners();
      },
    );
  }

  void updateCount(int count) {
    if (unreadCount == count) return;
    unreadCount = count;
    notifyListeners();
  }

  @override
  void dispose() {
    _countSub?.cancel();
    _authSub?.cancel();
    _started = false;
    super.dispose();
  }
}

void ensureNotificationsBadgeListening() {
  configureDependencies();
  if (sl.isRegistered<NotificationsUnreadNotifier>()) {
    sl<NotificationsUnreadNotifier>().start();
  }
}
