import '../../../products/domain/entities/product_entity.dart';
import '../local/local_wishlist_store.dart';
import 'wishlist_data_source.dart';

/// Guest/local wishlist backed by in-memory store until Auth + Firestore sync.
class WishlistLocalDataSource implements WishlistDataSource {
  const WishlistLocalDataSource();

  @override
  List<ProductEntity> getItems() => LocalWishlistStore.snapshot();

  @override
  int getCount() => LocalWishlistStore.count;

  @override
  bool isInWishlist(String productId) => LocalWishlistStore.contains(productId);

  @override
  void add(ProductEntity product) => LocalWishlistStore.add(product);

  @override
  void remove(String productId) => LocalWishlistStore.remove(productId);
}
