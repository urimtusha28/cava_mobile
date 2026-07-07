import '../entities/address_entity.dart';
import '../../data/models/address_model.dart';

abstract class AddressesRepository {
  Future<List<AddressEntity>> getAddresses();

  Future<void> addAddress(AddressModel address);

  Future<void> updateAddress(AddressModel address);

  Future<void> deleteAddress(String addressId);

  Future<void> setDefaultAddress(String addressId);
}
