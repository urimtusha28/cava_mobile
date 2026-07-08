import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies listeners when auth state changes.
abstract final class AuthStateNotifier {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  static Stream<bool> get stream => _controller.stream;

  /// Emits only when [loggedIn] differs from the current value.
  /// Avoids duplicate merge/badge work from AuthController + AuthRepository.
  static void update(bool loggedIn) {
    if (isLoggedIn.value == loggedIn) {
      return;
    }
    isLoggedIn.value = loggedIn;
    if (!_controller.isClosed) {
      _controller.add(loggedIn);
    }
  }

  /// Resets auth state — call from [resetDependencies] in tests.
  /// Always emits `false` so listeners clear merge locks even if already false.
  static void reset() {
    isLoggedIn.value = false;
    if (!_controller.isClosed) {
      _controller.add(false);
    }
  }
}
