import '../../domain/entities/order_customer_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/order_totals_entity.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    this.orderNumber,
    required this.status,
    this.fulfillmentStatus,
    this.paymentMethod,
    required this.paymentStatus,
    required this.total,
    required this.itemCount,
    this.createdAt,
    this.items = const [],
    this.totals,
    this.customer,
  });

  final String id;
  final String? orderNumber;
  final String status;
  final String? fulfillmentStatus;
  final String? paymentMethod;
  final String paymentStatus;
  final double total;
  final int itemCount;
  final DateTime? createdAt;
  final List<OrderItemEntity> items;
  final OrderTotalsEntity? totals;
  final OrderCustomerEntity? customer;

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      status: status,
      fulfillmentStatus: fulfillmentStatus,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      total: total,
      itemCount: itemCount,
      createdAt: createdAt,
      items: items,
      totals: totals,
      customer: customer,
    );
  }
}
