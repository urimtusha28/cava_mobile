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
  Future<CartSummaryEntity> getSummary() => Future.sync(() {
        _notifyChange();
        return CartSummaryEntity(
          items: _dataSource.getItems(),
          itemCount: _dataSource.getItemCount(),
          subtotal: _dataSource.getSubtotal(),
          discount: _dataSource.getDiscount(),
          vat: _dataSource.getVat(),
          shipping: _dataSource.getShipping(),
          total: _dataSource.getTotal(),
        );
      });

  @override
  Future<List<CartItemEntity>> getItems() =>
      Future.sync(_dataSource.getItems);

  @override
  Future<int> getItemCount() => Future.sync(_dataSource.getItemCount);

  @override
  Future<double> getSubtotal() => Future.sync(_dataSource.getSubtotal);

  @override
  Future<double> getDiscount() => Future.sync(_dataSource.getDiscount);

  @override
  Future<double> getVat() => Future.sync(_dataSource.getVat);

  @override
  Future<double> getShipping() => Future.sync(_dataSource.getShipping);

  @override
  Future<double> getTotal() => Future.sync(_dataSource.getTotal);

  @override
  Future<void> addProduct(ProductEntity product) => Future.sync(() {
        _dataSource.addProduct(product);
        _notifyChange();
      });

  @override
  Future<void> updateQuantity(int index, int quantity) => Future.sync(() {
        _dataSource.updateQuantity(index, quantity);
        _notifyChange();
      });

  @override
  Future<void> removeAt(int index) => Future.sync(() {
        _dataSource.removeAt(index);
        _notifyChange();
      });

  @override
  Future<void> clear() => Future.sync(() {
        _dataSource.clear();
        _notifyChange();
      });
}
