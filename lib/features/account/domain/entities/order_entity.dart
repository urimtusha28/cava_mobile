import 'order_customer_entity.dart';
import 'order_item_entity.dart';
import 'order_totals_entity.dart';

class OrderEntity {
  const OrderEntity({
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

  String get displayOrderNumber {
    final number = orderNumber?.trim();
    if (number != null && number.isNotEmpty) {
      return number.startsWith('#') ? number : '#$number';
    }
    final suffix = id.length <= 6 ? id : id.substring(id.length - 6);
    return 'Porosia #$suffix';
  }
}
