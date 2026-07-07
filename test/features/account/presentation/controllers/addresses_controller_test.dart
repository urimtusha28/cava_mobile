import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/account/domain/entities/address_entity.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/address_usecases.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/is_logged_in.dart';
import 'package:cava_ecommerce/features/account/presentation/controllers/addresses_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIsLoggedInUseCase extends Mock implements IsLoggedInUseCase {}

class MockGetAddressesUseCase extends Mock implements GetAddressesUseCase {}

class MockAddAddressUseCase extends Mock implements AddAddressUseCase {}

class MockSetDefaultAddressUseCase extends Mock implements SetDefaultAddressUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddAddressParams(
        label: 'Shtëpi',
        fullName: 'Urim',
        phone: '044',
        street: 'Rruga 1',
        city: 'Ferizaj',
        country: 'Kosovë',
      ),
    );
    registerFallbackValue(const SetDefaultAddressParams(addressId: 'a1'));
  });

  late MockIsLoggedInUseCase isLoggedIn;
  late MockGetAddressesUseCase getAddresses;
  late MockAddAddressUseCase addAddress;
  late MockSetDefaultAddressUseCase setDefaultAddress;
  late AddressesController controller;

  setUp(() {
    isLoggedIn = MockIsLoggedInUseCase();
    getAddresses = MockGetAddressesUseCase();
    addAddress = MockAddAddressUseCase();
    setDefaultAddress = MockSetDefaultAddressUseCase();
    controller = AddressesController(
      isLoggedIn,
      getAddresses,
      addAddress,
      setDefaultAddress,
    );
  });

  test('requires login when guest', () async {
    when(() => isLoggedIn()).thenAnswer((_) async => Success(false));

    await controller.load();

    expect(controller.requiresLogin, isTrue);
    expect(controller.addresses, isEmpty);
  });

  test('addAddress delegates to use case', () async {
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => getAddresses()).thenAnswer((_) async => Success(const []));
    when(() => addAddress(any())).thenAnswer((_) async => const Success(null));

    final result = await controller.addAddress(
      const AddAddressParams(
        label: 'Shtëpi',
        fullName: 'Urim',
        phone: '044',
        street: 'Rruga 1',
        city: 'Ferizaj',
        country: 'Kosovë',
      ),
    );

    expect(result.isSuccess, isTrue);
    verify(() => addAddress(any())).called(1);
  });

  test('setDefault refreshes addresses', () async {
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => getAddresses()).thenAnswer(
      (_) async => Success(const [
        AddressEntity(
          id: 'a1',
          label: 'Shtëpi',
          fullName: 'Urim',
          phone: '044',
          street: 'Rruga 1',
          city: 'Ferizaj',
          country: 'Kosovë',
          isDefault: true,
        ),
      ]),
    );
    when(() => setDefaultAddress(any())).thenAnswer((_) async => const Success(null));

    await controller.setDefault('a1');

    verify(() => setDefaultAddress(any())).called(1);
    expect(controller.addresses, hasLength(1));
  });
}
