import '../entities/product_entity.dart';
import 'product_filter_state.dart';
import 'product_sort_option.dart';

/// Client-side filter + sort. No Firestore reads.
abstract final class ProductFilterEngine {
  static List<ProductEntity> apply({
    required List<ProductEntity> products,
    required ProductFilterState filter,
  }) {
    final filtered = products.where((product) => matches(product, filter)).toList();
    sortInPlace(filtered, filter.sortOption);
    return filtered;
  }

  static bool matches(ProductEntity product, ProductFilterState filter) {
    if (filter.inStockOnly && !product.inStock) {
      return false;
    }

    if (filter.minPrice != null && product.price < filter.minPrice!) {
      return false;
    }
    if (filter.maxPrice != null && product.price > filter.maxPrice!) {
      return false;
    }

    if (filter.brands.isNotEmpty &&
        !filter.brands.contains(product.brand.trim())) {
      return false;
    }

    if (filter.countries.isNotEmpty) {
      final country = product.country?.trim() ?? '';
      if (!filter.countries.contains(country)) {
        return false;
      }
    }

    if (filter.categories.isNotEmpty &&
        !filter.categories.contains(product.categoryName.trim())) {
      return false;
    }

    if (filter.subcategories.isNotEmpty &&
        !filter.subcategories.contains(product.type.trim())) {
      return false;
    }

    if (filter.volumes.isNotEmpty &&
        !filter.volumes.contains(product.volume.trim())) {
      return false;
    }

    return true;
  }

  static void sortInPlace(
    List<ProductEntity> products,
    ProductSortOption sortOption,
  ) {
    switch (sortOption) {
      case ProductSortOption.recommended:
        products.sort((a, b) {
          final featured = (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0);
          if (featured != 0) return featured;
          return b.rating.compareTo(a.rating);
        });
      case ProductSortOption.nameAsc:
        products.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case ProductSortOption.nameDesc:
        products.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
      case ProductSortOption.priceAsc:
        products.sort((a, b) => a.price.compareTo(b.price));
      case ProductSortOption.priceDesc:
        products.sort((a, b) => b.price.compareTo(a.price));
      case ProductSortOption.newest:
        // No createdAt on ProductEntity — use id descending as stable proxy.
        products.sort((a, b) => b.id.compareTo(a.id));
      case ProductSortOption.bestSellers:
        products.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }
  }
}
