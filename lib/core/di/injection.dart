import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../firebase/firebase_config.dart';
import '../firebase/firebase_functions_gateway.dart';

import '../../features/account/data/datasources/addresses_data_source.dart';
import '../../features/account/data/datasources/addresses_firebase_datasource.dart';
import '../../features/account/data/datasources/addresses_mock_datasource.dart';
import '../../features/account/data/datasources/auth_data_source.dart';
import '../../features/account/data/datasources/auth_firebase_datasource.dart';
import '../../features/account/data/datasources/auth_mock_datasource.dart';
import '../../features/account/data/datasources/orders_data_source.dart';
import '../../features/account/data/datasources/orders_firebase_datasource.dart';
import '../../features/account/data/datasources/orders_mock_datasource.dart';
import '../../features/account/data/firebase/firebase_auth_gateway.dart';
import '../../features/account/data/repositories/addresses_repository_impl.dart';
import '../../features/account/data/repositories/auth_repository_impl.dart';
import '../../features/account/data/repositories/orders_repository_impl.dart';
import '../../features/account/domain/repositories/addresses_repository.dart';
import '../../features/account/domain/repositories/auth_repository.dart';
import '../../features/account/domain/repositories/orders_repository.dart';
import '../../features/account/domain/usecases/address_usecases.dart';
import '../../features/account/domain/usecases/forgot_password.dart';
import '../../features/account/domain/usecases/get_current_user.dart';
import '../../features/account/domain/usecases/get_my_orders.dart';
import '../../features/account/domain/usecases/get_order_by_id.dart';
import '../../features/account/domain/usecases/is_logged_in.dart';
import '../../features/account/domain/usecases/login.dart';
import '../../features/account/domain/usecases/logout.dart';
import '../../features/account/domain/usecases/register.dart';
import '../../features/account/presentation/controllers/addresses_controller.dart';
import '../../features/account/presentation/controllers/auth_controller.dart';
import '../../features/account/presentation/controllers/orders_controller.dart';
import '../../features/cart/data/datasources/cart_firestore_datasource.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/local/cart_local_storage.dart';
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
import '../../features/categories/data/datasources/category_firestore_datasource.dart';
import '../../features/categories/data/datasources/category_mock_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/get_category_by_id.dart';
import '../../features/categories/domain/usecases/get_subcategories.dart';
import '../../features/categories/presentation/controllers/categories_controller.dart';
import '../../features/categories/presentation/controllers/category_products_controller.dart';
import '../../features/checkout/data/datasources/checkout_data_source.dart';
import '../../features/checkout/data/datasources/checkout_firebase_datasource.dart';
import '../../features/checkout/data/firebase/firebase_functions_gateway_impl.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/domain/usecases/place_order.dart';
import '../../features/checkout/presentation/controllers/order_success_controller.dart';
import '../../features/checkout/data/local/checkout_selected_address_storage.dart';
import '../../features/checkout/presentation/controllers/checkout_controller.dart';
import '../../features/home/data/datasources/home_data_source.dart';
import '../../features/home/data/datasources/home_mock_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_sections.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/search/data/local/recent_search_storage.dart';
import '../../features/search/presentation/controllers/search_controller.dart';
import '../../features/products/data/datasources/product_data_source.dart';
import '../../features/products/data/datasources/product_firestore_datasource.dart';
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
import '../../features/wishlist/data/datasources/wishlist_firestore_datasource.dart';
import '../../features/wishlist/data/datasources/wishlist_local_datasource.dart';
import '../../features/wishlist/data/local/wishlist_guest_storage.dart';
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
import '../../features/wishlist/data/local/local_wishlist_store.dart';

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
  _registerAuth();
  _registerCart();
  _registerOrders();
  _registerAddresses();
  _registerCheckout();
  _registerWishlist();
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

  sl.registerLazySingleton<ProductDataSource>(_createProductDataSource);
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductDataSource>()),
  );
}

