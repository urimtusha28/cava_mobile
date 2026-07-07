import 'package:cava_ecommerce/features/account/data/models/address_model.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/address_usecases.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/get_my_orders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddressModel(
        id: 'a1',
        label: 'Shtëpi',
        fullName: 'Urim',
        phone: '044',
        street: 'Rruga 1',
        city: 'Ferizaj',
        country: 'Kosovë',
      ),
    );
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
    registerFallbackValue(
      UpdateAddressParams(
        address: const AddAddressParams(
          label: 'Shtëpi',
          fullName: 'Urim',
          phone: '044',
          street: 'Rruga 1',
          city: 'Ferizaj',
          country: 'Kosovë',
        ).toModel().copyWith(id: 'a1'),
      ),
    );
    registerFallbackValue(const DeleteAddressParams(addressId: 'a1'));
    registerFallbackValue(const SetDefaultAddressParams(addressId: 'a1'));
  });

  test('GetMyOrdersUseCase delegates to repository', () async {
    final repository = MockOrdersRepository();
    when(() => repository.getMyOrders()).thenAnswer((_) async => const []);

    final result = await GetMyOrdersUseCase(repository)();
    expect(result.isSuccess, isTrue);
  });

  test('AddAddressUseCase delegates to repository', () async {
    final repository = MockAddressesRepository();
    when(() => repository.addAddress(any())).thenAnswer((_) async {});

    final result = await AddAddressUseCase(repository)(
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
  });
}
