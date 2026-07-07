import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/subcategory_filter.dart';

/// Resolves product detail category badge label and colors from cached categories.
abstract final class CategoryProductBadgeResolver {
  static SubcategoryEntity? findSubcategory(
    ProductEntity product,
    List<SubcategoryEntity> subcategories,
  ) {
    for (final sub in subcategories) {
      if (sub.id == 'all') continue;
      if (SubcategoryFilter.matches(product, sub)) {
        return sub;
      }
      if (product.type.isNotEmpty &&
          sub.label.toLowerCase() == product.type.toLowerCase()) {
        return sub;
      }
      if (product.type.isNotEmpty &&
          sub.id.toLowerCase() == product.type.toLowerCase()) {
        return sub;
      }
    }
    return null;
  }

  static String resolveLabel({
    required ProductEntity product,
    CategoryEntity? mainCategory,
    SubcategoryEntity? subcategory,
  }) {
    if (subcategory != null && subcategory.label.isNotEmpty) {
      return subcategory.label;
    }
    if (product.type.isNotEmpty) {
      return product.type;
    }
    if (mainCategory != null) {
      if (mainCategory.label.isNotEmpty) {
        return mainCategory.label;
      }
      if (mainCategory.name.isNotEmpty) {
        return mainCategory.name;
      }
    }
    return product.categoryName;
  }
}
