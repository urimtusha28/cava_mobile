import '../entities/order_entity.dart';
import '../entities/order_fulfillment_status.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getMyOrders();

  Future<OrderEntity?> getOrderById(String orderId);

  Future<OrderEntity?> getOrderByIdForAdmin(String orderId);

  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatusDetail newStatus, {
    String? adminUid,
  });
}
