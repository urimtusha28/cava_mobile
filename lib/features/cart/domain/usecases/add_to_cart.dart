import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../repositories/cart_repository.dart';
import '../utils/cart_stock_validator.dart';

final class AddToCartParams {
  const AddToCartParams({
    required this.product,
    this.quantity = 1,
  });

  final ProductEntity product;
  final int quantity;
}

class AddToCartUseCase extends BaseUseCase<void, AddToCartParams> {
  AddToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<void>> call(AddToCartParams params) {
    return guard(() async {
      final items = await _repository.getItems();
      final alreadyInCart = CartStockValidator.quantityInCartForProduct(
        items,
        params.product.id,
      );
      final error = CartStockValidator.validateAdd(
        product: params.product,
        quantity: params.quantity,
        quantityAlreadyInCart: alreadyInCart,
      );
      if (error != null) {
        throw ValidationFailure(
          message: error,
          code: error == CartStockValidator.outOfStockMessage
              ? 'OUT_OF_STOCK'
              : 'INSUFFICIENT_STOCK',
        );
      }
      await _repository.addProduct(params.product, quantity: params.quantity);
    });
  }
}
