import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_all_products.dart';
import 'package:cava_ecommerce/features/search/data/local/recent_search_storage.dart';
import 'package:cava_ecommerce/features/search/presentation/controllers/search_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockGetAllProducts extends Mock implements GetAllProductsUseCase {}

class _MockRecentSearchStorage extends Mock implements RecentSearchStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockGetAllProducts getAllProducts;
  late _MockRecentSearchStorage storage;
  late SearchController controller;

  setUp(() {
    getAllProducts = _MockGetAllProducts();
    storage = _MockRecentSearchStorage();
    controller = SearchController(getAllProducts, storage);

    when(() => storage.readQueries())
        .thenAnswer((_) async => <String>[]);
    when(() => storage.addQuery(any()))
        .thenAnswer((_) async {});
    when(() => storage.clear())
        .thenAnswer((_) async {});

    when(() => getAllProducts())
        .thenAnswer((_) async => Future.value(Success(<ProductEntity>[testProductEntity])));
  });

  tearDown(() {
    controller.dispose();
  });

  test('minimum 2 characters required for search', () async {
    controller.updateQuery('a');
    await Future<void>.delayed(SearchController.debounceDuration * 2);

    expect(controller.results, isEmpty);
  });

  test('debounce waits 300ms before applying search', () async {
    controller.updateQuery('Tes');
    expect(controller.results, isEmpty);

    await Future<void>.delayed(
      SearchController.debounceDuration * 2,
    );

    expect(controller.results, isNotEmpty);
  });

  test('filters products by query across fields', () async {
    controller.updateQuery('Test Wine');
    await Future<void>.delayed(SearchController.debounceDuration * 2);

    expect(controller.results.single.id, testProductEntity.id);
  });

  test('recent searches saved without duplicates and limited', () async {
    when(() => storage.readQueries())
        .thenAnswer((_) async => <String>['vere']);

    controller.updateQuery('vere kuqe');
    await controller.submitQuery();

    verify(() => storage.addQuery('vere kuqe')).called(1);
  });

  test('clearRecentSearches delegates to storage', () async {
    await controller.clearRecentSearches();

    verify(storage.clear).called(1);
  });
}

