import 'package:cava_ecommerce/features/products/data/models/product_model.dart';
import 'package:cava_ecommerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockProductDataSource dataSource;
  late ProductRepositoryImpl repository;

  setUp(() {
    dataSource = MockProductDataSource();
    repository = ProductRepositoryImpl(dataSource);
  });

  group('ProductRepositoryImpl', () {
    test('getRecommended maps featured products', () async {
      when(() => dataSource.getFeaturedProducts())
          .thenReturn([testProductModel]);

      final result = await repository.getRecommended();
      expect(result, hasLength(1));
      expect(result.first.id, 'p1');
    });

    test('getBestSellers sorts by reviewCount', () async {
      final low = testProductModel;
      final high = ProductModel(
        id: 'p2',
        name: 'Popular',
        brand: 'B',
        categoryId: 'wines',
        categoryName: 'Wines',
        price: 10,
        description: '',
        volume: '750ml',
        type: 'Red',
        rating: 5,
        reviewCount: 999,
        inStock: true,
        isFeatured: false,
      );
      when(() => dataSource.getAllProducts()).thenReturn([low, high]);

      final result = await repository.getBestSellers();
      expect(result.first.id, 'p2');
    });

    test('getOffers filters products with oldPrice', () async {
      when(() => dataSource.getAllProducts()).thenReturn([testProductModel]);

      final result = await repository.getOffers();
      expect(result, hasLength(1));
    });

    test('getById returns null when missing', () async {
      when(() => dataSource.getProductById('missing')).thenReturn(null);
      expect(await repository.getById('missing'), isNull);
    });

    test('getProductsByCategory delegates to datasource', () async {
      when(() => dataSource.getProductsByCategory('wines'))
          .thenReturn([testProductModel]);

      final result = await repository.getProductsByCategory('wines');
      expect(result.first.categoryId, 'wines');
    });
  });
}
