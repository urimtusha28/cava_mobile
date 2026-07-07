import '../../domain/entities/cart_item_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import 'cart_data_source.dart';

/// Firestore placeholder — not wired in Phase 5.
class CartFirestoreDataSource implements CartDataSource {
  const CartFirestoreDataSource();

  Never _todo() => throw UnimplementedError(
        'CartFirestoreDataSource is not implemented yet.',
      );

  @override
  List<CartItemEntity> getItems() => _todo();

  @override
  int getItemCount() => _todo();

  @override
  double getSubtotal() => _todo();

  @override
  double getDiscount() => _todo();

  @override
  double getVat() => _todo();

  @override
  double getShipping() => _todo();

  @override
  double getTotal() => _todo();

  @override
  void addProduct(ProductEntity product) => _todo();

  @override
  void updateQuantity(int index, int quantity) => _todo();

  @override
  void removeAt(int index) => _todo();

  @override
  void clear() => _todo();

  @override
  Future<void> loadPersistedCart() async => _todo();
}
