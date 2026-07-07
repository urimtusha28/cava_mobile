import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../../core/result/result.dart';
import '../../../../core/state/auth_state_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/is_logged_in.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';

class AuthController extends BaseController {
  AuthController(
    this._isLoggedIn,
    this._login,
    this._register,
    this._forgotPassword,
    this._logout,
    this._authRepository,
  );

  final IsLoggedInUseCase _isLoggedIn;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final ForgotPasswordUseCase _forgotPassword;
  final LogoutUseCase _logout;
  final AuthRepository _authRepository;

  bool loggedIn = false;
  String userName = '';
  bool authActionLoading = false;
  String? authActionError;

  Stream<bool> get authState => _authRepository.watchAuthState();

  Future<void> load() {
    return runLoad(() async {
      await _refreshUser();
    });
  }

  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) {
    return _runAuthAction(() async {
      final result = await _login(
        LoginParams(email: email, password: password),
      );
      if (result.isSuccess) {
        await _refreshUser();
      }
      return result;
    });
  }

  Future<Result<void>> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _runAuthAction(() async {
      final result = await _register(
        RegisterParams(
          email: email,
          password: password,
          name: name,
        ),
      );
      if (result.isSuccess) {
        await _refreshUser();
      }
      return result;
    });
  }

  Future<Result<void>> resetPassword({required String email}) {
    return _runAuthAction(() async {
      return _forgotPassword(ForgotPasswordParams(email: email));
    });
  }

  Future<void> login() {
    return signIn(email: 'mock@cava.test', password: 'password123').then((_) {});
  }

  Future<void> logout() {
    return runAction(() async {
      await unwrapFutureResult(_logout(), fallback: null);
      await _refreshUser();
    });
  }

  Future<Result<void>> _runAuthAction(
    Future<Result<void>> Function() action,
  ) async {
    authActionLoading = true;
    authActionError = null;
    notifyListeners();

    final result = await action();

    authActionLoading = false;
    authActionError = result.failureOrNull?.message;
    notifyListeners();
    return result;
  }

  Future<void> _refreshUser() async {
    loggedIn = await unwrapFutureResult(
      _isLoggedIn(),
      fallback: false,
    );
    userName = await _authRepository.getUserName();
    AuthStateNotifier.update(loggedIn);
    notifyListeners();
  }
}

AuthController createAuthController() {
  configureDependencies();
  return sl<AuthController>();
}
