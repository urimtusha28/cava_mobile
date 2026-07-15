import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';
import '../utils/cart_stock_validator.dart';

final class UpdateCartQuantityParams {
  const UpdateCartQuantityParams({
    required this.index,
    required this.quantity,
  });

  final int index;
  final int quantity;
}

class UpdateCartQuantityUseCase
    extends BaseUseCase<void, UpdateCartQuantityParams> {
  UpdateCartQuantityUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<void>> call(UpdateCartQuantityParams params) {
    return guard(() async {
      final items = await _repository.getItems();
      if (params.index < 0 || params.index >= items.length) {
        throw const ValidationFailure(
          message: CartStockValidator.insufficientStockMessage,
          code: 'INVALID_CART_INDEX',
        );
      }
      final item = items[params.index];
      final error = CartStockValidator.validateSetQuantity(
        product: item.product,
        quantity: params.quantity,
      );
      if (error != null) {
        throw ValidationFailure(
          message: error,
          code: error == CartStockValidator.outOfStockMessage
              ? 'OUT_OF_STOCK'
              : 'INSUFFICIENT_STOCK',
        );
      }
      await _repository.updateQuantity(params.index, params.quantity);
    });
  }
}
