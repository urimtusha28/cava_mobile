import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/account/domain/repositories/auth_repository.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/is_logged_in.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/login.dart';
import 'package:cava_ecommerce/features/account/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIsLoggedInUseCase extends Mock implements IsLoggedInUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockIsLoggedInUseCase isLoggedIn;
  late MockLoginUseCase login;
  late MockAuthRepository authRepository;
  late AuthController controller;

  setUp(() {
    isLoggedIn = MockIsLoggedInUseCase();
    login = MockLoginUseCase();
    authRepository = MockAuthRepository();
    controller = AuthController(isLoggedIn, login, authRepository);
  });

  test('load sets loggedIn and userName', () async {
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => authRepository.getUserName()).thenAnswer((_) async => 'Test User');

    await controller.load();

    expect(controller.loggedIn, isTrue);
    expect(controller.userName, 'Test User');
  });

  test('login refreshes auth state', () async {
    when(() => login()).thenAnswer((_) async => const Success(null));
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => authRepository.getUserName()).thenAnswer((_) async => 'User');

    await controller.login();

    expect(controller.loggedIn, isTrue);
    verify(() => login()).called(1);
  });

  test('authState stream comes from repository', () {
    when(() => authRepository.watchAuthState())
        .thenAnswer((_) => Stream<bool>.value(false));
    expect(controller.authState, isA<Stream<bool>>());
  });
}
