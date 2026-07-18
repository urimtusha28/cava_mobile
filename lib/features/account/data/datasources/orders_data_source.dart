import '../models/order_model.dart';
import '../../domain/entities/order_fulfillment_status.dart';

abstract class OrdersDataSource {
  Future<List<OrderModel>> getMyOrders(String userId);

  Future<OrderModel?> getOrderById(String userId, String orderId);

  Future<OrderModel?> getOrderByIdForAdmin(String orderId);

  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatusDetail newStatus, {
    String? adminUid,
  });
}
