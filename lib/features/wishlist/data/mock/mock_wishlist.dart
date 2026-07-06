import 'package:flutter/foundation.dart';

import '../../../products/data/mock/mock_products.dart';
import '../../../products/domain/entities/product_entity.dart';

abstract final class MockWishlist {
  static List<ProductEntity> items = MockProducts.products
      .where((p) => ['wine-001', 'wine-002', 'wine-003'].contains(p.id))
      .toList();

  static final ValueNotifier<int> revision = ValueNotifier(items.length);

  static int get count => items.length;

  static void remove(String productId) {
    items.removeWhere((p) => p.id == productId);
    revision.value = items.length;
  }
}
