import '../../../../core/auth/app_role.dart';
import '../../domain/repositories/app_role_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../firebase/firebase_auth_gateway.dart';

class AppRoleRepositoryImpl implements AppRoleRepository {
  AppRoleRepositoryImpl(
    this._authRepository,
    this._profileRepository,
    this._authGateway,
  );

  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;
  final FirebaseAuthGateway? _authGateway;

  @override
  Future<AppRole> resolveCurrentRole() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      return AppRole.customer;
    }

    // 1) Custom claim `admin` (same source as Firestore rules isAdmin()).
    final gateway = _authGateway;
    if (gateway != null) {
      final isAdminClaim = await gateway.getAdminClaim(forceRefresh: true);
      if (isAdminClaim == true) {
        return AppRole.owner;
      }
    }

    // 2) Firestore users/{uid}.role
    final profile = await _profileRepository.getCurrentProfile();
    return AppRoleMapper.fromFirestoreRole(profile?.role);
  }
}
