import '../entities/place_order_result_entity.dart';

class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.paymentMethod,
    required this.termsAccepted,
    required this.addressId,
  });

  final String paymentMethod;
  final bool termsAccepted;
  final String addressId;
}

abstract class CheckoutRepository {
  Future<PlaceOrderResultEntity> placeOrder(PlaceOrderRequest request);
}
