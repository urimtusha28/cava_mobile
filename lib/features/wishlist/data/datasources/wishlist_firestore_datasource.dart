import '../../../products/domain/entities/product_entity.dart';
import 'wishlist_data_source.dart';

/// Firestore placeholder — not wired in Phase 5.
class WishlistFirestoreDataSource implements WishlistDataSource {
  const WishlistFirestoreDataSource();

  Never _todo() => throw UnimplementedError(
        'WishlistFirestoreDataSource is not implemented yet.',
      );

  @override
  List<ProductEntity> getItems() => _todo();

  @override
  int getCount() => _todo();

  @override
  bool isInWishlist(String productId) => _todo();

  @override
  void add(ProductEntity product) => _todo();

  @override
  void remove(String productId) => _todo();
}
