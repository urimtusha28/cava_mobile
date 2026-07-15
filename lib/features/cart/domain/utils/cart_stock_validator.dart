import '../../../products/domain/entities/product_entity.dart';
import '../entities/cart_item_entity.dart';

/// Domain rules for cart quantities vs available product stock.
abstract final class CartStockValidator {
  static const insufficientStockMessage = 'Nuk ka stok të mjaftueshëm.';
  static const outOfStockMessage = 'Produkti nuk është në stok.';
  static const unavailableMessage =
      'Një produkt nuk është më në dispozicion ose nuk ka stok të mjaftueshëm.';

  /// Validates adding [quantity] of [product] when [quantityAlreadyInCart]
  /// units are already in the cart.
  ///
  /// Returns an error message, or `null` when the add is allowed.
  static String? validateAdd({
    required ProductEntity product,
    required int quantity,
    int quantityAlreadyInCart = 0,
  }) {
    if (quantity <= 0) {
      return insufficientStockMessage;
    }
    if (product.stock <= 0 || !product.inStock) {
      return outOfStockMessage;
    }
    if (quantityAlreadyInCart + quantity > product.stock) {
      return insufficientStockMessage;
    }
    return null;
  }

  /// Validates setting cart line quantity to [quantity] for [product].
  static String? validateSetQuantity({
    required ProductEntity product,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return null; // treat as remove — handled by repository
    }
    if (product.stock <= 0 || !product.inStock) {
      return outOfStockMessage;
    }
    if (quantity > product.stock) {
      return insufficientStockMessage;
    }
    return null;
  }

  /// Validates all cart lines against each product's current [ProductEntity.stock].
  static String? validateCartItems(List<CartItemEntity> items) {
    for (final item in items) {
      if (item.product.stock <= 0 || !item.product.inStock) {
        return unavailableMessage;
      }
      if (item.quantity > item.product.stock) {
        return unavailableMessage;
      }
    }
    return null;
  }

  static int quantityInCartForProduct(
    List<CartItemEntity> items,
    String productId,
  ) {
    var total = 0;
    for (final item in items) {
      if (item.product.id == productId) {
        total += item.quantity;
      }
    }
    return total;
  }
}
