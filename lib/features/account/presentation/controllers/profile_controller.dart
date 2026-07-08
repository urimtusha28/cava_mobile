import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../../core/result/result.dart';
import '../../../../core/state/auth_state_notifier.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/user_profile_usecases.dart';
import 'auth_controller.dart';

class ProfileController extends BaseController {
  ProfileController(
    this._authController,
    this._getCurrentProfile,
    this._updateProfile,
    this._ensureUserDocExists,
  );

  final AuthController _authController;
  final GetCurrentProfileUseCase _getCurrentProfile;
  final UpdateProfileUseCase _updateProfile;
  final EnsureUserDocExistsUseCase _ensureUserDocExists;

  UserProfileEntity? profile;
  bool saveLoading = false;
  String? saveError;

  bool get isLoggedIn => _authController.loggedIn;

  String get displayName {
    final fromProfile = profile?.displayName.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) {
      return fromProfile;
    }
    return _authController.userName;
  }

  String get email => profile?.email ?? '';

  String? get phone => profile?.phone;

  AuthController get authController => _authController;

  Future<void> load() {
    return runLoad(() async {
      await _authController.load();
      await _refreshProfile();
    });
  }

  Future<void> refreshAfterAuth() async {
    await _authController.load();
    await unwrapFutureResult(_ensureUserDocExists(), fallback: null);
    await _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    if (!_authController.loggedIn) {
      profile = null;
      notifyListeners();
      return;
    }

    profile = await unwrapFutureResult(
      _getCurrentProfile(),
      fallback: null,
    );
    notifyListeners();
  }

  Future<Result<UserProfileEntity>> saveProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    saveLoading = true;
    saveError = null;
    notifyListeners();

    final result = await _updateProfile(
      UpdateProfileParams(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      ),
    );

    saveLoading = false;
    if (result.isSuccess) {
      profile = result.dataOrNull;
      if (profile != null) {
        _authController.userName = profile!.displayName;
      }
    } else {
      saveError = result.failureOrNull?.message ??
          'Profili nuk u përditësua. Provo përsëri.';
    }
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _authController.logout();
    profile = null;
    AuthStateNotifier.update(false);
    notifyListeners();
  }
}

ProfileController createProfileController() {
  configureDependencies();
  return sl<ProfileController>();
}
