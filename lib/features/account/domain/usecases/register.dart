import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    this.name,
  });

  final String email;
  final String password;
  final String? name;
}

class RegisterUseCase extends BaseUseCase<void, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(RegisterParams params) {
    return guard(
      () => _repository.register(
        email: params.email,
        password: params.password,
        name: params.name,
      ),
    );
  }
}
