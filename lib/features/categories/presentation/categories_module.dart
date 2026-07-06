import '../../../../core/di/injection.dart';

/// Ensures category dependencies are registered before use.
abstract final class CategoriesModule {
  static void ensureInitialized() {
    configureDependencies();
  }
}
