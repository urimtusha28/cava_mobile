import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/features/account/domain/entities/address_entity.dart';
import 'package:cava_ecommerce/features/account/domain/entities/auth_user_entity.dart';
import 'package:cava_ecommerce/features/checkout/data/datasources/checkout_mock_datasource.dart';
import 'package:cava_ecommerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:cava_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

const testOfficeAddressEntity = AddressEntity(
  id: 'addr-2',
  label: 'Office',
  fullName: 'Urim Tusha',
  phone: '+38344333444',
  street: 'Rruga B 5',
  city: 'Prizren',
  country: 'Kosovë',
  zip: '20000',
  isDefault: false,
);

void main() {
  late MockAuthRepository authRepository;
  late MockAddressesRepository addressesRepository;
  late MockCartRepository cartRepository;
  late CheckoutMockDataSource checkoutDataSource;
  late CheckoutRepositoryImpl repository;

  setUp(() {
    authRepository = MockAuthRepository();
    addressesRepository = MockAddressesRepository();
    cartRepository = MockCartRepository();
    checkoutDataSource = CheckoutMockDataSource();

    repository = CheckoutRepositoryImpl(
      checkoutDataSource,
      authRepository,
      addressesRepository,
      cartRepository,
    );

    when(() => authRepository.getCurrentUser()).thenAnswer(
      (_) async => const AuthUserEntity(
        uid: 'user-1',
        email: 'test@cava.test',
        displayName: 'Urim Tusha',
      ),
    );
    when(() => cartRepository.hydrateFromStorage()).thenAnswer((_) async {});
    when(() => cartRepository.getItems()).thenAnswer((_) async => [testCartItem]);
    when(() => addressesRepository.getAddresses()).thenAnswer(
      (_) async => [testAddressEntity, testOfficeAddressEntity],
    );
  });

  test('placeOrder sends payload without total', () async {
    await repository.placeOrder(
      const PlaceOrderRequest(
        paymentMethod: 'cash',
        termsAccepted: true,
        addressId: 'addr-1',
      ),
    );

    expect(checkoutDataSource.lastPayload, isNotNull);
    expect(checkoutDataSource.lastPayload!.containsKey('total'), isFalse);
    expect(checkoutDataSource.lastPayload!['items'], isNotEmpty);
  });

  test('placeOrder uses selected address instead of default', () async {
    await repository.placeOrder(
      const PlaceOrderRequest(
        paymentMethod: 'cash',
        termsAccepted: true,
        addressId: 'addr-2',
      ),
    );

    expect(checkoutDataSource.lastPayload?['customer']['address'], 'Rruga B 5');
    expect(checkoutDataSource.lastPayload?['customer']['city'], 'Prizren');
  });

  test('throws when user is not authenticated', () async {
    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => null);

    expect(
      () => repository.placeOrder(
        const PlaceOrderRequest(
          paymentMethod: 'cash',
          termsAccepted: true,
          addressId: 'addr-1',
        ),
      ),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('throws when no address exists', () async {
    when(() => addressesRepository.getAddresses()).thenAnswer((_) async => []);

    expect(
      () => repository.placeOrder(
        const PlaceOrderRequest(
          paymentMethod: 'cash',
          termsAccepted: true,
          addressId: 'addr-1',
        ),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('throws when selected address id is missing', () async {
    expect(
      () => repository.placeOrder(
        const PlaceOrderRequest(
          paymentMethod: 'cash',
          termsAccepted: true,
          addressId: 'missing-id',
        ),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
