import 'package:flutter/foundation.dart';

/// Notifies listeners when auth state changes.
abstract final class AuthStateNotifier {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

  static void update(bool loggedIn) {
    isLoggedIn.value = loggedIn;
  }
}
