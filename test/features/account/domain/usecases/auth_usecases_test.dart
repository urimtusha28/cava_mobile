import 'package:cava_ecommerce/features/account/domain/usecases/forgot_password.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/is_logged_in.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/login.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/logout.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/register.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  test('IsLoggedInUseCase returns status', () async {
    when(() => repository.isLoggedIn()).thenAnswer((_) async => true);
    final result = await IsLoggedInUseCase(repository)();
    expect(result.dataOrNull, isTrue);
  });

  test('LoginUseCase delegates to repository', () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => Future<void>.value());

    final result = await LoginUseCase(repository)(
      const LoginParams(email: 'a@b.com', password: 'secret'),
    );
    expect(result.isSuccess, isTrue);
  });

  test('RegisterUseCase delegates to repository', () async {
    when(
      () => repository.register(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) => Future<void>.value());

    final result = await RegisterUseCase(repository)(
      const RegisterParams(
        email: 'a@b.com',
        password: 'secret',
        name: 'Urim',
      ),
    );
    expect(result.isSuccess, isTrue);
  });

  test('ForgotPasswordUseCase delegates to repository', () async {
    when(
      () => repository.forgotPassword(email: any(named: 'email')),
    ).thenAnswer((_) => Future<void>.value());

    final result = await ForgotPasswordUseCase(repository)(
      const ForgotPasswordParams(email: 'a@b.com'),
    );
    expect(result.isSuccess, isTrue);
  });

  test('LogoutUseCase delegates to repository', () async {
    when(() => repository.logout()).thenAnswer((_) => Future<void>.value());
    final result = await LogoutUseCase(repository)();
    expect(result.isSuccess, isTrue);
  });
}
