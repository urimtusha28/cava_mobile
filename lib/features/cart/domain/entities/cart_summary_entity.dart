import '../entities/cart_item_entity.dart';

class CartSummaryEntity {
  const CartSummaryEntity({
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.vat,
    required this.shipping,
    required this.total,
  });

  final List<CartItemEntity> items;
  final int itemCount;
  final double subtotal;
  final double discount;
  final double vat;
  final double shipping;
  final double total;
}
