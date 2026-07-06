import '../../products/domain/entities/product_entity.dart';
import 'entities/subcategory_entity.dart';

abstract final class SubcategoryFilter {
  static bool matches(ProductEntity product, SubcategoryEntity subcategory) {
    if (subcategory.id == 'all') return true;

    if (subcategory.matchTypes.contains(product.type)) {
      return true;
    }

    final name = product.name.toLowerCase();
    for (final keyword in subcategory.matchKeywords) {
      if (name.contains(keyword.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  static bool matchesSearch(ProductEntity product, String query) {
    if (query.trim().isEmpty) return true;

    final normalized = query.trim().toLowerCase();
    return product.name.toLowerCase().contains(normalized) ||
        product.brand.toLowerCase().contains(normalized) ||
        product.type.toLowerCase().contains(normalized);
  }
}
