import '../../../products/domain/entities/product_entity.dart';

class CartItemEntity {
  const CartItemEntity({
    required this.product,
    required this.quantity,
  });

  final ProductEntity product;
  final int quantity;

  double get lineTotal => product.price * quantity;
}
