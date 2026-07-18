import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_fulfillment_status.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._dataSource, this._authRepository);

  final OrdersDataSource _dataSource;
  final AuthRepository _authRepository;

  @override
  Future<List<OrderEntity>> getMyOrders() async {
    final userId = await _authRepository.getCurrentUserId();
    if (userId == null) {
      return const [];
    }

    final orders = await _dataSource.getMyOrders(userId);
    return orders.map((order) => order.toEntity()).toList(growable: false);
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    final userId = await _authRepository.getCurrentUserId();
    if (userId == null) {
      return null;
    }

    final order = await _dataSource.getOrderById(userId, orderId);
    return order?.toEntity();
  }

  @override
  Future<OrderEntity?> getOrderByIdForAdmin(String orderId) async {
    final order = await _dataSource.getOrderByIdForAdmin(orderId);
    return order?.toEntity();
  }

  @override
  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatusDetail newStatus, {
    String? adminUid,
  }) {
    return _dataSource.updateOrderFulfillmentStatus(
      orderId,
      newStatus,
      adminUid: adminUid,
    );
  }
}
