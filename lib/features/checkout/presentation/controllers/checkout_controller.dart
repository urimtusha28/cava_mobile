import 'package:flutter/foundation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../account/domain/entities/address_entity.dart';
import '../../../account/domain/entities/auth_user_entity.dart';
import '../../../account/domain/usecases/address_usecases.dart';
import '../../../account/domain/usecases/get_current_user.dart';
import '../../../cart/domain/usecases/clear_cart.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/local/checkout_selected_address_storage.dart';
import '../../data/local/guest_checkout_customer_storage.dart';
import '../../data/utils/place_order_exception_mapper.dart';
import '../../domain/entities/guest_checkout_customer.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/usecases/place_order.dart';
import '../../domain/utils/checkout_address_resolver.dart';
import '../../domain/utils/guest_checkout_form_validator.dart';
import '../models/checkout_session_state.dart';

class CheckoutController extends BaseController {
  CheckoutController(
    this._cartController,
    this._placeOrder,
    this._clearCart,
    this._getAddresses,
    this._getCurrentUser,
    this._selectedAddressStorage,
    this._guestCustomerStorage,
  ) {
    _cartController.addListener(notifyListeners);
  }

  final CartController _cartController;
  final PlaceOrderUseCase _placeOrder;
  final ClearCartUseCase _clearCart;
  final GetAddressesUseCase _getAddresses;
  final GetCurrentUserUseCase _getCurrentUser;
  final CheckoutSelectedAddressStorage _selectedAddressStorage;
  final GuestCheckoutCustomerStorage _guestCustomerStorage;

  bool isSubmitting = false;
  bool isLoggedIn = false;
  bool hasItems = false;
  List<AddressEntity> addresses = const [];
  AddressEntity? selectedAddress;
  GuestCheckoutCustomer? guestCustomer;
  CheckoutCustomerInfo customerInfo = CheckoutCustomerInfo.empty;

  bool get hasAddresses => addresses.isNotEmpty;
  bool get hasSelectedAddress => selectedAddress != null;
  bool get hasGuestCustomer => guestCustomer?.isComplete == true;

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
    _syncCustomerInfoFromAddress();
    notifyListeners();
  }

  Future<void> saveGuestCustomer(GuestCheckoutCustomer customer) async {
    guestCustomer = customer;
    await _guestCustomerStorage.write(customer);
    _syncCustomerInfoFromGuest();
    notifyListeners();
  }

  Future<CheckoutSubmitResult> submitOrder({
    required String paymentMethod,
    required bool termsAccepted,
  }) async {
    // Live FirebaseAuth.currentUser via AuthRepository — same source as load.
    final authUser = await _refreshAuthForSubmit();

    final validation = _validateBeforeSubmit(
      termsAccepted: termsAccepted,
      authUser: authUser,
    );
    if (validation != null) {
      debugPrint(
        '[Checkout] submit validation: $validation '
        '(loggedIn=$isLoggedIn addressId=${selectedAddress?.id} '
        'payment=$paymentMethod terms=$termsAccepted '
        'items=${_cartController.items.length})',
      );
      return CheckoutSubmitResult.validationError(validation);
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final PlaceOrderRequest request;
      if (authUser != null) {
        request = PlaceOrderRequest.user(
          paymentMethod: paymentMethod,
          termsAccepted: termsAccepted,
          addressId: selectedAddress!.id,
        );
      } else {
        request = PlaceOrderRequest.guest(
          paymentMethod: paymentMethod,
          termsAccepted: termsAccepted,
          guestCustomer: guestCustomer!,
        );
      }

      debugPrint(
        '[Checkout] placeOrder start '
        'uid=${authUser?.uid} email=${authUser?.email} '
        'customerType=${authUser != null ? 'user' : 'guest'} '
        'addressId=${selectedAddress?.id} payment=$paymentMethod '
        'terms=$termsAccepted items=${_cartController.items.length}',
      );

      final result = await _placeOrder(request);

      if (result.isFailure) {
        final failure = result.failureOrNull!;
        debugPrint(
          '[Checkout] placeOrder failure code=${failure.code} '
          'message=${failure.message}',
        );
        return CheckoutSubmitResult.requestError(_mapFailure(failure));
      }

      final order = result.dataOrNull!;
      await unwrapFutureResult(_clearCart(), fallback: null);
      await _cartController.load();
      debugPrint('[Checkout] placeOrder success orderId=${order.orderId}');
      return CheckoutSubmitResult.success(order);
    } catch (error) {
      debugPrint('[Checkout] placeOrder exception: $error');
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

  String? _validateBeforeSubmit({
    required bool termsAccepted,
    required AuthUserEntity? authUser,
  }) {
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

    if (authUser != null) {
      if (!hasAddresses || selectedAddress == null) {
        return 'Shto ose zgjidh një adresë.';
      }
      // UID present means authenticated — never ask to login again.
      return null;
    }

    return GuestCheckoutFormValidator.validateCustomer(guestCustomer);
  }

  String _mapFailure(Failure failure) {
    return PlaceOrderExceptionMapper.toUserMessage(failure);
  }

  /// Returns live auth user from [GetCurrentUserUseCase]
  /// (`AuthRepository` → `FirebaseAuth.currentUser`).
  Future<AuthUserEntity?> _refreshAuthForSubmit() async {
    final user = await unwrapFutureResult(_getCurrentUser(), fallback: null);
    isLoggedIn = user != null;
    if (user != null) {
      _syncCustomerInfoFromAddress(userEmail: user.email?.trim() ?? '');
    }
    hasItems = _cartController.items.isNotEmpty;
    notifyListeners();
    return user;
  }

  Future<void> _refreshSession() async {
    // Prefer getCurrentUser over a separate isLoggedIn call so load and submit
    // share one AuthRepository snapshot of FirebaseAuth.currentUser.
    final user = await unwrapFutureResult(_getCurrentUser(), fallback: null);
    isLoggedIn = user != null;

    if (isLoggedIn) {
      addresses = await unwrapFutureResult(
        _getAddresses(),
        fallback: const <AddressEntity>[],
      );

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
      _syncCustomerInfoFromAddress(userEmail: user?.email?.trim() ?? '');
      return;
    }

    addresses = const [];
    selectedAddress = null;
    guestCustomer = await _guestCustomerStorage.read();
    hasItems = _cartController.items.isNotEmpty;
    if (guestCustomer != null) {
      _syncCustomerInfoFromGuest();
    } else {
      customerInfo = CheckoutCustomerInfo.empty;
    }
  }

  void _syncCustomerInfoFromAddress({String? userEmail}) {
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

  void _syncCustomerInfoFromGuest() {
    final guest = guestCustomer;
    if (guest == null) {
      customerInfo = CheckoutCustomerInfo.empty;
      return;
    }
    customerInfo = CheckoutCustomerInfo(
      email: guest.email,
      label: '',
      fullName: guest.fullName,
      phone: guest.phone,
      addressLine: guest.address,
      city: guest.city,
      country: guest.country,
      zip: guest.zip,
    );
  }
}

CheckoutController createCheckoutController() {
  configureDependencies();
  return sl<CheckoutController>();
}
