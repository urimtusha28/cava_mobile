import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._dataSource, this._authRepository);

  final UserProfileDataSource _dataSource;
  final AuthRepository _authRepository;

  @override
  Future<UserProfileEntity?> getCurrentProfile() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      return null;
    }

    final model = await _dataSource.getProfile(
      user.uid,
      authEmail: user.email,
    );
    return model?.toEntity();
  }

  @override
  Future<UserProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw StateError('Profile requires an authenticated user.');
    }

    final model = await _dataSource.updateProfile(
      uid: user.uid,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      authEmail: user.email,
    );
    return model.toEntity();
  }

  @override
  Future<void> ensureUserDocExists() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      return;
    }

    await _dataSource.ensureUserDocExists(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
  }
}
