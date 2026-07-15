import 'dart:async';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../domain/repositories/admin_support_repository.dart';

class AdminSupportUnreadNotifier extends BaseController {
  AdminSupportUnreadNotifier(this._repository, this._authRepository);

  final AdminSupportRepository _repository;
  final AuthRepository _authRepository;

  int unreadCount = 0;
  StreamSubscription<int>? _sub;
  StreamSubscription<bool>? _authSub;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _authSub = _authRepository.watchAuthState().listen((loggedIn) {
      if (loggedIn) {
        _listen();
      } else {
        _sub?.cancel();
        unreadCount = 0;
        notifyListeners();
      }
    });
    _authRepository.isLoggedIn().then((loggedIn) {
      if (loggedIn) _listen();
    });
  }

  void _listen() {
    _sub?.cancel();
    _sub = _repository.watchUnreadByAdmin().listen(
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

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    _started = false;
    super.dispose();
  }
}

void ensureAdminSupportBadgeListening() {
  configureDependencies();
  if (sl.isRegistered<AdminSupportUnreadNotifier>()) {
    sl<AdminSupportUnreadNotifier>().start();
  }
}
