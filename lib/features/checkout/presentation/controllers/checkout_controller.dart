import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../account/domain/entities/address_entity.dart';
import '../../../account/domain/usecases/address_usecases.dart';
import '../../../account/domain/usecases/get_current_user.dart';
import '../../../account/domain/usecases/is_logged_in.dart';
import '../../../cart/domain/usecases/clear_cart.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/utils/place_order_exception_mapper.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/usecases/place_order.dart';
import '../models/checkout_session_state.dart';

class CheckoutController extends BaseController {
  CheckoutController(
    this._cartController,
    this._placeOrder,
    this._clearCart,
    this._isLoggedIn,
    this._getAddresses,
    this._getCurrentUser,
  ) {
    _cartController.addListener(notifyListeners);
  }

  final CartController _cartController;
  final PlaceOrderUseCase _placeOrder;
  final ClearCartUseCase _clearCart;
  final IsLoggedInUseCase _isLoggedIn;
  final GetAddressesUseCase _getAddresses;
  final GetCurrentUserUseCase _getCurrentUser;

  bool isSubmitting = false;
  bool isLoggedIn = false;
  bool hasAddress = false;
  bool hasItems = false;
  CheckoutCustomerInfo customerInfo = CheckoutCustomerInfo.empty;
  AddressEntity? defaultAddress;

  double get total => _cartController.total;
  double get subtotal => _cartController.subtotal;
  double get vat => _cartController.vat;
  double get shipping => _cartController.shipping;
  double get discount => _cartController.discount;

  Future<void> load() async {
    await runLoad(_cartController.load);
    await _refreshSession();
    notifyListeners();
  }

  Future<CheckoutSubmitResult> submitOrder({
    required String paymentMethod,
    required bool termsAccepted,
  }) async {
    final validation = _validateBeforeSubmit(termsAccepted: termsAccepted);
    if (validation != null) {
      return CheckoutSubmitResult.validationError(validation);
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final result = await _placeOrder(
        PlaceOrderRequest(
          paymentMethod: paymentMethod,
          termsAccepted: termsAccepted,
        ),
      );

      if (result.isFailure) {
        return CheckoutSubmitResult.requestError(
          _mapFailure(result.failureOrNull!),
        );
      }

      final order = result.dataOrNull!;
      await unwrapFutureResult(_clearCart(), fallback: null);
      await _cartController.load();
      return CheckoutSubmitResult.success(order);
    } catch (error) {
      if (error is Failure) {
        return CheckoutSubmitResult.requestError(_mapFailure(error));
      }
      return CheckoutSubmitResult.requestError(
        PlaceOrderExceptionMapper.defaultMessage,
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String? _validateBeforeSubmit({required bool termsAccepted}) {
    if (!isLoggedIn) {
      return 'Kyçu për të vazhduar me porosinë.';
    }
    if (!hasItems) {
      return 'Shporta është bosh.';
    }
    if (!termsAccepted) {
      return PlaceOrderExceptionMapper.toUserMessage(
        const ValidationFailure(
          message: 'Duhet të pranosh kushtet.',
          code: 'TERMS_REQUIRED',
        ),
      );
    }
    if (!hasAddress || defaultAddress == null) {
      return 'Shto një adresë para porosisë.';
    }
    if (customerInfo.email.trim().isEmpty) {
      return 'Kyçu për të vazhduar me porosinë.';
    }
    return null;
  }

  String _mapFailure(Failure failure) {
    return PlaceOrderExceptionMapper.toUserMessage(failure);
  }

  Future<void> _refreshSession() async {
    isLoggedIn = await unwrapFutureResult(_isLoggedIn(), fallback: false);
    final user = isLoggedIn
        ? await unwrapFutureResult(_getCurrentUser(), fallback: null)
        : null;
    final addresses = isLoggedIn
        ? await unwrapFutureResult(
            _getAddresses(),
            fallback: const <AddressEntity>[],
          )
        : const <AddressEntity>[];
    defaultAddress = addresses.isEmpty
        ? null
        : addresses.firstWhere(
            (address) => address.isDefault,
            orElse: () => addresses.first,
          );
    hasAddress = defaultAddress != null;
    hasItems = _cartController.items.isNotEmpty;

    customerInfo = CheckoutCustomerInfo(
      email: user?.email?.trim() ?? '',
      addressLine: defaultAddress?.street ?? '',
      city: defaultAddress?.city ?? '',
      country: defaultAddress?.country ?? '',
    );
  }
}

CheckoutController createCheckoutController() {
  configureDependencies();
  return sl<CheckoutController>();
}
