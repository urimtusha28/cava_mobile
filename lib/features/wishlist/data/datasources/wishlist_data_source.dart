import '../../../products/domain/entities/product_entity.dart';

abstract class WishlistDataSource {
  List<ProductEntity> getItems();

  int getCount();

  bool isInWishlist(String productId);

  void add(ProductEntity product);

  void remove(String productId);
}
