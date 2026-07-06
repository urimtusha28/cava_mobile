import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase extends SyncUseCaseNoParams<void> {
  ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Result<void> call() {
    return guardSync(_repository.clear);
  }
}
