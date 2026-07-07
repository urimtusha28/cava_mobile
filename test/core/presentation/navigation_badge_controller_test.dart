import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/presentation/navigation_badge_controller.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/core/state/wishlist_state_notifier.dart';
import 'package:cava_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/local_wishlist_store.dart';
import 'package:cava_ecommerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  setUp(() async {
    await configureTestDependencies();
    await sl<CartRepository>().clear();
    LocalWishlistStore.clear();
    CartStateNotifier.reset();
    WishlistStateNotifier.reset();
  });

  tearDown(() async {
    await resetDependencies();
  });

  test('syncBadges reads counts without constructor side effects', () async {
    await sl<CartRepository>().addProduct(testProductEntity);
    await sl<CartRepository>().addProduct(testProductEntity);
    await sl<WishlistRepository>().add(testProductEntity);

    await NavigationBadgeController.syncBadges();

    expect(CartStateNotifier.revision.value, 2);
    expect(WishlistStateNotifier.revision.value, 1);
  });
}
