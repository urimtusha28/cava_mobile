import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase extends BaseUseCaseNoParams<List<CartItemEntity>> {
  GetCartItemsUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<List<CartItemEntity>>> call() {
    return guard(_repository.getItems);
  }
}
