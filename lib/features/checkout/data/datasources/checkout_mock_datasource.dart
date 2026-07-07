import '../../domain/entities/place_order_result_entity.dart';
import 'checkout_data_source.dart';

class CheckoutMockDataSource implements CheckoutDataSource {
  CheckoutMockDataSource({
    this.onPlaceOrder,
    this.result = const PlaceOrderResultEntity(
      orderId: 'order-1',
      orderNumber: 'CP-1001',
      total: 57,
      paymentMethod: 'cash',
    ),
  });

  final PlaceOrderResultEntity result;
  final Future<PlaceOrderResultEntity> Function(Map<String, dynamic> payload)?
      onPlaceOrder;

  Map<String, dynamic>? lastPayload;

  @override
  Future<PlaceOrderResultEntity> placeOrder(Map<String, dynamic> payload) async {
    lastPayload = payload;
    if (onPlaceOrder != null) {
      return onPlaceOrder!(payload);
    }
    return result;
  }
}
