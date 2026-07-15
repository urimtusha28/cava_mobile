import 'package:flutter/foundation.dart';

import 'app_role.dart';

/// Session state used by go_router redirects and post-login navigation.
///
/// UI reads [role] / [isOwner] only — it never resolves Firebase claims itself.
class AppSessionNotifier extends ChangeNotifier {
  AppSessionNotifier._();

  static final AppSessionNotifier instance = AppSessionNotifier._();

  bool _isLoggedIn = false;
  AppRole _role = AppRole.customer;
  bool _roleResolved = false;

  bool get isLoggedIn => _isLoggedIn;
  AppRole get role => _role;
  bool get isOwner => _role == AppRole.owner;

  /// True after at least one successful [update] / [clear] this process.
  bool get roleResolved => _roleResolved;

  void update({
    required bool isLoggedIn,
    required AppRole role,
  }) {
    final nextRole = isLoggedIn ? role : AppRole.customer;
    if (_isLoggedIn == isLoggedIn &&
        _role == nextRole &&
        _roleResolved) {
      return;
    }
    _isLoggedIn = isLoggedIn;
    _role = nextRole;
    _roleResolved = true;
    notifyListeners();
  }

  void clear() {
    if (!_isLoggedIn && _role == AppRole.customer && _roleResolved) {
      return;
    }
    _isLoggedIn = false;
    _role = AppRole.customer;
    _roleResolved = true;
    notifyListeners();
  }

  /// Test / DI reset.
  void reset() {
    _isLoggedIn = false;
    _role = AppRole.customer;
    _roleResolved = false;
    notifyListeners();
  }
}
