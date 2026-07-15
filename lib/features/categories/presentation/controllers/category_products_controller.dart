import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/usecases/get_all_products.dart';
import '../../../products/domain/usecases/get_products_by_category.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/usecases/get_category_by_id.dart';
import '../../domain/usecases/get_subcategories.dart';

class CategoryProductsController extends BaseController {
  CategoryProductsController(
    this._getCategoryById,
    this._getSubcategories,
    this._getAllProducts,
    this._getProductsByCategory,
  );

  final GetCategoryByIdUseCase _getCategoryById;
  final GetSubcategoriesUseCase _getSubcategories;
  final GetAllProductsUseCase _getAllProducts;
  final GetProductsByCategoryUseCase _getProductsByCategory;

  CategoryEntity? category;
  List<ProductEntity> products = const [];
  List<SubcategoryEntity> subcategories = const [];

  Future<void> load(String categoryId) {
    return runLoad(() async {
      if (categoryId == 'all') {
        category = null;
        subcategories = const [
          SubcategoryEntity(id: 'all', label: ''),
        ];
        products = await unwrapFutureResult(
          _getAllProducts(),
          fallback: const [],
        );
        return;
      }

      category = await unwrapFutureResult(
        _getCategoryById(categoryId),
        fallback: null,
      );

      final productCategoryKey = category?.name ?? categoryId;

      products = await unwrapFutureResult(
        _getProductsByCategory(productCategoryKey),
        fallback: const [],
      );
      subcategories = await unwrapFutureResult(
        _getSubcategories(categoryId),
        fallback: const [],
      );
    });
  }
}

CategoryProductsController createCategoryProductsController() {
  configureDependencies();
  return sl<CategoryProductsController>();
}
