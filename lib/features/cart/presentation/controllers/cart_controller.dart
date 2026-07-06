import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../../core/state/cart_state_notifier.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/usecases/get_cart_summary.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/update_cart_quantity.dart';

class CartController extends BaseController {
  CartController(
    this._getCartSummary,
    this._updateCartQuantity,
    this._removeFromCart,
  );

  final GetCartSummaryUseCase _getCartSummary;
  final UpdateCartQuantityUseCase _updateCartQuantity;
  final RemoveFromCartUseCase _removeFromCart;

  CartSummaryEntity summary = const CartSummaryEntity(
    items: [],
    itemCount: 0,
    subtotal: 0,
    discount: 0,
    vat: 0,
    shipping: 0,
    total: 0,
  );

  List<CartItemEntity> get items => summary.items;
  int get itemCount => summary.itemCount;
  double get subtotal => summary.subtotal;
  double get discount => summary.discount;
  double get vat => summary.vat;
  double get shipping => summary.shipping;
  double get total => summary.total;

  Future<void> load() {
    return runLoad(_refreshSummary);
  }

  Future<void> updateQuantity(int index, int quantity) {
    return runAction(() async {
      await _updateCartQuantity(
        UpdateCartQuantityParams(index: index, quantity: quantity),
      );
      await _refreshSummary();
    });
  }

  Future<void> removeAt(int index) {
    return runAction(() async {
      await _removeFromCart(index);
      await _refreshSummary();
    });
  }

  Future<void> _refreshSummary() async {
    summary = await unwrapFutureResult(
      _getCartSummary(),
      fallback: summary,
    );
    CartStateNotifier.update(summary.itemCount);
  }
}

CartController createCartController() {
  configureDependencies();
  return CartController(sl(), sl(), sl());
}
