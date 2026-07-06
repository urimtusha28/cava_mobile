import '../../../../core/di/injection.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/presentation/products_module.dart';

/// Deprecated backward-compatible adapter.
///
/// Prefer [ProductRepository] via DI or presentation query helpers.
/// Kept for any legacy imports outside Phase 3 scope.
@Deprecated('Use ProductRepository via DI or CategoryProductsQuery')
class CatalogProductRepository {
  CatalogProductRepository() {
    ProductsModule.ensureInitialized();
  }

  ProductRepository get _repository => sl<ProductRepository>();

  List<ProductEntity> getFeaturedProducts() => _repository.getRecommended();

  List<ProductEntity> getRecommended() => _repository.getRecommended();

  List<ProductEntity> getBestSellers() => _repository.getBestSellers();

  List<ProductEntity> getOffers() => _repository.getOffers();

  List<ProductEntity> getProductsByCategory(String categoryId) =>
      _repository.getProductsByCategory(categoryId);

  List<ProductEntity> getAll() => _repository.getAll();

  ProductEntity? getById(String id) => _repository.getById(id);
}

/// Deprecated facade — no longer used by Home or Categories screens.
@Deprecated('Use domain repositories and query helpers via DI')
class CatalogFacade {
  CatalogFacade() : products = CatalogProductRepository();

  final CatalogProductRepository products;
}
