import '../models/user_profile_model.dart';

abstract class UserProfileDataSource {
  Future<UserProfileModel?> getProfile(String uid, {String? authEmail});

  Future<UserProfileModel> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
    String? phone,
    String? authEmail,
  });

  Future<void> ensureUserDocExists({
    required String uid,
    required String email,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
  });
}
