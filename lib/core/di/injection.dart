import 'package:get_it/get_it.dart';

import '../../features/products/data/datasources/product_data_source.dart';
import '../../features/products/data/datasources/product_mock_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_best_seller_products.dart';
import '../../features/products/domain/usecases/get_offer_products.dart';
import '../../features/products/domain/usecases/get_product_by_id.dart';
import '../../features/products/domain/usecases/get_recommended_products.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

bool _dependenciesConfigured = false;

/// Registers application dependencies.
void configureDependencies() {
  if (_dependenciesConfigured) {
    return;
  }

  _registerProducts();
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
  sl.registerLazySingleton(() => GetRecommendedProducts(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetBestSellerProducts(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetOfferProducts(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetProductById(sl<ProductRepository>()));
}

/// Resets registrations — useful for tests.
Future<void> resetDependencies() async {
  await sl.reset();
  _dependenciesConfigured = false;
}
