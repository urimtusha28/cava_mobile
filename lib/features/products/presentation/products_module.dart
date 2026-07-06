import '../../../../core/di/injection.dart';

/// Ensures product dependencies are registered before use.
abstract final class ProductsModule {
  static void ensureInitialized() {
    configureDependencies();
  }
}
