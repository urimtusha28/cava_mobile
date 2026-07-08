import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/core/presentation/navigation_badge_controller.dart';
import 'package:cava_ecommerce/core/state/auth_state_notifier.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/core/state/wishlist_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/cart/data/local/cart_local_storage.dart';
import 'package:cava_ecommerce/features/cart/data/models/stored_cart_item_model.dart';
import 'package:cava_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/wishlist_guest_storage.dart';
import 'package:cava_ecommerce/features/wishlist/data/models/stored_wishlist_entry_model.dart';
import 'package:cava_ecommerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late CartRepository cartRepository;
  late WishlistRepository wishlistRepository;
  late String productId;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CartStateNotifier.reset();
    WishlistStateNotifier.reset();
    MockAuth.logout();
    AuthStateNotifier.reset();

    firestore = FakeFirebaseFirestore();
    productId = MockProducts.products.first.id;

    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      cartFirestore: firestore,
      wishlistFirestore: firestore,
    );

    cartRepository = sl<CartRepository>();
    wishlistRepository = sl<WishlistRepository>();
  });

  tearDown(() async {
    MockAuth.logout();
    await resetDependencies();
  });

  test('guest cart+wishlist merge once; logout keeps cloud; re-login reads cloud',
      () async {
    await CartLocalStorage().writeItems([
      StoredCartItemModel(
        productId: productId,
        quantity: 2,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);
    await WishlistGuestStorage().writeEntries([
      StoredWishlistEntryModel(
        productId: productId,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);

    await NavigationBadgeController.syncBadges();
    expect(CartStateNotifier.revision.value, 2);
    expect(WishlistStateNotifier.revision.value, 1);

    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc(productId)
        .set({
      'productId': productId,
      'quantity': 3,
      'addedAt': DateTime.utc(2026, 1, 1),
      'updatedAt': DateTime.utc(2026, 1, 1),
    });
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .doc(productId)
        .set({
      'productId': productId,
      'createdAt': DateTime.utc(2026, 1, 1),
    });

    MockAuth.login();
    await Future<void>.delayed(Duration.zero);
    await cartRepository.getItems();
    await wishlistRepository.getItems();
    await NavigationBadgeController.syncBadges();

    expect(await CartLocalStorage().readItems(), isEmpty);
    expect(await WishlistGuestStorage().readEntries(), isEmpty);
    expect(CartStateNotifier.revision.value, 5);
    expect(WishlistStateNotifier.revision.value, 1);

    final cartDocs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .get();
    expect(cartDocs.docs, hasLength(1));
    expect(cartDocs.docs.first.data()['quantity'], 5);

    // Same-value AuthStateNotifier.update must not fire another merge rewrite.
    AuthStateNotifier.update(true);
    await Future<void>.delayed(Duration.zero);
    await cartRepository.getItems();
    final cartDocsAfterNoop = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .get();
    expect(cartDocsAfterNoop.docs.single.data()['quantity'], 5);

    MockAuth.logout();
    await Future<void>.delayed(Duration.zero);
    await NavigationBadgeController.syncBadges();
    expect(CartStateNotifier.revision.value, 0);
    expect(WishlistStateNotifier.revision.value, 0);

    final cartAfterLogout = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .get();
    expect(cartAfterLogout.docs, hasLength(1));
    expect(cartAfterLogout.docs.first.data()['quantity'], 5);

    final wishlistAfterLogout = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.wishlistSubcollection)
        .get();
    expect(wishlistAfterLogout.docs, hasLength(1));

    MockAuth.login();
    await Future<void>.delayed(Duration.zero);
    await cartRepository.getItems();
    await wishlistRepository.getItems();
    await NavigationBadgeController.syncBadges();

    expect(CartStateNotifier.revision.value, 5);
    expect(WishlistStateNotifier.revision.value, 1);
    expect(await CartLocalStorage().readItems(), isEmpty);
    expect(await WishlistGuestStorage().readEntries(), isEmpty);
  });

  test('checkout/active cart reads Firestore cart when logged in', () async {
    MockAuth.login();
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc(productId)
        .set({
      'productId': productId,
      'quantity': 2,
      'addedAt': DateTime.utc(2026, 1, 1),
      'updatedAt': DateTime.utc(2026, 1, 1),
    });

    final items = await cartRepository.getItems();
    expect(items, hasLength(1));
    expect(items.first.quantity, 2);
    expect(items.first.product.id, productId);
  });

  test('AuthStateNotifier.update is idempotent for same value', () async {
    // Force a known false baseline without relying on reset()'s stream emit.
    if (AuthStateNotifier.isLoggedIn.value) {
      AuthStateNotifier.update(false);
    }
    expect(AuthStateNotifier.isLoggedIn.value, isFalse);

    final received = <bool>[];
    final sub = AuthStateNotifier.stream.listen(received.add);
    await Future<void>.delayed(Duration.zero);

    AuthStateNotifier.update(false);
    await Future<void>.delayed(Duration.zero);
    expect(received, isEmpty);

    AuthStateNotifier.update(true);
    await Future<void>.delayed(Duration.zero);
    expect(AuthStateNotifier.isLoggedIn.value, isTrue);
    expect(received, [true]);

    AuthStateNotifier.update(true);
    AuthStateNotifier.update(true);
    await Future<void>.delayed(Duration.zero);
    expect(received, [true]);

    await sub.cancel();
  });
}