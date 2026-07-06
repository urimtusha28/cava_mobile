import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../../core/state/auth_state_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/is_logged_in.dart';
import '../../domain/usecases/login.dart';

class AuthController extends BaseController {
  AuthController(this._isLoggedIn, this._login, this._authRepository);

  final IsLoggedInUseCase _isLoggedIn;
  final LoginUseCase _login;
  final AuthRepository _authRepository;

  bool loggedIn = false;
  String userName = '';

  Stream<bool> get authState => _authRepository.watchAuthState();

  Future<void> load() {
    return runLoad(() async {
      loggedIn = await unwrapFutureResult(
        _isLoggedIn(),
        fallback: false,
      );
      userName = await _authRepository.getUserName();
      AuthStateNotifier.update(loggedIn);
    });
  }

  Future<void> login() {
    return runAction(() async {
      await _login();
      loggedIn = await unwrapFutureResult(
        _isLoggedIn(),
        fallback: true,
      );
      userName = await _authRepository.getUserName();
      AuthStateNotifier.update(loggedIn);
    });
  }
}

AuthController createAuthController() {
  configureDependencies();
  return AuthController(sl(), sl(), sl());
}
