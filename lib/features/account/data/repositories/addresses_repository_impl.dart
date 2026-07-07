import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/addresses_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/addresses_data_source.dart';
import '../models/address_model.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  AddressesRepositoryImpl(this._dataSource, this._authRepository);

  final AddressesDataSource _dataSource;
  final AuthRepository _authRepository;

  Future<String?> _requireUserId() async {
    return _authRepository.getCurrentUserId();
  }

  @override
  Future<List<AddressEntity>> getAddresses() async {
    final userId = await _requireUserId();
    if (userId == null) {
      return const [];
    }

    final addresses = await _dataSource.getAddresses(userId);
    return addresses.map((address) => address.toEntity()).toList(growable: false);
  }

  @override
  Future<void> addAddress(AddressModel address) async {
    final userId = await _requireUserId();
    if (userId == null) {
      return;
    }
    await _dataSource.addAddress(userId, address);
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    final userId = await _requireUserId();
    if (userId == null) {
      return;
    }
    await _dataSource.updateAddress(userId, address);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final userId = await _requireUserId();
    if (userId == null) {
      return;
    }
    await _dataSource.deleteAddress(userId, addressId);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    final userId = await _requireUserId();
    if (userId == null) {
      return;
    }
    await _dataSource.setDefaultAddress(userId, addressId);
  }
}
