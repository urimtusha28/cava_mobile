import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/get_category_by_id.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id.dart';

class ProductDetailController extends BaseController {
  ProductDetailController(this._getProductById, this._getCategoryById);

  final GetProductById _getProductById;
  final GetCategoryByIdUseCase _getCategoryById;

  ProductEntity? product;
  CategoryEntity? category;

  Future<void> load(String productId) {
    return runLoad(() async {
      product = await unwrapFutureResult(
        _getProductById(productId),
        fallback: null,
      );
      category = null;
      if (product != null) {
        category = await unwrapFutureResult(
          _getCategoryById(product!.categoryId),
          fallback: null,
        );
      }
    });
  }
}

ProductDetailController createProductDetailController() {
  configureDependencies();
  return sl<ProductDetailController>();
}
