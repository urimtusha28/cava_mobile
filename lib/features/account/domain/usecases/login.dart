import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase extends SyncUseCaseNoParams<void> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Result<void> call() {
    return guardSync(_repository.login);
  }
}
