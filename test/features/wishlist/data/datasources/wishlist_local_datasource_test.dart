import 'package:cava_ecommerce/features/wishlist/data/datasources/wishlist_local_datasource.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/local_wishlist_store.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/wishlist_guest_storage.dart';
import 'package:cava_ecommerce/features/wishlist/data/models/stored_wishlist_entry_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WishlistGuestStorage storage;
  late MockProductRepository productRepository;
  late WishlistLocalDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = WishlistGuestStorage();
    productRepository = MockProductRepository();
    dataSource = WishlistLocalDataSource(storage, productRepository);

    when(() => productRepository.getById(any()))
        .thenAnswer((_) async => null);
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);
  });

  tearDown(() {
    dataSource.resetForTests();
  });

  test('starts empty without mock seed products', () async {
    expect(await dataSource.getItems(), isEmpty);
    expect(await dataSource.getCount(), 0);
  });

  test('stores only productId and addedAt in SharedPreferences', () async {
    await dataSource.add(testProductEntity);

    final stored = await storage.readEntries();
    expect(stored, hasLength(1));
    expect(stored.first.productId, 'p1');
    expect(stored.first.addedAt, isNotEmpty);
    expect(stored.first.toJson().containsKey('name'), isFalse);
  });

  test('hydrates ProductEntity from productId', () async {
    await dataSource.add(testProductEntity);

    final items = await dataSource.getItems();

    expect(items, [testProductEntity]);
    verify(() => productRepository.getById('p1')).called(1);
  });

  test('guest wishlist persists after restart', () async {
    await dataSource.add(testProductEntity);
    dataSource.resetForTests();

    final restarted = WishlistLocalDataSource(storage, productRepository);
    final items = await restarted.getItems();

    expect(items, [testProductEntity]);
    expect(await restarted.getCount(), 1);
  });

  test('remove deletes product from local wishlist', () async {
    await dataSource.add(testProductEntity);
    await dataSource.remove('p1');

    expect(await dataSource.getItems(), isEmpty);
    expect(await dataSource.isInWishlist('p1'), isFalse);
    expect(await storage.readEntries(), isEmpty);
  });

  test('removes missing products during hydration', () async {
    await storage.writeEntries([
      const StoredWishlistEntryModel(
        productId: 'missing',
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);
    dataSource.resetForTests();

    final items = await dataSource.getItems();

    expect(items, isEmpty);
    expect(await storage.readEntries(), isEmpty);
    expect(LocalWishlistStore.count, 0);
  });
}
