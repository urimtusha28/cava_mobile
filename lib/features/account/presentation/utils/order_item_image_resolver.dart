import '../../../../core/widgets/product_image_view.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/order_item_entity.dart';

abstract class OrderItemImageSource {
  Future<String?> resolve(OrderItemEntity item);
}

class OrderItemImageResolver implements OrderItemImageSource {
  const OrderItemImageResolver(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<String?> resolve(OrderItemEntity item) async {
    if (ProductImageView.hasUrl(item.imageUrl)) {
      return item.imageUrl!.trim();
    }

    final productId = item.productId?.trim();
    if (productId == null || productId.isEmpty) {
      return null;
    }

    final product = await _productRepository.getById(productId);
    return _imageFromProduct(product);
  }

  static String? _imageFromProduct(ProductEntity? product) {
    if (product == null) {
      return null;
    }
    if (ProductImageView.hasUrl(product.imageUrl)) {
      return product.imageUrl!.trim();
    }
    if (ProductImageView.hasUrl(product.detailImageUrl)) {
      return product.detailImageUrl!.trim();
    }
    return null;
  }
}
