import 'package:get_it/get_it.dart';

import '../../features/account/data/datasources/auth_data_source.dart';
import '../../features/account/data/datasources/auth_mock_datasource.dart';
import '../../features/account/data/repositories/auth_repository_impl.dart';
import '../../features/account/domain/repositories/auth_repository.dart';
import '../../features/account/domain/usecases/is_logged_in.dart';
import '../../features/account/domain/usecases/login.dart';
import '../../features/account/domain/usecases/logout.dart';
import '../../features/cart/data/datasources/cart_data_source.dart';
import '../../features/cart/data/datasources/cart_mock_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/domain/usecases/get_cart_count.dart';
import '../../features/cart/domain/usecases/get_cart_items.dart';
import '../../features/cart/domain/usecases/remove_from_cart.dart';
import '../../features/cart/domain/usecases/update_cart_quantity.dart';
import '../../features/categories/data/datasources/category_data_source.dart';
import '../../features/categories/data/datasources/category_mock_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/get_category_by_id.dart';
import '../../features/categories/domain/usecases/get_subcategories.dart';
import '../../features/home/data/datasources/home_data_source.dart';
import '../../features/home/data/datasources/home_mock_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_sections.dart';
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
import '../../features/wishlist/data/datasources/wishlist_data_source.dart';
import '../../features/wishlist/data/datasources/wishlist_mock_datasource.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/domain/usecases/get_wishlist_count.dart';
import '../../features/wishlist/domain/usecases/get_wishlist_items.dart';
import '../../features/wishlist/domain/usecases/is_in_wishlist.dart';
import '../../features/wishlist/domain/usecases/remove_from_wishlist.dart';
import '../../features/wishlist/domain/usecases/toggle_wishlist.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

bool _dependenciesConfigured = false;

/// Registers application dependencies.
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
  _dependenciesConfigured = true;
}

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
  sl.registerLazySingleton(
    () => GetRecommendedProducts(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => GetBestSellerProducts(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(() => GetOfferProducts(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetProductById(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetAllProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(
    () => GetProductsByCategoryUseCase(sl<ProductRepository>()),
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
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<CategoryRepository>()));
  sl.registerLazySingleton(
    () => GetCategoryByIdUseCase(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton(
    () => GetSubcategoriesUseCase(sl<CategoryRepository>()),
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
  sl.registerLazySingleton(() => GetHomeSectionsUseCase(sl<HomeRepository>()));
}

void _registerCart() {
  if (sl.isRegistered<CartRepository>()) {
    return;
  }

  sl.registerLazySingleton<CartDataSource>(() => const CartMockDataSource());
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartDataSource>()),
  );
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(
    () => UpdateCartQuantityUseCase(sl<CartRepository>()),
  );
  sl.registerLazySingleton(() => ClearCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => GetCartCountUseCase(sl<CartRepository>()));
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
  sl.registerLazySingleton(
    () => GetWishlistItemsUseCase(sl<WishlistRepository>()),
  );
  sl.registerLazySingleton(
    () => ToggleWishlistUseCase(sl<WishlistRepository>()),
  );
  sl.registerLazySingleton(
    () => RemoveFromWishlistUseCase(sl<WishlistRepository>()),
  );
  sl.registerLazySingleton(
    () => IsInWishlistUseCase(sl<WishlistRepository>()),
  );
  sl.registerLazySingleton(
    () => GetWishlistCountUseCase(sl<WishlistRepository>()),
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
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
}

/// Resets registrations — useful for tests.
Future<void> resetDependencies() async {
  await sl.reset();
  _dependenciesConfigured = false;
}
