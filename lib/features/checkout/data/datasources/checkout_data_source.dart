import '../../domain/entities/place_order_result_entity.dart';

abstract class CheckoutDataSource {
  Future<PlaceOrderResultEntity> placeOrder(Map<String, dynamic> payload);
}
