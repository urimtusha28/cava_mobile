import 'package:cava_ecommerce/features/account/data/datasources/auth_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/datasources/user_profile_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:cava_ecommerce/features/account/data/repositories/user_profile_repository_impl.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/forgot_password.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/is_logged_in.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/login.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/logout.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/register.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/user_profile_usecases.dart';
import 'package:cava_ecommerce/features/account/presentation/controllers/auth_controller.dart';
import 'package:cava_ecommerce/features/account/presentation/controllers/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserProfileMockDataSource profileDataSource;
  late AuthRepositoryImpl authRepository;
  late ProfileController controller;

  setUp(() {
    MockAuth.logout();
    profileDataSource = UserProfileMockDataSource();
    authRepository = AuthRepositoryImpl(const AuthMockDataSource());
    final profileRepository = UserProfileRepositoryImpl(
      profileDataSource,
      authRepository,
    );
    final authController = AuthController(
      IsLoggedInUseCase(authRepository),
      LoginUseCase(authRepository),
      RegisterUseCase(authRepository),
      ForgotPasswordUseCase(authRepository),
      LogoutUseCase(authRepository),
      authRepository,
    );
    controller = ProfileController(
      authController,
      GetCurrentProfileUseCase(profileRepository),
      UpdateProfileUseCase(profileRepository),
      EnsureUserDocExistsUseCase(profileRepository),
    );
  });

  tearDown(() {
    MockAuth.logout();
    profileDataSource.resetForTests();
  });

  test('logged out state has no profile', () async {
    await controller.load();
    expect(controller.isLoggedIn, isFalse);
    expect(controller.profile, isNull);
    expect(controller.displayName, isEmpty);
  });

  test('load/update after login', () async {
    MockAuth.login();
    await profileDataSource.ensureUserDocExists(
      uid: MockAuth.currentUser.uid,
      email: MockAuth.userEmail,
      name: MockAuth.userName,
    );

    await controller.load();
    expect(controller.isLoggedIn, isTrue);
    expect(controller.profile?.email, MockAuth.userEmail);
    expect(controller.displayName, 'Urim Tusha');

    final result = await controller.saveProfile(
      firstName: 'Ada',
      lastName: 'Lovelace',
      phone: '+38344111222',
    );

    expect(result.isSuccess, isTrue);
    expect(controller.profile?.firstName, 'Ada');
    expect(controller.profile?.phone, '+38344111222');
    expect(controller.displayName, 'Ada Lovelace');
  });

  test('logout clears profile', () async {
    MockAuth.login();
    await profileDataSource.ensureUserDocExists(
      uid: MockAuth.currentUser.uid,
      email: MockAuth.userEmail,
      name: 'Urim Tusha',
    );
    await controller.load();
    expect(controller.profile, isNotNull);

    await controller.logout();
    expect(controller.isLoggedIn, isFalse);
    expect(controller.profile, isNull);
  });
}
