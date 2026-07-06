import '../../../../core/di/injection.dart';

abstract final class AuthModule {
  static void ensureInitialized() {
    configureDependencies();
  }
}
