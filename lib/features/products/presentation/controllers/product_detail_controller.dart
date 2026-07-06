import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id.dart';

class ProductDetailController extends BaseController {
  ProductDetailController(this._getProductById);

  final GetProductById _getProductById;

  ProductEntity? product;

  Future<void> load(String productId) {
    return runLoad(() async {
      product = await unwrapFutureResult(
        _getProductById(productId),
        fallback: null,
      );
    });
  }
}

ProductDetailController createProductDetailController() {
  configureDependencies();
  return sl<ProductDetailController>();
}
