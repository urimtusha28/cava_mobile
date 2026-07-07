import '../models/order_model.dart';

abstract class OrdersDataSource {
  Future<List<OrderModel>> getMyOrders(String userId);

  Future<OrderModel?> getOrderById(String userId, String orderId);
}
