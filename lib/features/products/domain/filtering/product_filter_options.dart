import '../entities/product_entity.dart';

/// Facet values derived from a product list — never hardcoded.
class ProductFilterOptions {
  const ProductFilterOptions({
    required this.brands,
    required this.countries,
    required this.categories,
    required this.subcategories,
    required this.volumes,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<String> brands;
  final List<String> countries;
  final List<String> categories;
  final List<String> subcategories;
  final List<String> volumes;
  final double minPrice;
  final double maxPrice;

  static const ProductFilterOptions empty = ProductFilterOptions(
    brands: [],
    countries: [],
    categories: [],
    subcategories: [],
    volumes: [],
    minPrice: 0,
    maxPrice: 0,
  );

  factory ProductFilterOptions.fromProducts(List<ProductEntity> products) {
    if (products.isEmpty) {
      return ProductFilterOptions.empty;
    }

    final brands = <String>{};
    final countries = <String>{};
    final categories = <String>{};
    final subcategories = <String>{};
    final volumes = <String>{};
    var min = products.first.price;
    var max = products.first.price;

    for (final product in products) {
      final brand = product.brand.trim();
      if (brand.isNotEmpty) brands.add(brand);

      final country = product.country?.trim();
      if (country != null && country.isNotEmpty) countries.add(country);

      final category = product.categoryName.trim();
      if (category.isNotEmpty) categories.add(category);

      final type = product.type.trim();
      if (type.isNotEmpty) subcategories.add(type);

      final volume = product.volume.trim();
      if (volume.isNotEmpty) volumes.add(volume);

      if (product.price < min) min = product.price;
      if (product.price > max) max = product.price;
    }

    List<String> sorted(Set<String> values) =>
        values.toList(growable: false)..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ProductFilterOptions(
      brands: sorted(brands),
      countries: sorted(countries),
      categories: sorted(categories),
      subcategories: sorted(subcategories),
      volumes: sorted(volumes),
      minPrice: min,
      maxPrice: max,
    );
  }
}
