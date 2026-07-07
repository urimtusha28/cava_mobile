class OrderTotalsEntity {
  const OrderTotalsEntity({
    required this.total,
    this.subtotal,
    this.discount,
    this.shipping,
    this.vat,
  });

  final double? subtotal;
  final double? discount;
  final double? shipping;
  final double? vat;
  final double total;
}
