import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';

class GetCartCountUseCase extends SyncUseCaseNoParams<int> {
  GetCartCountUseCase(this._repository);

  final CartRepository _repository;

  @override
  Result<int> call() {
    return guardSync(_repository.getItemCount);
  }
}
