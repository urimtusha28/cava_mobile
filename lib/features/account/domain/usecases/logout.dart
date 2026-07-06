import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends BaseUseCaseNoParams<void> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call() {
    return guard(_repository.logout);
  }
}
