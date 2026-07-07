import '../entities/place_order_result_entity.dart';

class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.paymentMethod,
    required this.termsAccepted,
  });

  final String paymentMethod;
  final bool termsAccepted;
}

abstract class CheckoutRepository {
  Future<PlaceOrderResultEntity> placeOrder(PlaceOrderRequest request);
}
