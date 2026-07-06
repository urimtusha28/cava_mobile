import 'package:flutter/foundation.dart';

import '../../../core/di/injection.dart';
import '../../../core/state/wishlist_state_notifier.dart';
import '../../products/domain/entities/product_entity.dart';
import '../domain/usecases/get_wishlist_count.dart';
import '../domain/usecases/get_wishlist_items.dart';
import '../domain/usecases/remove_from_wishlist.dart';
import 'wishlist_module.dart';

abstract final class WishlistQuery {
  static ValueNotifier<int> get revision => WishlistStateNotifier.revision;

  static List<ProductEntity> getItems() {
    WishlistModule.ensureInitialized();
    return sl<GetWishlistItemsUseCase>().call().fold(
          onSuccess: (data) => data,
          onFailure: (_) => const [],
        );
  }

  static int get count {
    WishlistModule.ensureInitialized();
    return sl<GetWishlistCountUseCase>().call().fold(
          onSuccess: (data) => data,
          onFailure: (_) => 0,
        );
  }

  static void remove(String productId) {
    WishlistModule.ensureInitialized();
    sl<RemoveFromWishlistUseCase>().call(productId);
  }
}
