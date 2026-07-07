import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/subcategory_entity.dart';
import '../../../categories/domain/usecases/get_category_by_id.dart';
import '../../../categories/domain/usecases/get_subcategories.dart';
import '../../../categories/presentation/utils/category_product_badge_resolver.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id.dart';

class ProductDetailController extends BaseController {
  ProductDetailController(
    this._getProductById,
    this._getCategoryById,
    this._getSubcategories,
  );

  final GetProductById _getProductById;
  final GetCategoryByIdUseCase _getCategoryById;
  final GetSubcategoriesUseCase _getSubcategories;

  ProductEntity? product;
  CategoryEntity? category;
  SubcategoryEntity? productSubcategory;
  String categoryBadgeLabel = '';

  Future<void> load(String productId) {
    return runLoad(() async {
      product = await unwrapFutureResult(
        _getProductById(productId),
        fallback: null,
      );
      category = null;
      productSubcategory = null;
      categoryBadgeLabel = '';

      if (product != null) {
        category = await unwrapFutureResult(
          _getCategoryById(product!.categoryId),
          fallback: null,
        );
        final subcategories = await unwrapFutureResult(
          _getSubcategories(product!.categoryId),
          fallback: const <SubcategoryEntity>[],
        );
        productSubcategory = CategoryProductBadgeResolver.findSubcategory(
          product!,
          subcategories,
        );
        categoryBadgeLabel = CategoryProductBadgeResolver.resolveLabel(
          product: product!,
          mainCategory: category,
          subcategory: productSubcategory,
        );
      }
    });
  }
}

ProductDetailController createProductDetailController() {
  configureDependencies();
  return sl<ProductDetailController>();
}
