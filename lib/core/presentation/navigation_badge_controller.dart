import '../di/injection.dart';
import '../state/auth_state_notifier.dart';
import '../state/cart_state_notifier.dart';
import '../state/wishlist_state_notifier.dart';
import '../../features/account/domain/repositories/auth_repository.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/notifications/presentation/controllers/notifications_unread_notifier.dart';
import '../../features/support/presentation/controllers/admin_support_unread_notifier.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';

/// Badge counts for bottom navigation without importing data/mock layers.
abstract final class NavigationBadgeController {
  static void ensureInitialized() => configureDependencies();

  /// Syncs cart/wishlist/auth badge state after DI is ready — not during build.
  static Future<void> syncBadges() async {
    configureDependencies();

    await sl<CartRepository>().hydrateFromStorage();
    CartStateNotifier.update(await sl<CartRepository>().getItemCount());
    WishlistStateNotifier.update(await sl<WishlistRepository>().getCount());
    AuthStateNotifier.update(await sl<AuthRepository>().isLoggedIn());
    ensureNotificationsBadgeListening();
    ensureAdminSupportBadgeListening();
  }

  static int get cartCount => CartStateNotifier.revision.value;

  static int get wishlistCount => WishlistStateNotifier.revision.value;
}
