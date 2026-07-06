import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';

/// Checkout presentation controller — reuses cart totals.
class CheckoutController extends BaseController {
  CheckoutController(this._cartController) {
    _cartController.addListener(notifyListeners);
  }

  final CartController _cartController;

  double get total => _cartController.total;
  double get subtotal => _cartController.subtotal;
  double get vat => _cartController.vat;
  double get shipping => _cartController.shipping;
  double get discount => _cartController.discount;

  Future<void> load() => _cartController.load();
}

CheckoutController createCheckoutController() {
  configureDependencies();
  return CheckoutController(createCartController());
}
