import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase extends BaseUseCase<void, int> {
  RemoveFromCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<void>> call(int index) {
    return guard(() => _repository.removeAt(index));
  }
}
