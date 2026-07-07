import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../cart/domain/add_to_cart_result.dart';
import '../../../cart/domain/usecases/add_to_cart.dart';
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
    this._addToCart,
  );

  final GetProductById _getProductById;
  final GetCategoryByIdUseCase _getCategoryById;
  final GetSubcategoriesUseCase _getSubcategories;
  final AddToCartUseCase _addToCart;

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

  Future<AddToCartResult> addToCart({required int quantity}) async {
    final current = product;
    if (current == null) {
      return AddToCartResult.failure;
    }
    if (!current.inStock) {
      return AddToCartResult.outOfStock;
    }
    if (quantity <= 0) {
      return AddToCartResult.failure;
    }

    try {
      final result = await _addToCart(
        AddToCartParams(product: current, quantity: quantity),
      );
      return result.isSuccess ? AddToCartResult.success : AddToCartResult.failure;
    } catch (_) {
      return AddToCartResult.failure;
    }
  }
}

ProductDetailController createProductDetailController() {
  configureDependencies();
  return sl<ProductDetailController>();
}
