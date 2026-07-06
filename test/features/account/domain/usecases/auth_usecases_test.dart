import 'package:cava_ecommerce/features/account/domain/usecases/is_logged_in.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/login.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/logout.dart';
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
    when(() => repository.login()).thenAnswer((_) => Future<void>.value());
    final result = await LoginUseCase(repository)();
    expect(result.isSuccess, isTrue);
  });

  test('LogoutUseCase delegates to repository', () async {
    when(() => repository.logout()).thenAnswer((_) => Future<void>.value());
    final result = await LogoutUseCase(repository)();
    expect(result.isSuccess, isTrue);
  });
}