ProductDataSource _createProductDataSource() {
  if (FirebaseConfig.enabled && FirebaseConfig.useFirestoreProducts) {
    return ProductFirestoreDataSource(FirebaseFirestore.instance);
  }
  return const ProductMockDataSource();
}

void _registerCategories() {
  if (sl.isRegistered<CategoryRepository>()) {
    return;
  }

  sl.registerLazySingleton<CategoryDataSource>(_createCategoryDataSource);
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryDataSource>()),
  );
}

CategoryDataSource _createCategoryDataSource() {
  if (FirebaseConfig.enabled && FirebaseConfig.useFirestoreCategories) {
    return CategoryFirestoreDataSource(FirebaseFirestore.instance);
  }
  return const CategoryMockDataSource();
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

void _registerCart({FirebaseFirestore? firestoreOverride}) {
  if (sl.isRegistered<CartRepository>()) {
    return;
  }

  sl.registerLazySingleton<CartLocalStorage>(() => CartLocalStorage());
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSource(
      sl<CartLocalStorage>(),
      sl<ProductRepository>(),
    ),
  );
  sl.registerLazySingleton<CartFirestoreDataSource>(
    () => CartFirestoreDataSource(
      firestoreOverride ?? FirebaseFirestore.instance,
      sl<AuthRepository>(),
      sl<ProductRepository>(),
    ),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      sl<CartLocalDataSource>(),
      sl<CartFirestoreDataSource>(),
      sl<AuthRepository>(),
    ),
  );
}

void _registerWishlist({FirebaseFirestore? firestoreOverride}) {
  if (sl.isRegistered<WishlistRepository>()) {
    return;
  }

  sl.registerLazySingleton<WishlistGuestStorage>(() => WishlistGuestStorage());
  sl.registerLazySingleton<WishlistLocalDataSource>(
    () => WishlistLocalDataSource(
      sl<WishlistGuestStorage>(),
      sl<ProductRepository>(),
    ),
  );
  sl.registerLazySingleton<WishlistFirestoreDataSource>(
    () => WishlistFirestoreDataSource(
      firestoreOverride ?? FirebaseFirestore.instance,
      sl<AuthRepository>(),
      sl<ProductRepository>(),
    ),
  );
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(
      sl<WishlistLocalDataSource>(),
      sl<WishlistFirestoreDataSource>(),
      sl<AuthRepository>(),
    ),
  );
}

void _registerAuth() {
  if (sl.isRegistered<AuthRepository>()) {
    return;
  }

  sl.registerLazySingleton<AuthDataSource>(_createAuthDataSource);
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthDataSource>()),
  );
}

AuthDataSource _createAuthDataSource() {
  if (FirebaseConfig.enabled && FirebaseConfig.useFirebaseAuth) {
    return AuthFirebaseDataSource(
      FirebaseAuthGatewayImpl(FirebaseAuth.instance),
      FirebaseFirestore.instance,
    );
  }
  return const AuthMockDataSource();
}

void _registerOrders() {
  if (sl.isRegistered<OrdersRepository>()) {
    return;
  }

  sl.registerLazySingleton<OrdersDataSource>(_createOrdersDataSource);
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<OrdersDataSource>(), sl<AuthRepository>()),
  );
}

OrdersDataSource _createOrdersDataSource() {
  if (FirebaseConfig.enabled && FirebaseConfig.useFirestoreOrders) {
    return OrdersFirebaseDataSource(FirebaseFirestore.instance);
  }
  return const OrdersMockDataSource();
}

void _registerAddresses() {
  if (sl.isRegistered<AddressesRepository>()) {
    return;
  }

  sl.registerLazySingleton<AddressesDataSource>(_createAddressesDataSource);
  sl.registerLazySingleton<AddressesRepository>(
    () => AddressesRepositoryImpl(
      sl<AddressesDataSource>(),
      sl<AuthRepository>(),
    ),
  );
}

AddressesDataSource _createAddressesDataSource() {
  if (FirebaseConfig.enabled && FirebaseConfig.useFirestoreAddresses) {
    return AddressesFirebaseDataSource(FirebaseFirestore.instance);
  }
  return AddressesMockDataSource();
}

