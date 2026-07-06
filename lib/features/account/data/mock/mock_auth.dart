import 'package:flutter/foundation.dart';

abstract final class MockAuth {
  static bool isLoggedIn = false;

  static const String userName = 'Urim Tusha';

  static final ValueNotifier<bool> revision = ValueNotifier(isLoggedIn);

  static void login() {
    isLoggedIn = true;
    revision.value = true;
  }

  static void logout() {
    isLoggedIn = false;
    revision.value = false;
  }
}
