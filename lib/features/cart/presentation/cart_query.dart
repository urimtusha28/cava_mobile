import 'package:flutter/foundation.dart';

import '../../../core/di/injection.dart';
import '../../../core/result/result.dart';
import '../../../core/state/cart_state_notifier.dart';
import '../../products/domain/entities/product_entity.dart';
import '../domain/entities/cart_item_entity.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/usecases/add_to_cart.dart';
import '../domain/usecases/get_cart_items.dart';
import '../domain/usecases/remove_from_cart.dart';
import '../domain/usecases/update_cart_quantity.dart';
import 'cart_module.dart';

abstract final class CartQuery {
  static ValueNotifier<int> get revision => CartStateNotifier.revision;

  static List<CartItemEntity> getItems() {
    CartModule.ensureInitialized();
    return _unwrapItems(sl<GetCartItemsUseCase>().call());
  }

  static int get itemCount {
    CartModule.ensureInitialized();
    return sl<CartRepository>().getItemCount();
  }

  static double get subtotal {
    CartModule.ensureInitialized();
    return sl<CartRepository>().getSubtotal();
  }

  static double get discount {
    CartModule.ensureInitialized();
    return sl<CartRepository>().getDiscount();
  }

  static double get vat {
    CartModule.ensureInitialized();
    return sl<CartRepository>().getVat();
  }

  static double get shipping {
    CartModule.ensureInitialized();
    return sl<CartRepository>().getShipping();
  }

  static double get total {
    CartModule.ensureInitialized();
    return sl<CartRepository>().getTotal();
  }

  static void addProduct(ProductEntity product) {
    CartModule.ensureInitialized();
    sl<AddToCartUseCase>().call(product);
  }

  static void updateQuantity(int index, int quantity) {
    CartModule.ensureInitialized();
    sl<UpdateCartQuantityUseCase>().call(
      UpdateCartQuantityParams(index: index, quantity: quantity),
    );
  }

  static void removeAt(int index) {
    CartModule.ensureInitialized();
    sl<RemoveFromCartUseCase>().call(index);
  }

  static List<CartItemEntity> _unwrapItems(Result<List<CartItemEntity>> result) {
    return result.fold(
      onSuccess: (data) => data,
      onFailure: (_) => const [],
    );
  }
}
