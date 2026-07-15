import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/features/products/domain/filtering/product_filter_state.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_all_products.dart';
import 'package:cava_ecommerce/features/search/data/local/recent_search_storage.dart';
import 'package:cava_ecommerce/features/search/presentation/controllers/search_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockGetAllProducts extends Mock implements GetAllProductsUseCase {}

class _MockRecentSearchStorage extends Mock implements RecentSearchStorage {}

const _spirit = ProductEntity(
  id: 'p2',
  name: 'Highland Spirit',
  brand: 'Highland',
  categoryId: 'spirits',
  categoryName: 'Spirits',
  price: 40,
  description: 'Spirit drink',
  volume: '700ml',
  country: 'Scotland',
  type: 'Whiskey',
  rating: 4,
  reviewCount: 10,
  stock: 50,
  isFeatured: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockGetAllProducts getAllProducts;
  late _MockRecentSearchStorage storage;
  late SearchController controller;

  setUp(() {
    getAllProducts = _MockGetAllProducts();
    storage = _MockRecentSearchStorage();
    controller = SearchController(getAllProducts, storage);

    when(() => storage.readQueries()).thenAnswer((_) async => <String>[]);
    when(() => storage.addQuery(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});
    when(() => getAllProducts()).thenAnswer(
      (_) async => Future.value(Success([testProductEntity, _spirit])),
    );
  });

  tearDown(() => controller.dispose());

  test('filters apply only to search results', () async {
    controller.updateQuery('Test');
    await Future<void>.delayed(SearchController.debounceDuration * 2);

    expect(controller.rawSearchResults.map((p) => p.id), ['p1']);
    expect(controller.results.map((p) => p.id), ['p1']);

    controller.applyFilter(ProductFilterState(brands: {'Highland'}));
    expect(controller.results, isEmpty);

    controller.clearFilter();
    expect(controller.results.map((p) => p.id), ['p1']);
  });

  test('brand filter keeps matching search hit', () async {
    controller.updateQuery('Highland');
    await Future<void>.delayed(SearchController.debounceDuration * 2);

    controller.applyFilter(ProductFilterState(brands: {'Highland'}));
    expect(controller.results.single.id, 'p2');
  });
}
