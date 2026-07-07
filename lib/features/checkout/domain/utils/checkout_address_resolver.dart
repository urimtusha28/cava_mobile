import '../../../account/domain/entities/address_entity.dart';

abstract final class CheckoutAddressResolver {
  /// Resolves checkout delivery address from persisted id and available list.
  ///
  /// - Persisted id found → use it.
  /// - Persisted id missing (deleted) → default, else first.
  /// - No persisted id → null (user must select).
  static AddressEntity? resolve({
    required List<AddressEntity> addresses,
    String? persistedAddressId,
  }) {
    if (addresses.isEmpty) {
      return null;
    }

    if (persistedAddressId != null) {
      for (final address in addresses) {
        if (address.id == persistedAddressId) {
          return address;
        }
      }
      return _fallback(addresses);
    }

    return null;
  }

  static AddressEntity _fallback(List<AddressEntity> addresses) {
    return addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => addresses.first,
    );
  }
}
