import '../../../products/domain/entities/product_entity.dart';

abstract class WishlistDataSource {
  Future<List<ProductEntity>> getItems();

  Future<int> getCount();

  Future<bool> isInWishlist(String productId);

  Future<void> add(ProductEntity product);

  Future<void> remove(String productId);

  Future<void> toggle(ProductEntity product);
}
