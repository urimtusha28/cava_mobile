import 'package:cava_ecommerce/features/categories/domain/entities/subcategory_entity.dart';
import 'package:cava_ecommerce/features/categories/presentation/utils/category_product_badge_resolver.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  const productWithSub = ProductEntity(
    id: 'p1',
    name: 'Test Wine',
    brand: 'Test Brand',
    categoryId: 'wines',
    categoryName: 'Wines',
    price: 25.0,
    description: 'A test wine',
    volume: '750ml',
    type: 'Merlot',
    rating: 4.5,
    reviewCount: 100,
    stock: 50,
    isFeatured: true,
  );

  const subcategories = [
    SubcategoryEntity(id: 'all', label: 'All'),
    SubcategoryEntity(
      id: 'merlot',
      label: 'Merlot',
      matchTypes: ['Merlot'],
      badgeColor: '#AA0000',
    ),
  ];

  group('CategoryProductBadgeResolver.findSubcategory', () {
    test('matches subcategory by product type', () {
      final sub = CategoryProductBadgeResolver.findSubcategory(
        productWithSub,
        subcategories,
      );
      expect(sub?.label, 'Merlot');
      expect(sub?.badgeColor, '#AA0000');
    });

    test('returns null when no subcategory matches', () {
      const product = ProductEntity(
        id: 'p2',
        name: 'Other',
        brand: 'Brand',
        categoryId: 'wines',
        categoryName: 'Wines',
        price: 10,
        description: '',
        volume: '750ml',
        type: 'Unknown',
        rating: 0,
        reviewCount: 0,
        stock: 50,
        isFeatured: false,
      );
      final sub = CategoryProductBadgeResolver.findSubcategory(
        product,
        subcategories,
      );
      expect(sub, isNull);
    });
  });

  group('CategoryProductBadgeResolver.resolveLabel', () {
    test('prefers subcategory label over main category', () {
      final label = CategoryProductBadgeResolver.resolveLabel(
        product: productWithSub,
        mainCategory: testCategoryEntity,
        subcategory: subcategories[1],
      );
      expect(label, 'Merlot');
    });

    test('uses product type when subcategory is missing', () {
      final label = CategoryProductBadgeResolver.resolveLabel(
        product: productWithSub,
        mainCategory: testCategoryEntity,
      );
      expect(label, 'Merlot');
    });

    test('falls back to main category when type is empty', () {
      const product = ProductEntity(
        id: 'p3',
        name: 'Plain',
        brand: 'Brand',
        categoryId: 'wines',
        categoryName: 'Wines',
        price: 10,
        description: '',
        volume: '750ml',
        type: '',
        rating: 0,
        reviewCount: 0,
        stock: 50,
        isFeatured: false,
      );
      final label = CategoryProductBadgeResolver.resolveLabel(
        product: product,
        mainCategory: testCategoryEntity,
      );
      expect(label, 'Verërat');
    });
  });
}
