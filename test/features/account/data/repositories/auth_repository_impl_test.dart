import 'package:cava_ecommerce/core/state/auth_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:cava_ecommerce/features/account/domain/entities/auth_user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    AuthStateNotifier.reset();
    dataSource = MockAuthDataSource();
    when(() => dataSource.currentUser).thenReturn(null);
    when(() => dataSource.authStateChanges())
        .thenAnswer((_) => const Stream<AuthUserEntity?>.empty());
    repository = AuthRepositoryImpl(dataSource);
  });

  tearDown(() => AuthStateNotifier.reset());

  test('isLoggedIn returns false when current user is null', () async {
    when(() => dataSource.currentUser).thenReturn(null);
    expect(await repository.isLoggedIn(), isFalse);
  });

  test('isLoggedIn returns true when current user exists', () async {
    when(() => dataSource.currentUser).thenReturn(
      const AuthUserEntity(uid: '1', email: 'a@b.com'),
    );
    expect(await repository.isLoggedIn(), isTrue);
  });

  test('login delegates to datasource', () async {
    when(
      () => dataSource.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AuthUserEntity(uid: '1', email: 'a@b.com'),
    );

    await repository.login(email: 'a@b.com', password: 'secret');

    verify(
      () => dataSource.login(email: 'a@b.com', password: 'secret'),
    ).called(1);
  });

  test('logout delegates to datasource', () async {
    when(() => dataSource.logout()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => dataSource.logout()).called(1);
  });

  test('watchAuthState exposes stream', () {
    expect(repository.watchAuthState(), isA<Stream<bool>>());
  });
}
