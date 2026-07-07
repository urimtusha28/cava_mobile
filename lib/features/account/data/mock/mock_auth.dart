import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_user_entity.dart';

abstract final class MockAuth {
  static bool isLoggedIn = false;

  static const String userName = 'Urim Tusha';
  static const String userEmail = 'mock@cava.test';

  static final ValueNotifier<bool> revision = ValueNotifier(isLoggedIn);

  static AuthUserEntity get currentUser => const AuthUserEntity(
        uid: 'mock-user-id',
        email: userEmail,
        displayName: userName,
      );

  static void login() {
    isLoggedIn = true;
    revision.value = true;
  }

  static void logout() {
    isLoggedIn = false;
    revision.value = false;
  }
}
