import '../../../core/di/injection.dart';
import '../../../core/result/result.dart';
import '../../products/domain/entities/product_entity.dart';
import '../../products/domain/usecases/get_all_products.dart';
import '../../products/domain/usecases/get_products_by_category.dart';
import '../domain/entities/category_entity.dart';
import '../domain/entities/subcategory_entity.dart';
import '../domain/usecases/get_category_by_id.dart';
import '../domain/usecases/get_subcategories.dart';
import 'categories_module.dart';

abstract final class CategoryProductsQuery {
  static CategoryEntity? categoryById(String categoryId) {
    if (categoryId == 'all') {
      return null;
    }
    CategoriesModule.ensureInitialized();
    return sl<GetCategoryByIdUseCase>().call(categoryId).fold(
          onSuccess: (category) => category,
          onFailure: (_) => null,
        );
  }

  static List<ProductEntity> productsFor(String categoryId) {
    CategoriesModule.ensureInitialized();
    if (categoryId == 'all') {
      return _unwrapProducts(sl<GetAllProductsUseCase>().call());
    }
    return _unwrapProducts(
      sl<GetProductsByCategoryUseCase>().call(categoryId),
    );
  }

  static List<SubcategoryEntity> subcategoriesFor(String categoryId) {
    if (categoryId == 'all') {
      return const [SubcategoryEntity(id: 'all', label: 'All Products')];
    }
    CategoriesModule.ensureInitialized();
    return sl<GetSubcategoriesUseCase>().call(categoryId).fold(
          onSuccess: (data) => data,
          onFailure: (_) => const [],
        );
  }

  static List<ProductEntity> _unwrapProducts(
    Result<List<ProductEntity>> result,
  ) {
    return result.fold(
      onSuccess: (data) => data,
      onFailure: (_) => const [],
    );
  }
}
