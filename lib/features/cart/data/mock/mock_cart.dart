import 'package:flutter/foundation.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../../products/data/mock/mock_products.dart';
import '../../../products/domain/entities/product_entity.dart';

abstract final class MockCart {
  static List<CartItemEntity> items = [
    CartItemEntity(product: MockProducts.products[1], quantity: 2),
    CartItemEntity(product: MockProducts.products[4], quantity: 1),
    CartItemEntity(product: MockProducts.products[12], quantity: 1),
  ];

  static final ValueNotifier<int> revision = ValueNotifier(itemCount);

  static int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  static double get subtotal =>
      items.fold(0, (sum, i) => sum + i.lineTotal);

  static const double discount = 0;

  static const double vat = 0;

  static const double shipping = 0;

  static double get total => subtotal + vat + shipping;

  static void _notify() => revision.value = itemCount;

  static void addProduct(ProductEntity product, {int quantity = 1}) {
    if (quantity <= 0) {
      return;
    }

    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final item = items[index];
      items[index] = CartItemEntity(
        product: item.product,
        quantity: item.quantity + quantity,
      );
    } else {
      items.add(CartItemEntity(product: product, quantity: quantity));
    }
    _notify();
  }

  static void updateQuantity(int index, int quantity) {
    items[index] = CartItemEntity(
      product: items[index].product,
      quantity: quantity,
    );
    _notify();
  }

  static void removeAt(int index) {
    items.removeAt(index);
    _notify();
  }
}
