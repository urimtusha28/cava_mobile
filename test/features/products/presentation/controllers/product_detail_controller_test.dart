import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/cart/domain/add_to_cart_result.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
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

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}

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
  stock: 50,
  isFeatured: true,
  variants: ['750ml'],
);

void main() {
  late MockGetProductById getProductById;
  late MockGetCategoryByIdUseCase getCategoryById;
  late MockGetSubcategoriesUseCase getSubcategories;
  late MockAddToCartUseCase addToCart;
  late ProductDetailController controller;

  setUpAll(() {
    registerFallbackValue(
      const AddToCartParams(product: _productWithMerlot, quantity: 1),
    );
  });

  setUp(() {
    getProductById = MockGetProductById();
    getCategoryById = MockGetCategoryByIdUseCase();
    getSubcategories = MockGetSubcategoriesUseCase();
    addToCart = MockAddToCartUseCase();
    controller = ProductDetailController(
      getProductById,
      getCategoryById,
      getSubcategories,
      addToCart,
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

  test('addToCart delegates quantity to use case', () async {
    when(() => getProductById('p1'))
        .thenAnswer((_) async => Success(_productWithMerlot));
    when(() => getCategoryById('wines'))
        .thenAnswer((_) async => Success(testCategoryEntity));
    when(() => getSubcategories('wines'))
        .thenAnswer((_) async => const Success([]));
    when(() => addToCart(any())).thenAnswer((_) async => const Success(null));

    await controller.load('p1');
    final result = await controller.addToCart(quantity: 3);

    expect(result, AddToCartResult.success);
    final captured = verify(() => addToCart(captureAny())).captured.single
        as AddToCartParams;
    expect(captured.quantity, 3);
    expect(captured.product.id, 'p1');
  });

  test('addToCart returns outOfStock when product not in stock', () async {
    const outOfStock = ProductEntity(
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
      stock: 0,
      isFeatured: true,
      variants: ['750ml'],
    );

    when(() => getProductById('p1'))
        .thenAnswer((_) async => Success(outOfStock));
    when(() => getCategoryById('wines'))
        .thenAnswer((_) async => Success(testCategoryEntity));
    when(() => getSubcategories('wines'))
        .thenAnswer((_) async => const Success([]));

    await controller.load('p1');
    final result = await controller.addToCart(quantity: 1);

    expect(result, AddToCartResult.outOfStock);
    verifyNever(() => addToCart(any()));
  });

  test('addToCart returns failure when use case fails', () async {
    when(() => getProductById('p1'))
        .thenAnswer((_) async => Success(_productWithMerlot));
    when(() => getCategoryById('wines'))
        .thenAnswer((_) async => Success(testCategoryEntity));
    when(() => getSubcategories('wines'))
        .thenAnswer((_) async => const Success([]));
    when(() => addToCart(any())).thenAnswer(
      (_) async => const Error(
        UnknownFailure(message: 'failed', code: '500'),
      ),
    );

    await controller.load('p1');
    final result = await controller.addToCart(quantity: 1);

    expect(result, AddToCartResult.failure);
  });
}
