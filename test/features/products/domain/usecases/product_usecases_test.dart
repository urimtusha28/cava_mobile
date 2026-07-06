import 'package:cava_ecommerce/features/products/domain/usecases/get_all_products.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_best_seller_products.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_offer_products.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_product_by_id.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_products_by_category.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_recommended_products.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  test('GetRecommendedProducts returns success', () async {
    when(() => repository.getRecommended())
        .thenAnswer((_) async => [testProductEntity]);
    final useCase = GetRecommendedProducts(repository);
    final result = await useCase();
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, hasLength(1));
  });

  test('GetBestSellerProducts returns success', () async {
    when(() => repository.getBestSellers())
        .thenAnswer((_) async => [testProductEntity]);
    final result = await GetBestSellerProducts(repository)();
    expect(result.isSuccess, isTrue);
  });

  test('GetOfferProducts returns success', () async {
    when(() => repository.getOffers())
        .thenAnswer((_) async => [testProductEntity]);
    final result = await GetOfferProducts(repository)();
    expect(result.isSuccess, isTrue);
  });

  test('GetAllProductsUseCase returns success', () async {
    when(() => repository.getAll())
        .thenAnswer((_) async => [testProductEntity]);
    final result = await GetAllProductsUseCase(repository)();
    expect(result.isSuccess, isTrue);
  });

  test('GetProductById returns success', () async {
    when(() => repository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);
    final result = await GetProductById(repository)('p1');
    expect(result.dataOrNull?.id, 'p1');
  });

  test('GetProductsByCategoryUseCase returns success', () async {
    when(() => repository.getProductsByCategory('wines'))
        .thenAnswer((_) async => [testProductEntity]);
    final result = await GetProductsByCategoryUseCase(repository)('wines');
    expect(result.isSuccess, isTrue);
  });

  test('returns failure when repository throws', () async {
    when(() => repository.getRecommended()).thenThrow(Exception('fail'));
    final result = await GetRecommendedProducts(repository)();
    expect(result.isFailure, isTrue);
  });
}
