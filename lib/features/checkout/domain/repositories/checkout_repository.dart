import '../entities/guest_checkout_customer.dart';
import '../entities/place_order_result_entity.dart';

enum PlaceOrderCustomerType { user, guest }

class PlaceOrderRequest {
  const PlaceOrderRequest.user({
    required this.paymentMethod,
    required this.termsAccepted,
    required this.addressId,
  })  : customerType = PlaceOrderCustomerType.user,
        guestCustomer = null;

  const PlaceOrderRequest.guest({
    required this.paymentMethod,
    required this.termsAccepted,
    required this.guestCustomer,
  })  : customerType = PlaceOrderCustomerType.guest,
        addressId = null;

  /// Backward-compatible constructor (logged-in user + address).
  const PlaceOrderRequest({
    required this.paymentMethod,
    required this.termsAccepted,
    required this.addressId,
  })  : customerType = PlaceOrderCustomerType.user,
        guestCustomer = null;

  final PlaceOrderCustomerType customerType;
  final String paymentMethod;
  final bool termsAccepted;
  final String? addressId;
  final GuestCheckoutCustomer? guestCustomer;
}

abstract class CheckoutRepository {
  Future<PlaceOrderResultEntity> placeOrder(PlaceOrderRequest request);
}
