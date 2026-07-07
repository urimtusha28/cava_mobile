import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartDataSource {
  List<CartItemEntity> getItems();

  int getItemCount();

  double getSubtotal();

  double getDiscount();

  double getVat();

  double getShipping();

  double getTotal();

  void addProduct(ProductEntity product);

  void updateQuantity(int index, int quantity);

  void removeAt(int index);

  void clear();

  /// Loads guest cart lines from local storage and hydrates products.
  Future<void> loadPersistedCart();
}
