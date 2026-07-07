import '../models/order_model.dart';
import 'orders_data_source.dart';

class OrdersMockDataSource implements OrdersDataSource {
  const OrdersMockDataSource();

  @override
  Future<List<OrderModel>> getMyOrders(String userId) async => const [];
}
