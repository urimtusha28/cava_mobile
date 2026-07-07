import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/categories/domain/entities/subcategory_entity.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_category_by_id.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_subcategories.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_product_by_id.dart';
import 'package:cava_ecommerce/features/products/presentation/controllers/product_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetProductById extends Mock implements GetProductById {}

class MockGetCategoryByIdUseCase extends Mock implements GetCategoryByIdUseCase {}

class MockGetSubcategoriesUseCase extends Mock implements GetSubcategoriesUseCase {}

const _productWithMerlot = ProductEntity(
  id: 'p1',
  name: 'Test Wine',
  brand: 'Test Brand',
  categoryId: 'wines',
  categoryName: 'Wines',
  price: 25.0,
  oldPrice: 30.0,
  description: 'A test wine',
  volume: '750ml',
  alcoholPercentage: 13.5,
  country: 'Albania',
  type: 'Merlot',
  rating: 4.5,
  reviewCount: 100,
  inStock: true,
  isFeatured: true,
  variants: ['750ml'],
);

void main() {
  late MockGetProductById getProductById;
  late MockGetCategoryByIdUseCase getCategoryById;
  late MockGetSubcategoriesUseCase getSubcategories;
  late ProductDetailController controller;

  setUp(() {
    getProductById = MockGetProductById();
    getCategoryById = MockGetCategoryByIdUseCase();
    getSubcategories = MockGetSubcategoriesUseCase();
    controller = ProductDetailController(
      getProductById,
      getCategoryById,
      getSubcategories,
    );
  });

  test('load sets product on success', () async {
    when(() => getProductById('p1'))
        .thenAnswer((_) async => Success(_productWithMerlot));
    when(() => getCategoryById('wines'))
        .thenAnswer((_) async => Success(testCategoryEntity));
    when(() => getSubcategories('wines')).thenAnswer(
      (_) async => Success([
        const SubcategoryEntity(id: 'all', label: 'All'),
        const SubcategoryEntity(
          id: 'merlot',
          label: 'Merlot',
          matchTypes: ['Merlot'],
          badgeColor: '#AA0000',
        ),
      ]),
    );

    await controller.load('p1');

    expect(controller.isInitialized, isTrue);
    expect(controller.product?.id, 'p1');
    expect(controller.category?.badgeColor, '#7A1F32');
    expect(controller.productSubcategory?.label, 'Merlot');
    expect(controller.categoryBadgeLabel, 'Merlot');
    expect(controller.isLoading, isFalse);
  });

  test('load keeps null product on failure', () async {
    when(() => getProductById('missing')).thenAnswer(
      (_) async => const Error(
        UnknownFailure(message: 'not found', code: '404'),
      ),
    );

    await controller.load('missing');

    expect(controller.product, isNull);
    expect(controller.category, isNull);
    expect(controller.isInitialized, isTrue);
  });

  test('load sets errorMessage when use case throws', () async {
    when(() => getProductById('p1')).thenThrow(Exception('network'));

    await controller.load('p1');

    expect(controller.errorMessage, isNotNull);
  });

  test('notifyListeners fires on load', () async {
    when(() => getProductById('p1'))
        .thenAnswer((_) async => Success(_productWithMerlot));
    when(() => getCategoryById('wines'))
        .thenAnswer((_) async => Success(testCategoryEntity));
    when(() => getSubcategories('wines'))
        .thenAnswer((_) async => const Success([]));

    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.load('p1');

    expect(notifications, greaterThan(0));
  });
}
