import '../../../../core/auth/app_role.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/app_role_repository.dart';

class ResolveAppRoleUseCase extends BaseUseCaseNoParams<AppRole> {
  ResolveAppRoleUseCase(this._repository);

  final AppRoleRepository _repository;

  @override
  Future<Result<AppRole>> call() {
    return guard(_repository.resolveCurrentRole);
  }
}

extension ResolveAppRoleFallback on ResolveAppRoleUseCase {
  Future<AppRole> callOrCustomer() async {
    final result = await call();
    return result.dataOrNull ?? AppRole.customer;
  }
}
