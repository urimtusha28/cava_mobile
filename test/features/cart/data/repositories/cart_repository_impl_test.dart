import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/datasources/auth_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:cava_ecommerce/features/cart/data/datasources/cart_firestore_datasource.dart';
import 'package:cava_ecommerce/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:cava_ecommerce/features/cart/data/local/cart_local_storage.dart';
import 'package:cava_ecommerce/features/cart/data/models/stored_cart_item_model.dart';
import 'package:cava_ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:cava_ecommerce/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

const testProductEntity2 = ProductEntity(
  id: 'p2',
  name: 'Second Wine',
  brand: 'Brand',
  categoryId: 'wines',
  categoryName: 'Wines',
  price: 15,
  description: '',
  volume: '750ml',
  type: 'White',
  rating: 0,
  reviewCount: 0,
  inStock: true,
  isFeatured: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late CartLocalStorage localStorage;
  late MockProductRepository productRepository;
  late AuthRepositoryImpl authRepository;
  late CartLocalDataSource localDataSource;
  late CartFirestoreDataSource firestoreDataSource;
  late CartRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CartStateNotifier.reset();
    MockAuth.logout();

    firestore = FakeFirebaseFirestore();
    localStorage = CartLocalStorage();
    productRepository = MockProductRepository();
    authRepository = AuthRepositoryImpl(const AuthMockDataSource());
    localDataSource = CartLocalDataSource(localStorage, productRepository);
    firestoreDataSource = CartFirestoreDataSource(
      firestore,
      authRepository,
      productRepository,
    );
    repository = CartRepositoryImpl(
      localDataSource,
      firestoreDataSource,
      authRepository,
    );

    when(() => productRepository.getById(any()))
        .thenAnswer((_) async => null);
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);
    when(() => productRepository.getById('p2'))
        .thenAnswer((_) async => testProductEntity2);
  });

  tearDown(() {
    repository.dispose();
    localDataSource.resetForTests();
    CartStateNotifier.reset();
    MockAuth.logout();
  });

  test('guest add persists locally and updates badge', () async {
    await repository.addProduct(testProductEntity, quantity: 2);

    expect(await repository.getItemCount(), 2);
    expect(CartStateNotifier.revision.value, 2);
    expect(await localStorage.readItems(), hasLength(1));
    expect((await localStorage.readItems()).first.quantity, 2);
  });

  test('logged in cart reads from Firestore', () async {
    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('p1')
        .set({
      'productId': 'p1',
      'quantity': 3,
      'addedAt': DateTime.utc(2026, 1, 1),
      'updatedAt': DateTime.utc(2026, 1, 1),
    });

    final items = await repository.getItems();

    expect(items, hasLength(1));
    expect(items.first.quantity, 3);
    expect(items.first.product.id, 'p1');
  });

  test('merge local to Firestore after login sums quantities without duplicates', () async {
    await localStorage.writeItems([
      const StoredCartItemModel(
        productId: 'p1',
        quantity: 2,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);
    localDataSource.resetForTests();

    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('p1')
        .set({
      'productId': 'p1',
      'quantity': 3,
      'addedAt': DateTime.utc(2026, 1, 1),
      'updatedAt': DateTime.utc(2026, 1, 1),
    });

    final items = await repository.getItems();

    expect(items, hasLength(1));
    expect(items.first.quantity, 5);
    expect(await localStorage.readItems(), isEmpty);

    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .get();
    expect(docs.docs, hasLength(1));
    expect(docs.docs.first.data()['quantity'], 5);
  });

  test('merge combines guest-only and cloud-only lines', () async {
    await localStorage.writeItems([
      const StoredCartItemModel(
        productId: 'p2',
        quantity: 1,
        addedAt: '2026-01-02T00:00:00.000Z',
      ),
    ]);
    localDataSource.resetForTests();

    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('p1')
        .set({
      'productId': 'p1',
      'quantity': 2,
      'addedAt': DateTime.utc(2026, 1, 1),
      'updatedAt': DateTime.utc(2026, 1, 1),
    });

    final items = await repository.getItems();

    expect(items, hasLength(2));
    expect(
      items.map((item) => item.product.id).toSet(),
      {'p1', 'p2'},
    );
  });

  test('logged in add/update/remove use Firestore', () async {
    MockAuth.login();

    await repository.addProduct(testProductEntity, quantity: 2);
    expect(await repository.getItemCount(), 2);
    expect(CartStateNotifier.revision.value, 2);

    await repository.updateQuantity(0, 4);
    expect(await repository.getItemCount(), 4);

    await repository.removeAt(0);
    expect(await repository.getItemCount(), 0);

    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .get();
    expect(docs.docs, isEmpty);
  });

  test('logout switches to guest cart without deleting Firestore cart', () async {
    MockAuth.login();
    await repository.addProduct(testProductEntity, quantity: 3);
    expect(await repository.getItemCount(), 3);

    MockAuth.logout();
    await Future<void>.delayed(Duration.zero);

    expect(await repository.getItemCount(), 0);
    expect(CartStateNotifier.revision.value, 0);

    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .get();
    expect(docs.docs, hasLength(1));
    expect(docs.docs.first.data()['quantity'], 3);
  });

  test('removes missing products from Firestore cart on hydrate', () async {
    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('missing')
        .set({
      'productId': 'missing',
      'quantity': 1,
      'addedAt': DateTime.utc(2026, 1, 1),
      'updatedAt': DateTime.utc(2026, 1, 1),
    });

    final items = await repository.getItems();

    expect(items, isEmpty);
    final doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('missing')
        .get();
    expect(doc.exists, isFalse);
  });

  test('getSummary aggregates active datasource values', () async {
    await repository.addProduct(testProductEntity, quantity: 2);

    final summary = await repository.getSummary();

    expect(summary, isA<CartSummaryEntity>());
    expect(summary.itemCount, 2);
    expect(summary.discount, 0);
    expect(summary.subtotal, 50);
    expect(summary.total, 50);
  });

  test('hydrateFromStorage refreshes badge from active cart', () async {
    await localStorage.writeItems([
      const StoredCartItemModel(
        productId: 'p1',
        quantity: 4,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);
    localDataSource.resetForTests();

    await repository.hydrateFromStorage();

    expect(CartStateNotifier.revision.value, 4);
  });
}
