import '../models/address_model.dart';

abstract class AddressesDataSource {
  Future<List<AddressModel>> getAddresses(String userId);

  Future<void> addAddress(String userId, AddressModel address);

  Future<void> updateAddress(String userId, AddressModel address);

  Future<void> deleteAddress(String userId, String addressId);

  Future<void> setDefaultAddress(String userId, String addressId);
}
