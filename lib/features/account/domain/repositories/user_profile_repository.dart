import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity?> getCurrentProfile();

  Future<UserProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  });

  Future<void> ensureUserDocExists();
}
