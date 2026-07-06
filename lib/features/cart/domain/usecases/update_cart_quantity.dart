import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';

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
    return guard(
      () => _repository.updateQuantity(params.index, params.quantity),
    );
  }
}
