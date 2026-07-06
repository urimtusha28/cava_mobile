import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../../core/state/wishlist_state_notifier.dart';
import '../../../cart/domain/usecases/add_to_cart.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/usecases/get_wishlist_items.dart';
import '../../domain/usecases/remove_from_wishlist.dart';

class WishlistController extends BaseController {
  WishlistController(
    this._getWishlistItems,
    this._removeFromWishlist,
    this._addToCart,
  );

  final GetWishlistItemsUseCase _getWishlistItems;
  final RemoveFromWishlistUseCase _removeFromWishlist;
  final AddToCartUseCase _addToCart;

  List<ProductEntity> items = const [];

  int get count => items.length;

  Future<void> load() {
    return runLoad(_refreshItems);
  }

  Future<void> remove(String productId) {
    return runAction(() async {
      await _removeFromWishlist(productId);
      await _refreshItems();
    });
  }

  Future<void> addToCart(ProductEntity product) {
    return runAction(() async {
      await _addToCart(product);
    });
  }

  Future<void> _refreshItems() async {
    items = await unwrapFutureResult(
      _getWishlistItems(),
      fallback: const [],
    );
    WishlistStateNotifier.update(items.length);
  }
}

WishlistController createWishlistController() {
  configureDependencies();
  return WishlistController(sl(), sl(), sl());
}
