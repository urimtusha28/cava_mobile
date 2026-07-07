import '../../../../core/state/wishlist_state_notifier.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._dataSource);

  final WishlistDataSource _dataSource;

  void _notifyChange() {
    WishlistStateNotifier.update(_dataSource.getCount());
  }

  @override
  Future<List<ProductEntity>> getItems() => Future.sync(() {
        _notifyChange();
        return _dataSource.getItems();
      });

  @override
  Future<int> getCount() => Future.sync(_dataSource.getCount);

  @override
  Future<bool> isInWishlist(String productId) =>
      Future.sync(() => _dataSource.isInWishlist(productId));

  @override
  Future<void> add(ProductEntity product) => Future.sync(() {
        _dataSource.add(product);
        _notifyChange();
      });

  @override
  Future<void> remove(String productId) => Future.sync(() {
        _dataSource.remove(productId);
        _notifyChange();
      });

  @override
  Future<void> toggle(ProductEntity product) => Future.sync(() {
        if (_dataSource.isInWishlist(product.id)) {
          _dataSource.remove(product.id);
        } else {
          _dataSource.add(product);
        }
        _notifyChange();
      });
}
