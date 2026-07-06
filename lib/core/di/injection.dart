import 'package:get_it/get_it.dart';

import '../../features/account/data/datasources/auth_data_source.dart';
import '../../features/account/data/datasources/auth_mock_datasource.dart';
import '../../features/account/data/repositories/auth_repository_impl.dart';
import '../../features/account/domain/repositories/auth_repository.dart';
import '../../features/account/domain/usecases/is_logged_in.dart';
import '../../features/account/domain/usecases/login.dart';
import '../../features/account/domain/usecases/logout.dart';
import '../../features/account/presentation/controllers/auth_controller.dart';
import '../../features/cart/data/datasources/cart_data_source.dart';
import '../../features/cart/data/datasources/cart_mock_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/domain/usecases/get_cart_count.dart';
import '../../features/cart/domain/usecases/get_cart_items.dart';
import '../../features/cart/domain/usecases/get_cart_summary.dart';
import '../../features/cart/domain/usecases/remove_from_cart.dart';
import '../../features/cart/domain/usecases/update_cart_quantity.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/categories/data/datasources/category_data_source.dart';
import '../../features/categories/data/datasources/category_mock_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/get_category_by_id.dart';
import '../../features/categories/domain/usecases/get_subcategories.dart';
import '../../features/categories/presentation/controllers/categories_controller.dart';
import '../../features/categories/presentation/controllers/category_products_controller.dart';
import '../../features/checkout/presentation/controllers/checkout_controller.dart';
import '../../features/home/data/datasources/home_data_source.dart';
import '../../features/home/data/datasources/home_mock_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_sections.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/products/data/datasources/product_data_source.dart';
import '../../features/products/data/datasources/product_mock_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_all_products.dart';
import '../../features/products/domain/usecases/get_best_seller_products.dart';
import '../../features/products/domain/usecases/get_offer_products.dart';
import '../../features/products/domain/usecases/get_product_by_id.dart';
import '../../features/products/domain/usecases/get_products_by_category.dart';
import '../../features/products/domain/usecases/get_recommended_products.dart';
import '../../features/products/presentation/controllers/product_detail_controller.dart';
import '../../features/wishlist/data/datasources/wishlist_data_source.dart';
import '../../features/wishlist/data/datasources/wishlist_mock_datasource.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/domain/usecases/get_wishlist_count.dart';
import '../../features/wishlist/domain/usecases/get_wishlist_items.dart';
import '../../features/wishlist/domain/usecases/is_in_wishlist.dart';
import '../../features/wishlist/domain/usecases/remove_from_wishlist.dart';
import '../../features/wishlist/domain/usecases/toggle_wishlist.dart';
import '../../features/wishlist/presentation/controllers/wishlist_controller.dart';
import '../state/auth_state_notifier.dart';
import '../state/cart_state_notifier.dart';
import '../state/wishlist_state_notifier.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

bool _dependenciesConfigured = false;

/// Registers application dependencies (idempotent).
void configureDependencies() {
  if (_dependenciesConfigured) {
    return;
  }

  _registerProducts();
  _registerCategories();
  _registerHome();
  _registerCart();
  _registerWishlist();
  _registerAuth();
  _registerControllers();
  _dependenciesConfigured = true;
}

// ---------------------------------------------------------------------------
// Data layer — LazySingleton (shared state / single datasource instance)
// ---------------------------------------------------------------------------

void _registerProducts() {
  if (sl.isRegistered<ProductRepository>()) {
    return;
  }

  sl.registerLazySingleton<ProductDataSource>(
    () => const ProductMockDataSource(),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductDataSource>()),
  );
}

void _registerCategories() {
  if (sl.isRegistered<CategoryRepository>()) {
    return;
  }

  sl.registerLazySingleton<CategoryDataSource>(
    () => const CategoryMockDataSource(),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryDataSource>()),
  );
}

void _registerHome() {
  if (sl.isRegistered<HomeRepository>()) {
    return;
  }

  sl.registerLazySingleton<HomeDataSource>(() => const HomeMockDataSource());
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeDataSource>(), sl<ProductRepository>()),
  );
}

void _registerCart() {
  if (sl.isRegistered<CartRepository>()) {
    return;
  }

  sl.registerLazySingleton<CartDataSource>(() => const CartMockDataSource());
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartDataSource>()),
  );
}

void _registerWishlist() {
  if (sl.isRegistered<WishlistRepository>()) {
    return;
  }

  sl.registerLazySingleton<WishlistDataSource>(
    () => const WishlistMockDataSource(),
  );
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(sl<WishlistDataSource>()),
  );
}

void _registerAuth() {
  if (sl.isRegistered<AuthRepository>()) {
    return;
  }

  sl.registerLazySingleton<AuthDataSource>(() => const AuthMockDataSource());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthDataSource>()),
  );
}

// ---------------------------------------------------------------------------
// Domain layer — Factory (stateless, new instance per resolve)
// ---------------------------------------------------------------------------

