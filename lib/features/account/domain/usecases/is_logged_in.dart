import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class IsLoggedInUseCase extends BaseUseCaseNoParams<bool> {
  IsLoggedInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call() {
    return guard(_repository.isLoggedIn);
  }
}
