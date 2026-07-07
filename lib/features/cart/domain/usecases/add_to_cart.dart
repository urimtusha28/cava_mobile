import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../repositories/cart_repository.dart';

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
    return guard(
      () => _repository.addProduct(params.product, quantity: params.quantity),
    );
  }
}
