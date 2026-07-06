import '../../../../core/state/cart_state_notifier.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._dataSource) {
    CartStateNotifier.update(_dataSource.getItemCount());
  }

  final CartDataSource _dataSource;

  void _notifyChange() {
    CartStateNotifier.update(_dataSource.getItemCount());
  }

  @override
  List<CartItemEntity> getItems() => _dataSource.getItems();

  @override
  int getItemCount() => _dataSource.getItemCount();

  @override
  double getSubtotal() => _dataSource.getSubtotal();

  @override
  double getDiscount() => _dataSource.getDiscount();

  @override
  double getVat() => _dataSource.getVat();

  @override
  double getShipping() => _dataSource.getShipping();

  @override
  double getTotal() => _dataSource.getTotal();

  @override
  void addProduct(ProductEntity product) {
    _dataSource.addProduct(product);
    _notifyChange();
  }

  @override
  void updateQuantity(int index, int quantity) {
    _dataSource.updateQuantity(index, quantity);
    _notifyChange();
  }

  @override
  void removeAt(int index) {
    _dataSource.removeAt(index);
    _notifyChange();
  }

  @override
  void clear() {
    _dataSource.clear();
    _notifyChange();
  }
}
