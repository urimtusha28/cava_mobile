import 'package:cava_ecommerce/core/state/auth_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    AuthStateNotifier.reset();
    dataSource = MockAuthDataSource();
    when(() => dataSource.isLoggedIn()).thenReturn(false);
    repository = AuthRepositoryImpl(dataSource);
  });

  tearDown(() => AuthStateNotifier.reset());

  test('isLoggedIn delegates to datasource', () async {
    when(() => dataSource.isLoggedIn()).thenReturn(true);
    expect(await repository.isLoggedIn(), isTrue);
  });

  test('login updates auth notifier', () async {
    await repository.login();
    verify(() => dataSource.login()).called(1);
    expect(AuthStateNotifier.isLoggedIn.value, isTrue);
  });

  test('logout updates auth notifier', () async {
    when(() => dataSource.isLoggedIn()).thenReturn(true);
    repository = AuthRepositoryImpl(dataSource);

    await repository.logout();

    verify(() => dataSource.logout()).called(1);
    expect(AuthStateNotifier.isLoggedIn.value, isFalse);
  });

  test('watchAuthState exposes stream', () {
    expect(repository.watchAuthState(), isA<Stream<bool>>());
  });
}