void _registerUseCases() {
  if (sl.isRegistered<GetRecommendedProducts>()) {
    return;
  }

  // Products
  sl.registerFactory<GetRecommendedProducts>(
    () => GetRecommendedProducts(sl<ProductRepository>()),
  );
  sl.registerFactory<GetBestSellerProducts>(
    () => GetBestSellerProducts(sl<ProductRepository>()),
  );
  sl.registerFactory<GetOfferProducts>(
    () => GetOfferProducts(sl<ProductRepository>()),
  );
  sl.registerFactory<GetProductById>(
    () => GetProductById(sl<ProductRepository>()),
  );
  sl.registerFactory<GetAllProductsUseCase>(
    () => GetAllProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerFactory<GetProductsByCategoryUseCase>(
    () => GetProductsByCategoryUseCase(sl<ProductRepository>()),
  );

  // Categories
  sl.registerFactory<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<CategoryRepository>()),
  );
  sl.registerFactory<GetCategoryByIdUseCase>(
    () => GetCategoryByIdUseCase(sl<CategoryRepository>()),
  );
  sl.registerFactory<GetSubcategoriesUseCase>(
    () => GetSubcategoriesUseCase(sl<CategoryRepository>()),
  );

  // Home
  sl.registerFactory<GetHomeSectionsUseCase>(
    () => GetHomeSectionsUseCase(sl<HomeRepository>()),
  );

  // Cart
  sl.registerFactory<GetCartItemsUseCase>(
    () => GetCartItemsUseCase(sl<CartRepository>()),
  );
  sl.registerFactory<GetCartSummaryUseCase>(
    () => GetCartSummaryUseCase(sl<CartRepository>()),
  );
  sl.registerFactory<AddToCartUseCase>(
    () => AddToCartUseCase(sl<CartRepository>()),
  );
  sl.registerFactory<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(sl<CartRepository>()),
  );
  sl.registerFactory<UpdateCartQuantityUseCase>(
    () => UpdateCartQuantityUseCase(sl<CartRepository>()),
  );
  sl.registerFactory<ClearCartUseCase>(
    () => ClearCartUseCase(sl<CartRepository>()),
  );
  sl.registerFactory<GetCartCountUseCase>(
    () => GetCartCountUseCase(sl<CartRepository>()),
  );

  // Wishlist
  sl.registerFactory<GetWishlistItemsUseCase>(
    () => GetWishlistItemsUseCase(sl<WishlistRepository>()),
  );
  sl.registerFactory<ToggleWishlistUseCase>(
    () => ToggleWishlistUseCase(sl<WishlistRepository>()),
  );
  sl.registerFactory<RemoveFromWishlistUseCase>(
    () => RemoveFromWishlistUseCase(sl<WishlistRepository>()),
  );
  sl.registerFactory<IsInWishlistUseCase>(
    () => IsInWishlistUseCase(sl<WishlistRepository>()),
  );
  sl.registerFactory<GetWishlistCountUseCase>(
    () => GetWishlistCountUseCase(sl<WishlistRepository>()),
  );

  // Auth
  sl.registerFactory<IsLoggedInUseCase>(
    () => IsLoggedInUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));
}

// ---------------------------------------------------------------------------
// Presentation layer — Factory (ChangeNotifier, scoped to screen lifecycle)
// ---------------------------------------------------------------------------

void _registerControllers() {
  _registerUseCases();

  if (sl.isRegistered<HomeController>()) {
    return;
  }

  sl.registerFactory<HomeController>(
    () => HomeController(sl(), sl()),
  );
  sl.registerFactory<ProductDetailController>(
    () => ProductDetailController(sl()),
  );
  sl.registerFactory<CategoriesController>(
    () => CategoriesController(sl()),
  );
  sl.registerFactory<CategoryProductsController>(
    () => CategoryProductsController(sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<CartController>(
    () => CartController(sl(), sl(), sl()),
  );
  sl.registerFactory<WishlistController>(
    () => WishlistController(sl(), sl(), sl()),
  );
  sl.registerFactory<AuthController>(
    () => AuthController(sl(), sl(), sl()),
  );
  sl.registerFactory<CheckoutController>(
    () => CheckoutController(sl<CartController>()),
  );
}

/// Resets all registrations and ephemeral global state — use in test tearDown.
Future<void> resetDependencies() async {
  await sl.reset(dispose: true);
  _dependenciesConfigured = false;
  CartStateNotifier.reset();
  WishlistStateNotifier.reset();
  AuthStateNotifier.reset();
}

/// Registers dependencies with optional datasource overrides for tests.
Future<void> configureTestDependencies({
  ProductDataSource? productDataSource,
  CategoryDataSource? categoryDataSource,
  HomeDataSource? homeDataSource,
  CartDataSource? cartDataSource,
  WishlistDataSource? wishlistDataSource,
  AuthDataSource? authDataSource,
}) async {
  await resetDependencies();

  if (productDataSource != null) {
    sl.registerLazySingleton<ProductDataSource>(() => productDataSource);
    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ProductDataSource>()),
    );
  } else {
    _registerProducts();
  }

  if (categoryDataSource != null) {
    sl.registerLazySingleton<CategoryDataSource>(() => categoryDataSource);
    sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl<CategoryDataSource>()),
    );
  } else {
    _registerCategories();
  }

  if (homeDataSource != null) {
    sl.registerLazySingleton<HomeDataSource>(() => homeDataSource);
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(sl<HomeDataSource>(), sl<ProductRepository>()),
    );
  } else {
    _registerHome();
  }

  if (cartDataSource != null) {
    sl.registerLazySingleton<CartDataSource>(() => cartDataSource);
    sl.registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(sl<CartDataSource>()),
    );
  } else {
    _registerCart();
  }

  if (wishlistDataSource != null) {
    sl.registerLazySingleton<WishlistDataSource>(() => wishlistDataSource);
    sl.registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(sl<WishlistDataSource>()),
    );
  } else {
    _registerWishlist();
  }

  if (authDataSource != null) {
    sl.registerLazySingleton<AuthDataSource>(() => authDataSource);
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthDataSource>()),
    );
  } else {
    _registerAuth();
  }

  _registerControllers();
  _dependenciesConfigured = true;
}
