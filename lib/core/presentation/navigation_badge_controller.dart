import '../../../../core/di/injection.dart';
import '../../../../core/state/cart_state_notifier.dart';
import '../../../../core/state/wishlist_state_notifier.dart';

/// Badge counts for bottom navigation without importing data/mock layers.
abstract final class NavigationBadgeController {
  static void ensureInitialized() => configureDependencies();

  static int get cartCount => CartStateNotifier.revision.value;

  static int get wishlistCount => WishlistStateNotifier.revision.value;
}
