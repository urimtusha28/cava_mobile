import '../../../../core/di/injection.dart';

/// Ensures home dependencies are registered before use.
abstract final class HomeModule {
  static void ensureInitialized() {
    configureDependencies();
  }
}
