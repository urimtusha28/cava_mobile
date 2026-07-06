import 'package:flutter/foundation.dart';

import '../../../core/di/injection.dart';
import '../../../core/state/auth_state_notifier.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/is_logged_in.dart';
import '../domain/usecases/login.dart';
import 'auth_module.dart';

abstract final class AuthQuery {
  static ValueNotifier<bool> get authState => AuthStateNotifier.isLoggedIn;

  static bool get isLoggedIn {
    AuthModule.ensureInitialized();
    return sl<IsLoggedInUseCase>().call().fold(
          onSuccess: (data) => data,
          onFailure: (_) => false,
        );
  }

  static String get userName {
    AuthModule.ensureInitialized();
    return sl<AuthRepository>().getUserName();
  }

  static void login() {
    AuthModule.ensureInitialized();
    sl<LoginUseCase>().call();
  }
}
