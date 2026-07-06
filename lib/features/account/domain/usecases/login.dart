import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase extends BaseUseCaseNoParams<void> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call() {
    return guard(_repository.login);
  }
}
