import '../../../../core/di/injection.dart';

abstract final class WishlistModule {
  static void ensureInitialized() {
    configureDependencies();
  }
}
