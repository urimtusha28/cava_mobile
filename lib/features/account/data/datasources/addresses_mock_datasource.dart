import '../models/address_model.dart';
import 'addresses_data_source.dart';

class AddressesMockDataSource implements AddressesDataSource {
  AddressesMockDataSource();

  final Map<String, List<AddressModel>> _store = {};

  @override
  Future<List<AddressModel>> getAddresses(String userId) async {
    return List<AddressModel>.from(_store[userId] ?? const []);
  }

  @override
  Future<void> addAddress(String userId, AddressModel address) async {
    final list = List<AddressModel>.from(_store[userId] ?? const []);
    final id = address.id.isEmpty ? 'addr-${list.length + 1}' : address.id;
    final shouldBeDefault = address.isDefault || list.isEmpty;
    final model = AddressModel(
      id: id,
      label: address.label,
      fullName: address.fullName,
      phone: address.phone,
      street: address.street,
      city: address.city,
      country: address.country,
      zip: address.zip,
      isDefault: shouldBeDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (shouldBeDefault) {
      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        list[i] = AddressModel(
          id: item.id,
          label: item.label,
          fullName: item.fullName,
          phone: item.phone,
          street: item.street,
          city: item.city,
          country: item.country,
          zip: item.zip,
          isDefault: false,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
        );
      }
    }
    list.add(model);
    _store[userId] = list;
  }

  @override
  Future<void> updateAddress(String userId, AddressModel address) async {
    final list = List<AddressModel>.from(_store[userId] ?? const []);
    final index = list.indexWhere((item) => item.id == address.id);
    if (index == -1) {
      return;
    }
    list[index] = address.copyWith(updatedAt: DateTime.now());
    if (address.isDefault) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].id != address.id) {
          final item = list[i];
          list[i] = item.copyWith(isDefault: false);
        }
      }
    }
    _store[userId] = list;
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    final list = List<AddressModel>.from(_store[userId] ?? const []);
    list.removeWhere((item) => item.id == addressId);
    _store[userId] = list;
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    final list = List<AddressModel>.from(_store[userId] ?? const []);
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      list[i] = item.copyWith(
        isDefault: item.id == addressId,
        updatedAt: DateTime.now(),
      );
    }
    _store[userId] = list;
  }

  void reset() => _store.clear();
}
