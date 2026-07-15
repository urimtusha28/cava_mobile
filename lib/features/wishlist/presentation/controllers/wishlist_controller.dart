import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../../core/state/wishlist_state_notifier.dart';
import '../../../cart/domain/add_to_cart_result.dart';
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

  Future<AddToCartResult> addToCart(ProductEntity product) async {
    if (!product.inStock || product.stock <= 0) {
      return AddToCartResult.outOfStock;
    }

    try {
      final result = await _addToCart(
        AddToCartParams(product: product, quantity: 1),
      );
      if (!result.isSuccess) {
        final failure = result.failureOrNull;
        if (failure?.code == 'OUT_OF_STOCK') {
          return AddToCartResult.outOfStock;
        }
        if (failure?.code == 'INSUFFICIENT_STOCK') {
          return AddToCartResult.insufficientStock;
        }
        return AddToCartResult.failure;
      }

      // Remove only after a confirmed cart write; leave wishlist intact on failure.
      await _removeFromWishlist(product.id);
      await _refreshItems();
      return AddToCartResult.success;
    } catch (_) {
      return AddToCartResult.failure;
    }
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
  return sl<WishlistController>();
}