void _registerCheckout() {
  if (sl.isRegistered<CheckoutRepository>()) {
    return;
  }

  sl.registerLazySingleton<CheckoutSelectedAddressStorage>(
    () => CheckoutSelectedAddressStorage(),
  );
  sl.registerLazySingleton<FirebaseFunctionsGateway>(
    () => FirebaseFunctionsGatewayImpl(FirebaseFunctions.instance),
  );
  sl.registerLazySingleton<CheckoutDataSource>(
    () => CheckoutFirebaseDataSource(sl<FirebaseFunctionsGateway>()),
  );
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      sl<CheckoutDataSource>(),
      sl<AuthRepository>(),
      sl<AddressesRepository>(),
      sl<CartRepository>(),
    ),
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

  // Search
  sl.registerLazySingleton<RecentSearchStorage>(() => RecentSearchStorage());
  sl.registerFactory<SearchController>(
    () => SearchController(
      sl<GetAllProductsUseCase>(),
      sl<RecentSearchStorage>(),
    ),
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

  // Checkout
  sl.registerFactory<PlaceOrderUseCase>(
    () => PlaceOrderUseCase(sl<CheckoutRepository>()),
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
  sl.registerFactory<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));

  // Orders & Addresses
  sl.registerFactory<GetMyOrdersUseCase>(
    () => GetMyOrdersUseCase(sl<OrdersRepository>()),
  );
  sl.registerFactory<GetOrderByIdUseCase>(
    () => GetOrderByIdUseCase(sl<OrdersRepository>()),
  );
  sl.registerFactory<GetAddressesUseCase>(
    () => GetAddressesUseCase(sl<AddressesRepository>()),
  );
  sl.registerFactory<AddAddressUseCase>(
    () => AddAddressUseCase(sl<AddressesRepository>()),
  );
  sl.registerFactory<UpdateAddressUseCase>(
    () => UpdateAddressUseCase(sl<AddressesRepository>()),
  );
  sl.registerFactory<DeleteAddressUseCase>(
    () => DeleteAddressUseCase(sl<AddressesRepository>()),
  );
  sl.registerFactory<SetDefaultAddressUseCase>(
    () => SetDefaultAddressUseCase(sl<AddressesRepository>()),
  );
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
    () => ProductDetailController(sl(), sl(), sl(), sl()),
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
    () => AuthController(sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<OrdersController>(
    () => OrdersController(sl(), sl()),
  );
  sl.registerFactory<AddressesController>(
    () => AddressesController(sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<OrderSuccessController>(
    () => OrderSuccessController(sl<GetOrderByIdUseCase>()),
  );
  sl.registerFactory<CheckoutController>(
    () => CheckoutController(
      sl<CartController>(),
      sl<PlaceOrderUseCase>(),
      sl<ClearCartUseCase>(),
      sl<IsLoggedInUseCase>(),
      sl<GetAddressesUseCase>(),
      sl<GetCurrentUserUseCase>(),
      sl<CheckoutSelectedAddressStorage>(),
    ),
  );
}

/// Resets all registrations and ephemeral global state — use in test tearDown.
Future<void> resetDependencies() async {
  if (sl.isRegistered<CartLocalDataSource>()) {
    try {
      sl<CartLocalDataSource>().resetForTests();
    } catch (_) {
      // Cart datasource not instantiated yet.
    }
  }

  if (sl.isRegistered<WishlistLocalDataSource>()) {
    try {
      sl<WishlistLocalDataSource>().resetForTests();
    } catch (_) {
      // Wishlist datasource not instantiated yet.
    }
  }

  await sl.reset(dispose: true);
  _dependenciesConfigured = false;
  CartStateNotifier.reset();
  WishlistStateNotifier.reset();
  LocalWishlistStore.clear();
  try {
    await CartLocalStorage().clear();
  } catch (_) {
    // SharedPreferences may be unavailable before Flutter binding init.
  }
  try {
    await CheckoutSelectedAddressStorage().clear();
  } catch (_) {
    // SharedPreferences may be unavailable before Flutter binding init.
  }
  try {
    await WishlistGuestStorage().clear();
  } catch (_) {
    // SharedPreferences may be unavailable before Flutter binding init.
  }
  AuthStateNotifier.reset();
}

/// Registers dependencies with optional datasource overrides for tests.
Future<void> configureTestDependencies({
  ProductDataSource? productDataSource,
  CategoryDataSource? categoryDataSource,
  HomeDataSource? homeDataSource,
  WishlistDataSource? wishlistDataSource,
  AuthDataSource? authDataSource,
  OrdersDataSource? ordersDataSource,
  AddressesDataSource? addressesDataSource,
  CheckoutDataSource? checkoutDataSource,
  FirebaseFirestore? cartFirestore,
  FirebaseFirestore? wishlistFirestore,
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

  if (authDataSource != null) {
    sl.registerLazySingleton<AuthDataSource>(() => authDataSource);
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthDataSource>()),
    );
  } else {
    sl.registerLazySingleton<AuthDataSource>(() => const AuthMockDataSource());
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthDataSource>()),
    );
  }

  _registerCart(firestoreOverride: cartFirestore);

  if (wishlistDataSource != null) {
    sl.registerLazySingleton<WishlistGuestStorage>(() => WishlistGuestStorage());
    if (wishlistDataSource is WishlistLocalDataSource) {
      sl.registerLazySingleton<WishlistLocalDataSource>(() => wishlistDataSource);
    } else {
      sl.registerLazySingleton<WishlistLocalDataSource>(
        () => WishlistLocalDataSource(
          sl<WishlistGuestStorage>(),
          sl<ProductRepository>(),
        ),
      );
    }
    sl.registerLazySingleton<WishlistFirestoreDataSource>(
      () => WishlistFirestoreDataSource(
        wishlistFirestore ?? FirebaseFirestore.instance,
        sl<AuthRepository>(),
        sl<ProductRepository>(),
      ),
    );
    sl.registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(
        sl<WishlistLocalDataSource>(),
        sl<WishlistFirestoreDataSource>(),
        sl<AuthRepository>(),
      ),
    );
  } else {
    _registerWishlist(firestoreOverride: wishlistFirestore);
  }

  if (ordersDataSource != null) {
    sl.registerLazySingleton<OrdersDataSource>(() => ordersDataSource);
    sl.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(sl<OrdersDataSource>(), sl<AuthRepository>()),
    );
  } else {
    sl.registerLazySingleton<OrdersDataSource>(() => const OrdersMockDataSource());
    sl.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(sl<OrdersDataSource>(), sl<AuthRepository>()),
    );
  }

  if (addressesDataSource != null) {
    sl.registerLazySingleton<AddressesDataSource>(() => addressesDataSource);
    sl.registerLazySingleton<AddressesRepository>(
      () => AddressesRepositoryImpl(
        sl<AddressesDataSource>(),
        sl<AuthRepository>(),
      ),
    );
  } else {
    sl.registerLazySingleton<AddressesDataSource>(AddressesMockDataSource.new);
    sl.registerLazySingleton<AddressesRepository>(
      () => AddressesRepositoryImpl(
        sl<AddressesDataSource>(),
        sl<AuthRepository>(),
      ),
    );
  }

  if (checkoutDataSource != null) {
    if (!sl.isRegistered<CheckoutSelectedAddressStorage>()) {
      sl.registerLazySingleton<CheckoutSelectedAddressStorage>(
        () => CheckoutSelectedAddressStorage(),
      );
    }
    sl.registerLazySingleton<CheckoutDataSource>(() => checkoutDataSource);
    sl.registerLazySingleton<CheckoutRepository>(
      () => CheckoutRepositoryImpl(
        sl<CheckoutDataSource>(),
        sl<AuthRepository>(),
        sl<AddressesRepository>(),
        sl<CartRepository>(),
      ),
    );
  } else {
    _registerCheckout();
  }

  _registerControllers();
  _dependenciesConfigured = true;
}
