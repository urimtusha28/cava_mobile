import '../../../products/data/mock/mock_products.dart';
import '../../domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../mock/mock_categories.dart';

class ProductRepository {
  List<ProductEntity> getFeaturedProducts() =>
      MockProducts.products.where((p) => p.isFeatured).toList();

  List<ProductEntity> getRecommended() => getFeaturedProducts();

  List<ProductEntity> getBestSellers() {
    final list = List<ProductEntity>.from(MockProducts.products);
    list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return list.take(8).toList();
  }

  List<ProductEntity> getOffers() =>
      MockProducts.products.where((p) => p.oldPrice != null).toList();

  List<ProductEntity> getProductsByCategory(String categoryId) =>
      MockProducts.products.where((p) => p.categoryId == categoryId).toList();

  List<ProductEntity> getAll() => List<ProductEntity>.from(MockProducts.products);

  ProductEntity? getById(String id) {
    try {
      return MockProducts.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
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
        products = ProductRepository();

  final CategoryRepository categories;
  final ProductRepository products;
}
