class OrderItemEntity {
  const OrderItemEntity({
    required this.name,
    required this.quantity,
    required this.price,
    required this.lineTotal,
  });

  final String name;
  final int quantity;
  final double price;
  final double lineTotal;
}
