import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/account/data/datasources/auth_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:cava_ecommerce/features/wishlist/data/datasources/wishlist_firestore_datasource.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AuthRepositoryImpl authRepository;
  late MockProductRepository productRepository;
  late WishlistFirestoreDataSource dataSource;

  setUp(() {
    MockAuth.logout();
    firestore = FakeFirebaseFirestore();
    authRepository = AuthRepositoryImpl(const AuthMockDataSource());
    productRepository = MockProductRepository();
    dataSource = WishlistFirestoreDataSource(
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

  test('add writes users/{uid}/wishlist/{productId}', () async {
    MockAuth.login();
    await dataSource.add(testProductEntity);

    final doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .doc('p1')
        .get();

    expect(doc.exists, isTrue);
    expect(doc.data()?['productId'], 'p1');
    expect(doc.data()?['createdAt'], isNotNull);
  });

  test('getItems hydrates products and removes missing entries', () async {
    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .doc('p1')
        .set({'productId': 'p1', 'createdAt': DateTime.utc(2026, 1, 1)});
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .doc('missing')
        .set({'productId': 'missing', 'createdAt': DateTime.utc(2026, 1, 1)});

    final items = await dataSource.getItems();

    expect(items, [testProductEntity]);
    final missingDoc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .doc('missing')
        .get();
    expect(missingDoc.exists, isFalse);
  });

  test('toggle adds and removes Firestore entry', () async {
    MockAuth.login();

    await dataSource.toggle(testProductEntity);
    expect(await dataSource.isInWishlist('p1'), isTrue);
    expect(await dataSource.getCount(), 1);

    await dataSource.toggle(testProductEntity);
    expect(await dataSource.isInWishlist('p1'), isFalse);
    expect(await dataSource.getCount(), 0);
  });
}
