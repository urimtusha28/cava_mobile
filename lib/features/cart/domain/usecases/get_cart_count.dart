import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';

class GetCartCountUseCase extends BaseUseCaseNoParams<int> {
  GetCartCountUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<int>> call() {
    return guard(_repository.getItemCount);
  }
}
