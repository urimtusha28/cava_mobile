import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends SyncUseCaseNoParams<void> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Result<void> call() {
    return guardSync(_repository.logout);
  }
}
