import '../../../core/di/injection.dart';
import '../../../core/result/result.dart';
import '../domain/entities/product_entity.dart';
import '../domain/usecases/get_best_seller_products.dart';
import '../domain/usecases/get_offer_products.dart';
import '../domain/usecases/get_recommended_products.dart';
import 'products_module.dart';

/// Resolves home product lists through use cases without touching UI layout.
abstract final class HomeProductsQuery {
  static List<ProductEntity> recommended() {
    ProductsModule.ensureInitialized();
    return _unwrap(sl<GetRecommendedProducts>().call());
  }

  static List<ProductEntity> bestSellers() {
    ProductsModule.ensureInitialized();
    return _unwrap(sl<GetBestSellerProducts>().call());
  }

  static List<ProductEntity> offers() {
    ProductsModule.ensureInitialized();
    return _unwrap(sl<GetOfferProducts>().call());
  }

  static List<ProductEntity> _unwrap(Result<List<ProductEntity>> result) {
    return result.fold(
      onSuccess: (data) => data,
      onFailure: (_) => const [],
    );
  }
}
