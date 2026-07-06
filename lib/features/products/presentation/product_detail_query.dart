import '../../../core/di/injection.dart';
import '../domain/entities/product_entity.dart';
import '../domain/usecases/get_product_by_id.dart';
import 'products_module.dart';

/// Resolves a single product through the use case layer.
abstract final class ProductDetailQuery {
  static ProductEntity? byId(String productId) {
    ProductsModule.ensureInitialized();
    return sl<GetProductById>().call(productId).fold(
          onSuccess: (product) => product,
          onFailure: (_) => null,
        );
  }
}
