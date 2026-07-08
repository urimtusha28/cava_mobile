import '../../domain/utils/user_profile_name_splitter.dart';
import '../models/user_profile_model.dart';
import 'user_profile_data_source.dart';

/// In-memory profile store for tests / mock auth mode.
class UserProfileMockDataSource implements UserProfileDataSource {
  final Map<String, UserProfileModel> _profiles = {};

  @override
  Future<UserProfileModel?> getProfile(String uid, {String? authEmail}) async {
    final existing = _profiles[uid];
    if (existing != null) {
      if (existing.email.isEmpty && authEmail != null && authEmail.isNotEmpty) {
        return UserProfileModel(
          uid: existing.uid,
          name: existing.name,
          firstName: existing.firstName,
          lastName: existing.lastName,
          email: authEmail,
          phone: existing.phone,
          role: existing.role,
          status: existing.status,
          createdAt: existing.createdAt,
          updatedAt: existing.updatedAt,
        );
      }
      return existing;
    }

    if (authEmail == null || authEmail.trim().isEmpty) {
      return null;
    }

    return UserProfileModel.fromFirestore(
      uid: uid,
      data: const {},
      authEmailFallback: authEmail,
    );
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
    String? phone,
    String? authEmail,
  }) async {
    final current = _profiles[uid];
    final now = DateTime.now().toUtc();
    final updated = UserProfileModel(
      uid: uid,
      name: UserProfileNameSplitter.combine(firstName, lastName),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: current?.email.isNotEmpty == true
          ? current!.email
          : (authEmail ?? ''),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      role: current?.role ?? 'client',
      status: current?.status ?? 'active',
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
    _profiles[uid] = updated;
    return updated;
  }

  @override
  Future<void> ensureUserDocExists({
    required String uid,
    required String email,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    if (_profiles.containsKey(uid)) {
      return;
    }

    String resolvedFirst = firstName?.trim() ?? '';
    String resolvedLast = lastName?.trim() ?? '';
    if (resolvedFirst.isEmpty && resolvedLast.isEmpty) {
      final split = UserProfileNameSplitter.split(name);
      resolvedFirst = split.$1;
      resolvedLast = split.$2;
    }

    final now = DateTime.now().toUtc();
    _profiles[uid] = UserProfileModel(
      uid: uid,
      name: (name?.trim().isNotEmpty == true)
          ? name!.trim()
          : UserProfileNameSplitter.combine(resolvedFirst, resolvedLast),
      firstName: resolvedFirst,
      lastName: resolvedLast,
      email: email.trim(),
      phone: phone,
      role: 'client',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
  }

  void resetForTests() => _profiles.clear();
}
