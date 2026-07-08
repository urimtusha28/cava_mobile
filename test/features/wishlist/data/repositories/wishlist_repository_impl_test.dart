import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/core/state/wishlist_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/datasources/auth_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:cava_ecommerce/features/wishlist/data/datasources/wishlist_firestore_datasource.dart';
import 'package:cava_ecommerce/features/wishlist/data/datasources/wishlist_local_datasource.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/wishlist_guest_storage.dart';
import 'package:cava_ecommerce/features/wishlist/data/models/stored_wishlist_entry_model.dart';
import 'package:cava_ecommerce/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late WishlistGuestStorage guestStorage;
  late MockProductRepository productRepository;
  late AuthRepositoryImpl authRepository;
  late WishlistLocalDataSource localDataSource;
  late WishlistFirestoreDataSource firestoreDataSource;
  late WishlistRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WishlistStateNotifier.reset();
    MockAuth.logout();

    firestore = FakeFirebaseFirestore();
    guestStorage = WishlistGuestStorage();
    productRepository = MockProductRepository();
    authRepository = AuthRepositoryImpl(const AuthMockDataSource());
    localDataSource = WishlistLocalDataSource(guestStorage, productRepository);
    firestoreDataSource = WishlistFirestoreDataSource(
      firestore,
      authRepository,
      productRepository,
    );
    repository = WishlistRepositoryImpl(
      localDataSource,
      firestoreDataSource,
      authRepository,
    );

    when(() => productRepository.getById(any()))
        .thenAnswer((_) async => null);
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);
  });

  tearDown(() {
    repository.dispose();
    localDataSource.resetForTests();
    WishlistStateNotifier.reset();
    MockAuth.logout();
  });

  test('guest add uses local datasource and updates badge', () async {
    await repository.add(testProductEntity);

    expect(await repository.getCount(), 1);
    expect(WishlistStateNotifier.revision.value, 1);
    expect(await guestStorage.readEntries(), hasLength(1));
  });

  test('logged in wishlist reads from Firestore', () async {
    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .doc('p1')
        .set({'productId': 'p1', 'createdAt': DateTime.utc(2026, 1, 1)});

    final items = await repository.getItems();

    expect(items, [testProductEntity]);
  });

  test('merge local to Firestore after login without duplicates', () async {
    await guestStorage.writeEntries([
      const StoredWishlistEntryModel(
        productId: 'p1',
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);
    localDataSource.resetForTests();

    MockAuth.login();
    await repository.getItems();

    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .get();

    expect(docs.docs, hasLength(1));
    expect(docs.docs.first.id, 'p1');
    expect(await guestStorage.readEntries(), isEmpty);

    await repository.getItems();
    final docsAfterSecondMerge = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .get();
    expect(docsAfterSecondMerge.docs, hasLength(1));
  });

  test('toggle add/remove in Firestore when logged in', () async {
    MockAuth.login();

    await repository.toggle(testProductEntity);
    expect(await repository.isInWishlist('p1'), isTrue);
    expect(WishlistStateNotifier.revision.value, 1);

    await repository.toggle(testProductEntity);
    expect(await repository.isInWishlist('p1'), isFalse);
    expect(WishlistStateNotifier.revision.value, 0);
  });

  test('logout switches back to guest local wishlist without deleting Firestore', () async {
    MockAuth.login();
    await repository.add(testProductEntity);
    expect(await repository.getCount(), 1);

    MockAuth.logout();
    await Future<void>.delayed(Duration.zero);

    expect(await repository.getCount(), 0);
    expect(WishlistStateNotifier.revision.value, 0);

    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .get();
    expect(docs.docs, hasLength(1));
  });

  test('removes missing products from Firestore wishlist', () async {
    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .doc('missing')
        .set({'productId': 'missing', 'createdAt': DateTime.utc(2026, 1, 1)});

    final items = await repository.getItems();

    expect(items, isEmpty);
    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .get();
    expect(docs.docs, isEmpty);
  });
}
