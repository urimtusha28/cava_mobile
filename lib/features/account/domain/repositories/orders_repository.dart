import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getMyOrders();
}
