class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.itemCount,
    this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final double total;
  final int itemCount;
  final DateTime? createdAt;
}
