import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:cava_ecommerce/features/account/domain/repositories/auth_repository.dart';
import 'package:cava_ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:cava_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:cava_ecommerce/features/cart/presentation/controllers/cart_controller.dart';
import 'package:cava_ecommerce/features/categories/data/repositories/category_repository_impl.dart';
import 'package:cava_ecommerce/features/categories/domain/repositories/category_repository.dart';
import 'package:cava_ecommerce/features/home/data/repositories/home_repository_impl.dart';
import 'package:cava_ecommerce/features/home/domain/repositories/home_repository.dart';
import 'package:cava_ecommerce/features/home/presentation/controllers/home_controller.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_data_source.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:cava_ecommerce/features/products/domain/repositories/product_repository.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_recommended_products.dart';
import 'package:cava_ecommerce/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:cava_ecommerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_di.dart';

void main() {
  tearDown(tearDownTestDependencies);

  group('configureDependencies', () {
    test('registers ProductMockDataSource in tests via override', () async {
      await setUpTestDependencies();
      expect(sl<ProductDataSource>(), isA<ProductMockDataSource>());
    });

    test('Firebase flags enable Firestore products in DI wiring', () {
      expect(FirebaseConfig.enabled, isTrue);
      expect(FirebaseConfig.useFirestoreProducts, isTrue);
      expect(FirebaseConfig.fallbackToMockProductsOnError, isFalse);
    });

    test('registers datasources as LazySingleton', () async {
      await setUpTestDependencies();
      expect(sl<ProductRepository>(), same(sl<ProductRepository>()));
      expect(sl<ProductRepository>(), isA<ProductRepositoryImpl>());
    });

    test('registers use cases as Factory', () async {
      await setUpTestDependencies();
      expect(sl<GetRecommendedProducts>(), isA<GetRecommendedProducts>());
      expect(sl<GetRecommendedProducts>(), isNot(same(sl<GetRecommendedProducts>())));
    });

    test('registers controllers as Factory', () async {
      await setUpTestDependencies();
      expect(sl<HomeController>(), isA<HomeController>());
      expect(sl<HomeController>(), isNot(same(sl<HomeController>())));
    });

    test('is idempotent', () async {
      await setUpTestDependencies();
      configureDependencies();
      configureDependencies();
      expect(sl<CartRepository>(), isA<CartRepositoryImpl>());
    });

    test('links repository interfaces to implementations', () async {
      await setUpTestDependencies();
      expect(sl<CategoryRepository>(), isA<CategoryRepositoryImpl>());
      expect(sl<HomeRepository>(), isA<HomeRepositoryImpl>());
      expect(sl<CartRepository>(), isA<CartRepositoryImpl>());
      expect(sl<WishlistRepository>(), isA<WishlistRepositoryImpl>());
      expect(sl<AuthRepository>(), isA<AuthRepositoryImpl>());
    });
  });

  group('resetDependencies', () {
    test('clears registrations and allows reconfigure', () async {
      await setUpTestDependencies();
      final first = sl<CartController>();
      await resetDependencies();
      configureDependencies();
      final second = sl<CartController>();
      expect(first, isNot(same(second)));
    });
  });
}
