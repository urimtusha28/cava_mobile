import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase extends SyncUseCase<void, int> {
  RemoveFromCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Result<void> call(int index) {
    return guardSync(() {
      _repository.removeAt(index);
    });
  }
}
