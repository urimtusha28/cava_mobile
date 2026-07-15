import 'package:cava_ecommerce/core/auth/app_role.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/account/domain/repositories/auth_repository.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/forgot_password.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/is_logged_in.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/login.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/register.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/logout.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/resolve_app_role.dart';
import 'package:cava_ecommerce/features/account/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIsLoggedInUseCase extends Mock implements IsLoggedInUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockResolveAppRoleUseCase extends Mock implements ResolveAppRoleUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: 'a@b.com', password: 'secret'));
    registerFallbackValue(
      const RegisterParams(email: 'a@b.com', password: 'secret', name: 'Urim'),
    );
    registerFallbackValue(const ForgotPasswordParams(email: 'a@b.com'));
  });

  late MockIsLoggedInUseCase isLoggedIn;
  late MockLoginUseCase login;
  late MockRegisterUseCase register;
  late MockForgotPasswordUseCase forgotPassword;
  late MockLogoutUseCase logout;
  late MockAuthRepository authRepository;
  late MockResolveAppRoleUseCase resolveAppRole;
  late AuthController controller;

  setUp(() {
    isLoggedIn = MockIsLoggedInUseCase();
    login = MockLoginUseCase();
    register = MockRegisterUseCase();
    forgotPassword = MockForgotPasswordUseCase();
    logout = MockLogoutUseCase();
    authRepository = MockAuthRepository();
    resolveAppRole = MockResolveAppRoleUseCase();
    when(() => resolveAppRole.call()).thenAnswer(
      (_) async => const Success(AppRole.customer),
    );
    controller = AuthController(
      isLoggedIn,
      login,
      register,
      forgotPassword,
      logout,
      authRepository,
      resolveAppRole,
    );
  });

  test('load sets loggedIn and userName', () async {
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => authRepository.getUserName()).thenAnswer((_) async => 'Test User');

    await controller.load();

    expect(controller.loggedIn, isTrue);
    expect(controller.userName, 'Test User');
  });

  test('signIn refreshes auth state on success', () async {
    when(
      () => login(any()),
    ).thenAnswer((_) async => const Success(null));
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => authRepository.getUserName()).thenAnswer((_) async => 'User');

    final result = await controller.signIn(
      email: 'a@b.com',
      password: 'secret',
    );

    expect(result.isSuccess, isTrue);
    expect(controller.loggedIn, isTrue);
    verify(() => login(any())).called(1);
  });

  test('signUp delegates to register use case', () async {
    when(
      () => register(any()),
    ).thenAnswer((_) async => const Success(null));
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => authRepository.getUserName()).thenAnswer((_) async => 'User');

    final result = await controller.signUp(
      email: 'a@b.com',
      password: 'secret',
      name: 'Urim',
    );

    expect(result.isSuccess, isTrue);
    verify(() => register(any())).called(1);
  });

  test('resetPassword delegates to forgot password use case', () async {
    when(
      () => forgotPassword(any()),
    ).thenAnswer((_) async => const Success(null));

    final result = await controller.resetPassword(email: 'a@b.com');

    expect(result.isSuccess, isTrue);
    verify(() => forgotPassword(any())).called(1);
  });

  test('logout refreshes auth state', () async {
    when(() => logout()).thenAnswer((_) async => const Success(null));
    when(() => isLoggedIn()).thenAnswer((_) async => Success(false));
    when(() => authRepository.getUserName()).thenAnswer((_) async => '');

    await controller.logout();

    expect(controller.loggedIn, isFalse);
    verify(() => logout()).called(1);
  });

  test('authState stream comes from repository', () {
    when(() => authRepository.watchAuthState())
        .thenAnswer((_) => Stream<bool>.value(false));
    expect(controller.authState, isA<Stream<bool>>());
  });
}
