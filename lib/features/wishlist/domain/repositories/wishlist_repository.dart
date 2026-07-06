import '../../../products/domain/entities/product_entity.dart';

abstract class WishlistRepository {
  List<ProductEntity> getItems();

  int getCount();

  bool isInWishlist(String productId);

  void add(ProductEntity product);

  void remove(String productId);

  void toggle(ProductEntity product);
}
