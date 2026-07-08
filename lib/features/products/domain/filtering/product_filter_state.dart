import 'product_sort_option.dart';

class ProductFilterState {
  const ProductFilterState({
    this.minPrice,
    this.maxPrice,
    this.brands = const {},
    this.countries = const {},
    this.categories = const {},
    this.subcategories = const {},
    this.volumes = const {},
    this.inStockOnly = false,
    this.sortOption = ProductSortOption.recommended,
  });

  final double? minPrice;
  final double? maxPrice;
  final Set<String> brands;
  final Set<String> countries;
  final Set<String> categories;
  final Set<String> subcategories;
  final Set<String> volumes;
  final bool inStockOnly;
  final ProductSortOption sortOption;

  static const ProductFilterState empty = ProductFilterState();

  bool get isActive =>
      minPrice != null ||
      maxPrice != null ||
      brands.isNotEmpty ||
      countries.isNotEmpty ||
      categories.isNotEmpty ||
      subcategories.isNotEmpty ||
      volumes.isNotEmpty ||
      inStockOnly ||
      sortOption != ProductSortOption.recommended;

  /// Count of active filter dimensions (sort excluded unless non-default).
  int get activeCount {
    var count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (brands.isNotEmpty) count++;
    if (countries.isNotEmpty) count++;
    if (categories.isNotEmpty) count++;
    if (subcategories.isNotEmpty) count++;
    if (volumes.isNotEmpty) count++;
    if (inStockOnly) count++;
    if (sortOption != ProductSortOption.recommended) count++;
    return count;
  }

  ProductFilterState copyWith({
    double? minPrice,
    double? maxPrice,
    Set<String>? brands,
    Set<String>? countries,
    Set<String>? categories,
    Set<String>? subcategories,
    Set<String>? volumes,
    bool? inStockOnly,
    ProductSortOption? sortOption,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ProductFilterState(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      brands: brands ?? this.brands,
      countries: countries ?? this.countries,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      volumes: volumes ?? this.volumes,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  ProductFilterState reset() => ProductFilterState.empty;
}
