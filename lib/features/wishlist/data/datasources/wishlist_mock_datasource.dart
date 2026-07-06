import '../../../products/domain/entities/product_entity.dart';
import '../mock/mock_wishlist.dart';
import 'wishlist_data_source.dart';

class WishlistMockDataSource implements WishlistDataSource {
  const WishlistMockDataSource();

  @override
  List<ProductEntity> getItems() =>
      List<ProductEntity>.from(MockWishlist.items);

  @override
  int getCount() => MockWishlist.count;

  @override
  bool isInWishlist(String productId) =>
      MockWishlist.items.any((product) => product.id == productId);

  @override
  void add(ProductEntity product) {
    if (!isInWishlist(product.id)) {
      MockWishlist.items.add(product);
      MockWishlist.revision.value = MockWishlist.items.length;
    }
  }

  @override
  void remove(String productId) => MockWishlist.remove(productId);
}
