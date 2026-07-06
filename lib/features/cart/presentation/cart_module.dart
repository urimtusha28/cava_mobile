import '../../../../core/di/injection.dart';

abstract final class CartModule {
  static void ensureInitialized() {
    configureDependencies();
  }
}
