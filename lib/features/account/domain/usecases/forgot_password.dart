import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordParams {
  const ForgotPasswordParams({required this.email});

  final String email;
}

class ForgotPasswordUseCase extends BaseUseCase<void, ForgotPasswordParams> {
  ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(ForgotPasswordParams params) {
    return guard(() => _repository.forgotPassword(email: params.email));
  }
}
