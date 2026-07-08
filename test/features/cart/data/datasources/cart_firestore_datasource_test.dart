import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/account/data/datasources/auth_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:cava_ecommerce/features/cart/data/datasources/cart_firestore_datasource.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AuthRepositoryImpl authRepository;
  late MockProductRepository productRepository;
  late CartFirestoreDataSource dataSource;

  setUp(() {
    MockAuth.logout();
    firestore = FakeFirebaseFirestore();
    authRepository = AuthRepositoryImpl(const AuthMockDataSource());
    productRepository = MockProductRepository();
    dataSource = CartFirestoreDataSource(
      firestore,
      authRepository,
      productRepository,
    );

    when(() => productRepository.getById(any()))
        .thenAnswer((_) async => null);
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);
  });

  tearDown(() {
    authRepository.dispose();
    MockAuth.logout();
  });

  test('addProduct writes users/{uid}/cart/{productId}', () async {
    MockAuth.login();
    await dataSource.loadPersistedCart();
    dataSource.addProduct(testProductEntity, quantity: 2);
    await Future<void>.delayed(Duration.zero);

    final doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('p1')
        .get();

    expect(doc.exists, isTrue);
    expect(doc.data()?['productId'], 'p1');
    expect(doc.data()?['quantity'], 2);
    expect(doc.data()?['addedAt'], isNotNull);
    expect(doc.data()?['updatedAt'], isNotNull);
  });

  test('loadPersistedCart hydrates products and removes missing entries', () async {
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

    await dataSource.loadPersistedCart();

    expect(dataSource.getItems(), hasLength(1));
    expect(dataSource.getItemCount(), 3);
    expect(dataSource.getItems().first.product.id, 'p1');

    final missingDoc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('missing')
        .get();
    expect(missingDoc.exists, isFalse);
  });

  test('updateQuantity and removeAt persist to Firestore', () async {
    MockAuth.login();
    await dataSource.loadPersistedCart();
    dataSource.addProduct(testProductEntity);
    await Future<void>.delayed(Duration.zero);

    dataSource.updateQuantity(0, 4);
    await Future<void>.delayed(Duration.zero);

    var doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('p1')
        .get();
    expect(doc.data()?['quantity'], 4);

    dataSource.removeAt(0);
    await Future<void>.delayed(Duration.zero);

    doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc('p1')
        .get();
    expect(doc.exists, isFalse);
  });

  test('clear removes all Firestore cart documents', () async {
    MockAuth.login();
    await dataSource.loadPersistedCart();
    dataSource.addProduct(testProductEntity);
    await Future<void>.delayed(Duration.zero);
    dataSource.clear();
    await Future<void>.delayed(Duration.zero);

    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .get();
    expect(docs.docs, isEmpty);
    expect(dataSource.getItemCount(), 0);
  });

  test('getItemCount sums line quantities', () async {
    MockAuth.login();
    await dataSource.loadPersistedCart();
    dataSource.addProduct(testProductEntity, quantity: 2);
    await Future<void>.delayed(Duration.zero);

    expect(dataSource.getItemCount(), 2);
  });
}
