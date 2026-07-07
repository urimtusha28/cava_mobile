import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/presentation/navigation_badge_controller.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/core/state/wishlist_state_notifier.dart';
import 'package:cava_ecommerce/features/cart/data/local/cart_local_storage.dart';
import 'package:cava_ecommerce/features/cart/data/models/stored_cart_item_model.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/local_wishlist_store.dart';
import 'package:cava_ecommerce/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProductRepository productRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CartLocalStorage().clear();
    LocalWishlistStore.clear();
    CartStateNotifier.reset();
    WishlistStateNotifier.reset();

    productRepository = MockProductRepository();
    when(() => productRepository.getById(any()))
        .thenAnswer((_) async => null);
    when(() => productRepository.getById('p1'))
        .thenAnswer((_) async => testProductEntity);
    when(() => productRepository.getRecommended())
        .thenAnswer((_) async => []);
    when(() => productRepository.getBestSellers())
        .thenAnswer((_) async => []);
    when(() => productRepository.getOffers()).thenAnswer((_) async => []);
    when(() => productRepository.getAll()).thenAnswer((_) async => []);
    when(() => productRepository.getProductsByCategory(any()))
        .thenAnswer((_) async => []);

    await configureTestDependencies(
      productDataSource: MockProductDataSource(),
    );
    if (sl.isRegistered<ProductRepository>()) {
      sl.unregister<ProductRepository>();
    }
    sl.registerLazySingleton<ProductRepository>(() => productRepository);
  });

  tearDown(() async {
    await resetDependencies();
  });

  test('syncBadges hydrates persisted cart count', () async {
    await CartLocalStorage().writeItems([
      const StoredCartItemModel(
        productId: 'p1',
        quantity: 2,
        addedAt: '2026-01-01T00:00:00.000Z',
      ),
    ]);

    await NavigationBadgeController.syncBadges();

    expect(CartStateNotifier.revision.value, 2);
  });
}
