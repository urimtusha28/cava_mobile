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
import '../../data/local/checkout_selected_address_storage.dart';
import '../../data/utils/place_order_exception_mapper.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/usecases/place_order.dart';
import '../../domain/utils/checkout_address_resolver.dart';
import '../models/checkout_session_state.dart';

class CheckoutController extends BaseController {
  CheckoutController(
    this._cartController,
    this._placeOrder,
    this._clearCart,
    this._isLoggedIn,
    this._getAddresses,
    this._getCurrentUser,
    this._selectedAddressStorage,
  ) {
    _cartController.addListener(notifyListeners);
  }

  final CartController _cartController;
  final PlaceOrderUseCase _placeOrder;
  final ClearCartUseCase _clearCart;
  final IsLoggedInUseCase _isLoggedIn;
  final GetAddressesUseCase _getAddresses;
  final GetCurrentUserUseCase _getCurrentUser;
  final CheckoutSelectedAddressStorage _selectedAddressStorage;

  bool isSubmitting = false;
  bool isLoggedIn = false;
  bool hasItems = false;
  List<AddressEntity> addresses = const [];
  AddressEntity? selectedAddress;
  CheckoutCustomerInfo customerInfo = CheckoutCustomerInfo.empty;

  bool get hasAddresses => addresses.isNotEmpty;
  bool get hasSelectedAddress => selectedAddress != null;

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

  Future<void> refreshAddresses() async {
    await _refreshSession();
    notifyListeners();
  }

  Future<void> selectAddress(AddressEntity address) async {
    selectedAddress = address;
    await _selectedAddressStorage.writeAddressId(address.id);
    _syncCustomerInfo();
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
          addressId: selectedAddress!.id,
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
    if (!hasAddresses || selectedAddress == null) {
      return 'Shto ose zgjidh një adresë.';
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
    addresses = isLoggedIn
        ? await unwrapFutureResult(
            _getAddresses(),
            fallback: const <AddressEntity>[],
          )
        : const <AddressEntity>[];

    final persistedId = await _selectedAddressStorage.readAddressId();
    selectedAddress = CheckoutAddressResolver.resolve(
      addresses: addresses,
      persistedAddressId: persistedId,
    );

    if (selectedAddress != null &&
        persistedId != null &&
        selectedAddress!.id != persistedId) {
      await _selectedAddressStorage.writeAddressId(selectedAddress!.id);
    }

    hasItems = _cartController.items.isNotEmpty;
    _syncCustomerInfo(userEmail: user?.email?.trim() ?? '');
  }

  void _syncCustomerInfo({String? userEmail}) {
    final address = selectedAddress;
    customerInfo = CheckoutCustomerInfo(
      email: userEmail ?? customerInfo.email,
      label: address?.label ?? '',
      fullName: address?.fullName ?? '',
      phone: address?.phone ?? '',
      addressLine: address?.street ?? '',
      city: address?.city ?? '',
      country: address?.country ?? '',
      zip: address?.zip ?? '',
    );
  }
}

CheckoutController createCheckoutController() {
  configureDependencies();
  return sl<CheckoutController>();
}
