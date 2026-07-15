import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/core/state/auth_state_notifier.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/core/state/wishlist_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/cart/domain/add_to_cart_result.dart';
import 'package:cava_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/get_wishlist_items.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'package:cava_ecommerce/features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'package:cava_ecommerce/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_app.dart';
import '../../../../helpers/test_di.dart';

class MockGetWishlistItemsUseCase extends Mock
    implements GetWishlistItemsUseCase {}

class MockRemoveFromWishlistUseCase extends Mock
    implements RemoveFromWishlistUseCase {}

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WishlistController addToCart', () {
    late WishlistController controller;
    late MockGetWishlistItemsUseCase getWishlistItems;
    late MockRemoveFromWishlistUseCase removeFromWishlist;
    late MockAddToCartUseCase addToCart;

    setUpAll(() {
      registerFallbackValue(
        AddToCartParams(product: testProductEntity, quantity: 1),
      );
    });

    setUp(() {
      WishlistStateNotifier.reset();
      CartStateNotifier.reset();
      getWishlistItems = MockGetWishlistItemsUseCase();
      removeFromWishlist = MockRemoveFromWishlistUseCase();
      addToCart = MockAddToCartUseCase();
      controller = WishlistController(
        getWishlistItems,
        removeFromWishlist,
        addToCart,
      );
    });

    test('success removes from wishlist and refreshes wishlist badge', () async {
      when(() => addToCart(any())).thenAnswer((_) async => const Success(null));
      when(() => removeFromWishlist(testProductEntity.id))
          .thenAnswer((_) async => const Success(null));
      when(() => getWishlistItems()).thenAnswer((_) async => const Success([]));

      WishlistStateNotifier.update(1);
      final result = await controller.addToCart(testProductEntity);

      expect(result, AddToCartResult.success);
      verify(() => addToCart(any())).called(1);
      verify(() => removeFromWishlist(testProductEntity.id)).called(1);
      expect(controller.items, isEmpty);
      expect(WishlistStateNotifier.revision.value, 0);
    });

    test('failure leaves wishlist unchanged', () async {
      when(() => addToCart(any())).thenAnswer(
        (_) async => const Error(UnknownFailure(message: 'fail')),
      );
      when(() => getWishlistItems())
          .thenAnswer((_) async => Success([testProductEntity]));
      await controller.load();
      WishlistStateNotifier.update(1);

      final result = await controller.addToCart(testProductEntity);

      expect(result, AddToCartResult.failure);
      verifyNever(() => removeFromWishlist(any()));
      expect(controller.items, hasLength(1));
      expect(WishlistStateNotifier.revision.value, 1);
    });

    test('out of stock leaves wishlist unchanged', () async {
      const oos = ProductEntity(
        id: 'oos',
        name: 'OOS',
        brand: 'B',
        categoryId: 'wines',
        categoryName: 'Wines',
        price: 10,
        description: '',
        volume: '750ml',
        type: 'Red',
        rating: 0,
        reviewCount: 0,
        stock: 0,
        isFeatured: false,
      );
      when(() => getWishlistItems())
          .thenAnswer((_) async => const Success([oos]));
      await controller.load();

      final result = await controller.addToCart(oos);

      expect(result, AddToCartResult.outOfStock);
      verifyNever(() => addToCart(any()));
      verifyNever(() => removeFromWishlist(any()));
      expect(controller.items, hasLength(1));
    });
  });

  group('Wishlist → Cart integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      CartStateNotifier.reset();
      WishlistStateNotifier.reset();
      AuthStateNotifier.reset();
      MockAuth.logout();
    });

    tearDown(() async {
      MockAuth.logout();
      AuthStateNotifier.reset();
      await resetDependencies();
    });

    test('guest add success removes from SharedPreferences wishlist', () async {
      await configureTestDependencies(
        productDataSource: const ProductMockDataSource(),
        cartFirestore: FakeFirebaseFirestore(),
        wishlistFirestore: FakeFirebaseFirestore(),
      );

      final product = MockProducts.products.first;
      await sl<WishlistRepository>().add(product);
      final controller = sl<WishlistController>();
      await controller.load();
      expect(controller.items, hasLength(1));

      final cartBefore = CartStateNotifier.revision.value;
      final result = await controller.addToCart(product);

      expect(result, AddToCartResult.success);
      expect(controller.items, isEmpty);
      expect(WishlistStateNotifier.revision.value, 0);
      expect(CartStateNotifier.revision.value, greaterThan(cartBefore));
      expect(await sl<CartRepository>().getItemCount(), 1);
      expect(await sl<WishlistRepository>().getCount(), 0);
    });

    test('logged in add success removes from Firestore wishlist', () async {
      final firestore = FakeFirebaseFirestore();
      await configureTestDependencies(
        productDataSource: const ProductMockDataSource(),
        cartFirestore: firestore,
        wishlistFirestore: firestore,
      );
      MockAuth.login();
      AuthStateNotifier.update(true);
      await Future<void>.delayed(Duration.zero);

      final product = MockProducts.products.first;
      await sl<WishlistRepository>().add(product);
      final controller = sl<WishlistController>();
      await controller.load();

      final result = await controller.addToCart(product);

      expect(result, AddToCartResult.success);
      expect(controller.items, isEmpty);
      expect(WishlistStateNotifier.revision.value, 0);
      expect(CartStateNotifier.revision.value, greaterThan(0));

      final cartDoc = await firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(MockAuth.currentUser.uid)
          .collection(FirebaseConfig.cartSubcollection)
          .doc(product.id)
          .get();
      expect(cartDoc.exists, isTrue);

      final wishlistDoc = await firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(MockAuth.currentUser.uid)
          .collection(FirebaseConfig.wishlistSubcollection)
          .doc(product.id)
          .get();
      expect(wishlistDoc.exists, isFalse);
    });

    test('duplicate add merges quantity without duplicate lines', () async {
      await configureTestDependencies(
        productDataSource: const ProductMockDataSource(),
        cartFirestore: FakeFirebaseFirestore(),
        wishlistFirestore: FakeFirebaseFirestore(),
      );

      final product = MockProducts.products.first;
      await sl<CartRepository>().addProduct(product, quantity: 1);
      await sl<WishlistRepository>().add(product);
      final controller = sl<WishlistController>();
      await controller.load();

      final result = await controller.addToCart(product);

      expect(result, AddToCartResult.success);
      final items = await sl<CartRepository>().getItems();
      expect(items, hasLength(1));
      expect(items.first.quantity, 2);
    });

    testWidgets('snackbar success after add to cart', (tester) async {
      await setUpTestDependencies();
      addTearDown(tearDownTestDependencies);

      final product = MockProducts.products.first;
      await sl<WishlistRepository>().add(product);

      await pumpTestApp(tester, home: const WishlistScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shto në shportë'));
      await tester.pumpAndSettle();

      expect(find.text('Produkti u shtua në shportë.'), findsOneWidget);
    });

    testWidgets('snackbar out of stock', (tester) async {
      await setUpTestDependencies();
      addTearDown(tearDownTestDependencies);

      final product = MockProducts.products.firstWhere((p) => !p.inStock,
          orElse: () => ProductEntity(
                id: 'oos-test',
                name: 'Out',
                brand: 'B',
                categoryId: 'wines',
                categoryName: 'Wines',
                price: 1,
                description: '',
                volume: '750ml',
                type: 'Red',
                rating: 0,
                reviewCount: 0,
                stock: 0,
                isFeatured: false,
              ));

      // Direct OOS through controller snackbar mapping in screen — seed via local
      // wishlist with a controller that returns OOS.
      await pumpTestApp(
        tester,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  final controller = WishlistController(
                    MockGetWishlistItemsUseCase(),
                    MockRemoveFromWishlistUseCase(),
                    MockAddToCartUseCase(),
                  );
                  final result = await controller.addToCart(product);
                  final message = switch (result) {
                    AddToCartResult.success =>
                      'Produkti u shtua në shportë.',
                    AddToCartResult.outOfStock =>
                      'Produkti nuk është në stok.',
                    AddToCartResult.insufficientStock =>
                      'Nuk ka stok të mjaftueshëm.',
                    AddToCartResult.failure =>
                      'Nuk u shtua në shportë. Provo përsëri.',
                  };
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                },
                child: const Text('tap'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Produkti nuk është në stok.'), findsOneWidget);
    });

    testWidgets('snackbar failure', (tester) async {
      await setUpTestDependencies();
      addTearDown(tearDownTestDependencies);

      final getItems = MockGetWishlistItemsUseCase();
      final remove = MockRemoveFromWishlistUseCase();
      final add = MockAddToCartUseCase();
      when(() => add(any())).thenAnswer(
        (_) async => const Error(UnknownFailure(message: 'fail')),
      );

      await pumpTestApp(
        tester,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  final controller = WishlistController(getItems, remove, add);
                  final result = await controller.addToCart(testProductEntity);
                  final message = switch (result) {
                    AddToCartResult.success =>
                      'Produkti u shtua në shportë.',
                    AddToCartResult.outOfStock =>
                      'Produkti nuk është në stok.',
                    AddToCartResult.insufficientStock =>
                      'Nuk ka stok të mjaftueshëm.',
                    AddToCartResult.failure =>
                      'Nuk u shtua në shportë. Provo përsëri.',
                  };
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                },
                child: const Text('tap'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Nuk u shtua në shportë. Provo përsëri.'), findsOneWidget);
      verifyNever(() => remove(any()));
    });
  });
}
