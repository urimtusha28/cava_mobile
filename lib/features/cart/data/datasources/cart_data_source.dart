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

  Future<void> addProduct(ProductEntity product, {int quantity = 1});

  Future<void> updateQuantity(int index, int quantity);

  Future<void> removeAt(int index);

  Future<void> clear();

  /// Loads guest cart lines from local storage and hydrates products.
  Future<void> loadPersistedCart();
}
