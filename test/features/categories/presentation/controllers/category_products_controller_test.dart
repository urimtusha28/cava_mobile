import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_category_by_id.dart';
import 'package:cava_ecommerce/features/categories/domain/usecases/get_subcategories.dart';
import 'package:cava_ecommerce/features/categories/presentation/controllers/category_products_controller.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_all_products.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_products_by_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetCategoryById extends Mock implements GetCategoryByIdUseCase {}

class MockGetSubcategories extends Mock implements GetSubcategoriesUseCase {}

class MockGetAllProducts extends Mock implements GetAllProductsUseCase {}

class MockGetProductsByCategory extends Mock
    implements GetProductsByCategoryUseCase {}

void main() {
  late CategoryProductsController controller;
  late MockGetCategoryById getCategoryById;
  late MockGetSubcategories getSubcategories;
  late MockGetAllProducts getAllProducts;
  late MockGetProductsByCategory getProductsByCategory;

  setUp(() {
    getCategoryById = MockGetCategoryById();
    getSubcategories = MockGetSubcategories();
    getAllProducts = MockGetAllProducts();
    getProductsByCategory = MockGetProductsByCategory();
    controller = CategoryProductsController(
      getCategoryById,
      getSubcategories,
      getAllProducts,
      getProductsByCategory,
    );
  });

  test('load all products when categoryId is all', () async {
    when(() => getAllProducts())
        .thenAnswer((_) async => Success([testProductEntity]));

    await controller.load('all');

    expect(controller.category, isNull);
    expect(controller.products, hasLength(1));
    expect(controller.subcategories.first.id, 'all');
  });

  test('load category products for specific id', () async {
    when(() => getCategoryById('wines'))
        .thenAnswer((_) async => Success(testCategoryEntity));
    when(() => getProductsByCategory('Wines'))
        .thenAnswer((_) async => Success([testProductEntity]));
    when(() => getSubcategories('wines'))
        .thenAnswer((_) async => Success([testSubcategoryEntity]));

    await controller.load('wines');

    expect(controller.category?.id, 'wines');
    expect(controller.products, hasLength(1));
    expect(controller.subcategories, hasLength(1));
  });

  test('isLoading is false after load completes', () async {
    when(() => getAllProducts())
        .thenAnswer((_) async => Success([testProductEntity]));

    expect(controller.isLoading, isFalse);
    final loadFuture = controller.load('all');
    expect(controller.isLoading, isTrue);
    await loadFuture;
    expect(controller.isLoading, isFalse);
    expect(controller.isInitialized, isTrue);
  });
}
