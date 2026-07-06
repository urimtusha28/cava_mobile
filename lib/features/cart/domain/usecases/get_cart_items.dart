import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase extends SyncUseCaseNoParams<List<CartItemEntity>> {
  GetCartItemsUseCase(this._repository);

  final CartRepository _repository;

  @override
  Result<List<CartItemEntity>> call() {
    return guardSync(_repository.getItems);
  }
}
