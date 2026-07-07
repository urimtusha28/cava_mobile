import '../../../products/domain/entities/product_entity.dart';

/// In-memory guest wishlist — real [ProductEntity] items only, no mock seed data.
abstract final class LocalWishlistStore {
  static final List<ProductEntity> _items = <ProductEntity>[];

  static List<ProductEntity> snapshot() =>
      List<ProductEntity>.unmodifiable(_items);

  static int get count => _items.length;

  static void clear() => _items.clear();

  static bool contains(String productId) =>
      _items.any((product) => product.id == productId);

  static void add(ProductEntity product) {
    if (contains(product.id)) {
      return;
    }
    _items.add(product);
  }

  static void remove(String productId) {
    _items.removeWhere((product) => product.id == productId);
  }
}
