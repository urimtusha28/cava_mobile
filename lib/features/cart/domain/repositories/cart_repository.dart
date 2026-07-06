import '../../../products/domain/entities/product_entity.dart';
import '../entities/cart_item_entity.dart';
import '../entities/cart_summary_entity.dart';

abstract class CartRepository {
  Future<CartSummaryEntity> getSummary();

  Future<List<CartItemEntity>> getItems();

  Future<int> getItemCount();

  Future<double> getSubtotal();

  Future<double> getDiscount();

  Future<double> getVat();

  Future<double> getShipping();

  Future<double> getTotal();

  Future<void> addProduct(ProductEntity product);

  Future<void> updateQuantity(int index, int quantity);

  Future<void> removeAt(int index);

  Future<void> clear();
}
