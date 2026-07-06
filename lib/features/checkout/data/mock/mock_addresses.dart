import '../../domain/entities/address_entity.dart';

abstract final class MockAddresses {
  static const List<AddressEntity> addresses = [
    AddressEntity(
      id: 'addr-001',
      fullName: 'Arben Krasniqi',
      street: 'Rruga Nëna Terezë 42',
      city: 'Prishtinë, 10000',
      phone: '+383 44 123 456',
      isDefault: true,
    ),
    AddressEntity(
      id: 'addr-002',
      fullName: 'Arben Krasniqi',
      street: 'Bulevardi Bill Clinton 15',
      city: 'Prizren, 20000',
      phone: '+383 44 123 456',
    ),
  ];
}
