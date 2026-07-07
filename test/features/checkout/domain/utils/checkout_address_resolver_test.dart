import 'package:cava_ecommerce/features/account/domain/entities/address_entity.dart';
import 'package:cava_ecommerce/features/checkout/domain/utils/checkout_address_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

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
  group('CheckoutAddressResolver', () {
    test('returns null when no addresses exist', () {
      expect(
        CheckoutAddressResolver.resolve(
          addresses: const [],
          persistedAddressId: 'addr-1',
        ),
        isNull,
      );
    });

    test('returns null when no persisted id on first visit', () {
      expect(
        CheckoutAddressResolver.resolve(
          addresses: const [testAddressEntity, testOfficeAddressEntity],
          persistedAddressId: null,
        ),
        isNull,
      );
    });

    test('returns persisted address when it exists', () {
      expect(
        CheckoutAddressResolver.resolve(
          addresses: const [testAddressEntity, testOfficeAddressEntity],
          persistedAddressId: 'addr-2',
        ),
        testOfficeAddressEntity,
      );
    });

    test('falls back to default when persisted address was deleted', () {
      expect(
        CheckoutAddressResolver.resolve(
          addresses: const [testAddressEntity],
          persistedAddressId: 'addr-deleted',
        ),
        testAddressEntity,
      );
    });

    test('falls back to first when persisted deleted and no default', () {
      const first = AddressEntity(
        id: 'addr-a',
        label: 'A',
        fullName: 'A',
        phone: '1',
        street: 'S1',
        city: 'C1',
        country: 'Kosovë',
      );
      const second = AddressEntity(
        id: 'addr-b',
        label: 'B',
        fullName: 'B',
        phone: '2',
        street: 'S2',
        city: 'C2',
        country: 'Kosovë',
      );

      expect(
        CheckoutAddressResolver.resolve(
          addresses: const [first, second],
          persistedAddressId: 'missing',
        ),
        first,
      );
    });
  });
}
