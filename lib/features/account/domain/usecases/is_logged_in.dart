import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class IsLoggedInUseCase extends SyncUseCaseNoParams<bool> {
  IsLoggedInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Result<bool> call() {
    return guardSync(_repository.isLoggedIn);
  }
}
