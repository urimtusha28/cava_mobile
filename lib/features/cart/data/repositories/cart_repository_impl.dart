import '../../../../core/state/cart_state_notifier.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._dataSource);

  final CartDataSource _dataSource;

  void _notifyChange() {
    CartStateNotifier.update(_dataSource.getItemCount());
  }

  @override
  Future<void> hydrateFromStorage() async {
    await _dataSource.loadPersistedCart();
    _notifyChange();
  }

  @override
  Future<CartSummaryEntity> getSummary() async {
    await hydrateFromStorage();
    return CartSummaryEntity(
      items: _dataSource.getItems(),
      itemCount: _dataSource.getItemCount(),
      subtotal: _dataSource.getSubtotal(),
      discount: _dataSource.getDiscount(),
      vat: _dataSource.getVat(),
      shipping: _dataSource.getShipping(),
      total: _dataSource.getTotal(),
    );
  }

  @override
  Future<List<CartItemEntity>> getItems() async {
    await hydrateFromStorage();
    return _dataSource.getItems();
  }

  @override
  Future<int> getItemCount() async {
    await hydrateFromStorage();
    return _dataSource.getItemCount();
  }

  @override
  Future<double> getSubtotal() async {
    await hydrateFromStorage();
    return _dataSource.getSubtotal();
  }

  @override
  Future<double> getDiscount() async {
    await hydrateFromStorage();
    return _dataSource.getDiscount();
  }

  @override
  Future<double> getVat() async {
    await hydrateFromStorage();
    return _dataSource.getVat();
  }

  @override
  Future<double> getShipping() async {
    await hydrateFromStorage();
    return _dataSource.getShipping();
  }

  @override
  Future<double> getTotal() async {
    await hydrateFromStorage();
    return _dataSource.getTotal();
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    _dataSource.addProduct(product);
    _notifyChange();
  }

  @override
  Future<void> updateQuantity(int index, int quantity) async {
    _dataSource.updateQuantity(index, quantity);
    _notifyChange();
  }

  @override
  Future<void> removeAt(int index) async {
    _dataSource.removeAt(index);
    _notifyChange();
  }

  @override
  Future<void> clear() async {
    _dataSource.clear();
    _notifyChange();
  }
}
