import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../mock/mock_cart.dart';
import 'cart_data_source.dart';

class CartMockDataSource implements CartDataSource {
  const CartMockDataSource();

  @override
  List<CartItemEntity> getItems() => List<CartItemEntity>.from(MockCart.items);

  @override
  int getItemCount() => MockCart.itemCount;

  @override
  double getSubtotal() => MockCart.subtotal;

  @override
  double getDiscount() => MockCart.discount;

  @override
  double getVat() => MockCart.vat;

  @override
  double getShipping() => MockCart.shipping;

  @override
  double getTotal() => MockCart.total;

  @override
  void addProduct(ProductEntity product, {int quantity = 1}) =>
      MockCart.addProduct(product, quantity: quantity);

  @override
  void updateQuantity(int index, int quantity) =>
      MockCart.updateQuantity(index, quantity);

  @override
  void removeAt(int index) => MockCart.removeAt(index);

  @override
  void clear() {
    MockCart.items.clear();
    MockCart.revision.value = MockCart.itemCount;
  }

  @override
  Future<void> loadPersistedCart() async {}
}
