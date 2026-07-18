import '../models/order_model.dart';
import '../../domain/entities/order_fulfillment_status.dart';
import 'orders_data_source.dart';

class OrdersMockDataSource implements OrdersDataSource {
  const OrdersMockDataSource();

  @override
  Future<List<OrderModel>> getMyOrders(String userId) async => const [];

  @override
  Future<OrderModel?> getOrderById(String userId, String orderId) async =>
      null;

  @override
  Future<OrderModel?> getOrderByIdForAdmin(String orderId) async => null;

  @override
  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatusDetail newStatus, {
    String? adminUid,
  }) async {}
}
