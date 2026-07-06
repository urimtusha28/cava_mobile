import '../../../../core/di/injection.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/presentation/products_module.dart';
import '../../domain/entities/category_entity.dart';
import '../mock/mock_categories.dart';

/// Backward-compatible adapter for screens still using [CatalogFacade].
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

class CategoryRepository {
  List<CategoryEntity> getAll() => MockCategories.categories;

  CategoryEntity? getById(String id) {
    try {
      return MockCategories.categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

class CatalogFacade {
  CatalogFacade()
      : categories = CategoryRepository(),
        products = CatalogProductRepository();

  final CategoryRepository categories;
  final CatalogProductRepository products;
}
