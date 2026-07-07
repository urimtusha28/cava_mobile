import 'package:cava_ecommerce/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:cava_ecommerce/features/cart/data/local/cart_local_storage.dart';
import 'package:cava_ecommerce/features/cart/data/models/stored_cart_item_model.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CartLocalStorage storage;
  late MockProductRepository productRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = CartLocalStorage();
    await storage.clear();
    productRepository = MockProductRepository();
    when(() => productRepository.getById(any()))
        .thenAnswer((_) async => null);
  });

  test('persists cart after add', () async {
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);

    final dataSource = CartLocalDataSource(storage, productRepository);
    dataSource.addProduct(testProductEntity);
    await Future<void>.delayed(Duration.zero);

    final stored = await storage.readItems();
    expect(stored, hasLength(1));
    expect(stored.first.productId, 'p1');
    expect(stored.first.quantity, 1);
    expect(stored.first.addedAt, isNotEmpty);
  });

  test('restores cart after hydrate', () async {
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);

    await storage.writeItems([
      const StoredCartItemModel(
        productId: 'p1',
        quantity: 3,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);

    final dataSource = CartLocalDataSource(storage, productRepository);
    await dataSource.loadPersistedCart();

    expect(dataSource.getItemCount(), 3);
    expect(dataSource.getItems().first.product.id, 'p1');
  });

  test('remove updates storage', () async {
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);

    final dataSource = CartLocalDataSource(storage, productRepository);
    dataSource.addProduct(testProductEntity);
    await Future<void>.delayed(Duration.zero);
    dataSource.removeAt(0);
    await Future<void>.delayed(Duration.zero);

    expect(await storage.readItems(), isEmpty);
  });

  test('clear empties storage', () async {
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);

    final dataSource = CartLocalDataSource(storage, productRepository);
    dataSource.addProduct(testProductEntity);
    await Future<void>.delayed(Duration.zero);
    dataSource.clear();
    await Future<void>.delayed(Duration.zero);

    expect(await storage.readItems(), isEmpty);
    expect(dataSource.getItemCount(), 0);
  });

  test('missing product does not crash hydrate', () async {
    await storage.writeItems([
      const StoredCartItemModel(
        productId: 'missing',
        quantity: 1,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);

    final dataSource = CartLocalDataSource(storage, productRepository);
    await dataSource.loadPersistedCart();

    expect(dataSource.getItems(), isEmpty);
    expect(await storage.readItems(), isEmpty);
  });

  test('duplicate product increases quantity instead of new line', () async {
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);

    final dataSource = CartLocalDataSource(storage, productRepository);
    dataSource.addProduct(testProductEntity);
    dataSource.addProduct(testProductEntity, quantity: 2);
    await Future<void>.delayed(Duration.zero);

    expect(dataSource.getItems(), hasLength(1));
    expect(dataSource.getItemCount(), 3);

    final stored = await storage.readItems();
    expect(stored.single.quantity, 3);
  });

  test('addProduct with quantity persists correct amount', () async {
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);

    final dataSource = CartLocalDataSource(storage, productRepository);
    dataSource.addProduct(testProductEntity, quantity: 4);
    await Future<void>.delayed(Duration.zero);

    final stored = await storage.readItems();
    expect(stored.single.quantity, 4);
    expect(dataSource.getItemCount(), 4);
  });

  test('hydrate uses current product price from repository', () async {
    const updatedProduct = ProductEntity(
      id: 'p1',
      name: 'Updated',
      brand: 'Brand',
      categoryId: 'wines',
      categoryName: 'Wines',
      price: 99,
      description: '',
      volume: '750ml',
      type: 'Red',
      rating: 0,
      reviewCount: 0,
      inStock: true,
      isFeatured: false,
    );

    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => updatedProduct);

    await storage.writeItems([
      const StoredCartItemModel(
        productId: 'p1',
        quantity: 2,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);

    final dataSource = CartLocalDataSource(storage, productRepository);
    await dataSource.loadPersistedCart();

    expect(dataSource.getSubtotal(), 198);
  });
}
