import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetCurrentProfileUseCase
    extends BaseUseCaseNoParams<UserProfileEntity?> {
  GetCurrentProfileUseCase(this._repository);

  final UserProfileRepository _repository;

  @override
  Future<Result<UserProfileEntity?>> call() {
    return guard(_repository.getCurrentProfile);
  }
}

class UpdateProfileParams {
  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  final String firstName;
  final String lastName;
  final String? phone;
}

class UpdateProfileUseCase
    extends BaseUseCase<UserProfileEntity, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);

  final UserProfileRepository _repository;

  @override
  Future<Result<UserProfileEntity>> call(UpdateProfileParams params) {
    return guard(
      () => _repository.updateProfile(
        firstName: params.firstName,
        lastName: params.lastName,
        phone: params.phone,
      ),
    );
  }
}

class EnsureUserDocExistsUseCase extends BaseUseCaseNoParams<void> {
  EnsureUserDocExistsUseCase(this._repository);

  final UserProfileRepository _repository;

  @override
  Future<Result<void>> call() {
    return guard(_repository.ensureUserDocExists);
  }
}
