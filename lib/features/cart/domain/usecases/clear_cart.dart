import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase extends BaseUseCaseNoParams<void> {
  ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<void>> call() {
    return guard(_repository.clear);
  }
}
