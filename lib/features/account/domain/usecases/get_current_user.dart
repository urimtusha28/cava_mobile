import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase extends BaseUseCaseNoParams<AuthUserEntity?> {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUserEntity?>> call() {
    return guard(_repository.getCurrentUser);
  }
}
