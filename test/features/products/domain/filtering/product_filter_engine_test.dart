import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/features/products/domain/filtering/product_filter_engine.dart';
import 'package:cava_ecommerce/features/products/domain/filtering/product_filter_options.dart';
import 'package:cava_ecommerce/features/products/domain/filtering/product_filter_state.dart';
import 'package:cava_ecommerce/features/products/domain/filtering/product_sort_option.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

const _p2 = ProductEntity(
  id: 'p2',
  name: 'Alpha Whiskey',
  brand: 'Highland',
  categoryId: 'spirits',
  categoryName: 'Spirits',
  price: 40,
  description: 'Aged whiskey',
  volume: '700ml',
  country: 'Scotland',
  type: 'Whiskey',
  rating: 4,
  reviewCount: 50,
  inStock: false,
  isFeatured: false,
);

const _p3 = ProductEntity(
  id: 'p3',
  name: 'Zeta Red',
  brand: 'Test Brand',
  categoryId: 'wines',
  categoryName: 'Wines',
  price: 10,
  description: 'Budget red',
  volume: '750ml',
  country: 'Italy',
  type: 'Red',
  rating: 3,
  reviewCount: 200,
  inStock: true,
  isFeatured: true,
);

void main() {
  final catalog = [testProductEntity, _p2, _p3];

  group('ProductFilterEngine', () {
    test('filters by price range', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: const ProductFilterState(minPrice: 20, maxPrice: 30),
      );
      expect(result.map((p) => p.id), ['p1']);
    });

    test('filters by brand', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: ProductFilterState(brands: {'Highland'}),
      );
      expect(result.map((p) => p.id), ['p2']);
    });

    test('filters by country', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: ProductFilterState(countries: {'Italy'}),
      );
      expect(result.map((p) => p.id), ['p3']);
    });

    test('filters by category', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: ProductFilterState(categories: {'Spirits'}),
      );
      expect(result.map((p) => p.id), ['p2']);
    });

    test('filters by subcategory/type', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: ProductFilterState(subcategories: {'Red'}),
      );
      expect(result.map((p) => p.id).toSet(), {'p1', 'p3'});
    });

    test('filters by volume', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: ProductFilterState(volumes: {'700ml'}),
      );
      expect(result.map((p) => p.id), ['p2']);
    });

    test('filters inStock only', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: const ProductFilterState(inStockOnly: true),
      );
      expect(result.every((p) => p.inStock), isTrue);
      expect(result.map((p) => p.id), isNot(contains('p2')));
    });

    test('sorts name ascending', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: const ProductFilterState(sortOption: ProductSortOption.nameAsc),
      );
      expect(result.map((p) => p.name).toList(), [
        'Alpha Whiskey',
        'Test Wine',
        'Zeta Red',
      ]);
    });

    test('sorts name descending', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: const ProductFilterState(sortOption: ProductSortOption.nameDesc),
      );
      expect(result.first.name, 'Zeta Red');
      expect(result.last.name, 'Alpha Whiskey');
    });

    test('sorts price ascending', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: const ProductFilterState(sortOption: ProductSortOption.priceAsc),
      );
      expect(result.map((p) => p.price).toList(), [10, 25, 40]);
    });

    test('sorts price descending', () {
      final result = ProductFilterEngine.apply(
        products: catalog,
        filter: const ProductFilterState(sortOption: ProductSortOption.priceDesc),
      );
      expect(result.map((p) => p.price).toList(), [40, 25, 10]);
    });

    test('reset filters returns all products', () {
      final filtered = ProductFilterEngine.apply(
        products: catalog,
        filter: ProductFilterState(brands: {'Highland'}),
      );
      expect(filtered, hasLength(1));

      final reset = ProductFilterEngine.apply(
        products: catalog,
        filter: ProductFilterState.empty,
      );
      expect(reset, hasLength(3));
    });
  });

  group('ProductFilterOptions', () {
    test('options generated from products', () {
      final options = ProductFilterOptions.fromProducts(catalog);
      expect(options.brands, containsAll(['Highland', 'Test Brand']));
      expect(options.countries, containsAll(['Albania', 'Scotland', 'Italy']));
      expect(options.categories, containsAll(['Wines', 'Spirits']));
      expect(options.volumes, containsAll(['750ml', '700ml']));
      expect(options.minPrice, 10);
      expect(options.maxPrice, 40);
    });

    test('empty products yields empty options', () {
      final options = ProductFilterOptions.fromProducts(const []);
      expect(options.brands, isEmpty);
      expect(options.minPrice, 0);
    });
  });

  group('ProductFilterState', () {
    test('activeCount and isActive', () {
      expect(ProductFilterState.empty.isActive, isFalse);
      expect(ProductFilterState.empty.activeCount, 0);

      final state = ProductFilterState(
        brands: {'Highland'},
        inStockOnly: true,
        sortOption: ProductSortOption.priceAsc,
      );
      expect(state.isActive, isTrue);
      expect(state.activeCount, 3);
    });

    test('reset clears all', () {
      final state = ProductFilterState(
        minPrice: 10,
        brands: {'X'},
        sortOption: ProductSortOption.nameDesc,
      );
      expect(state.reset().isActive, isFalse);
    });
  });
}
