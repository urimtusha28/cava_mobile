import '../../../../core/state/wishlist_state_notifier.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._dataSource) {
    WishlistStateNotifier.update(_dataSource.getCount());
  }

  final WishlistDataSource _dataSource;

  void _notifyChange() {
    WishlistStateNotifier.update(_dataSource.getCount());
  }

  @override
  List<ProductEntity> getItems() => _dataSource.getItems();

  @override
  int getCount() => _dataSource.getCount();

  @override
  bool isInWishlist(String productId) => _dataSource.isInWishlist(productId);

  @override
  void add(ProductEntity product) {
    _dataSource.add(product);
    _notifyChange();
  }

  @override
  void remove(String productId) {
    _dataSource.remove(productId);
    _notifyChange();
  }

  @override
  void toggle(ProductEntity product) {
    if (_dataSource.isInWishlist(product.id)) {
      _dataSource.remove(product.id);
    } else {
      _dataSource.add(product);
    }
    _notifyChange();
  }
}
