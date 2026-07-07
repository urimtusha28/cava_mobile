import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../data/models/address_model.dart';
import '../entities/address_entity.dart';
import '../repositories/addresses_repository.dart';

class GetAddressesUseCase extends BaseUseCaseNoParams<List<AddressEntity>> {
  GetAddressesUseCase(this._repository);

  final AddressesRepository _repository;

  @override
  Future<Result<List<AddressEntity>>> call() {
    return guard(_repository.getAddresses);
  }
}

class AddAddressParams {
  const AddAddressParams({
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.country,
    this.zip,
    this.isDefault = false,
  });

  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String country;
  final String? zip;
  final bool isDefault;

  AddressModel toModel() {
    return AddressModel(
      id: '',
      label: label.trim(),
      fullName: fullName.trim(),
      phone: phone.trim(),
      street: street.trim(),
      city: city.trim(),
      country: country.trim(),
      zip: zip?.trim(),
      isDefault: isDefault,
    );
  }
}

class AddAddressUseCase extends BaseUseCase<void, AddAddressParams> {
  AddAddressUseCase(this._repository);

  final AddressesRepository _repository;

  @override
  Future<Result<void>> call(AddAddressParams params) {
    return guard(() => _repository.addAddress(params.toModel()));
  }
}

class UpdateAddressParams {
  const UpdateAddressParams({required this.address});

  final AddressModel address;
}

class UpdateAddressUseCase extends BaseUseCase<void, UpdateAddressParams> {
  UpdateAddressUseCase(this._repository);

  final AddressesRepository _repository;

  @override
  Future<Result<void>> call(UpdateAddressParams params) {
    return guard(() => _repository.updateAddress(params.address));
  }
}

class DeleteAddressParams {
  const DeleteAddressParams({required this.addressId});

  final String addressId;
}

class DeleteAddressUseCase extends BaseUseCase<void, DeleteAddressParams> {
  DeleteAddressUseCase(this._repository);

  final AddressesRepository _repository;

  @override
  Future<Result<void>> call(DeleteAddressParams params) {
    return guard(() => _repository.deleteAddress(params.addressId));
  }
}

class SetDefaultAddressParams {
  const SetDefaultAddressParams({required this.addressId});

  final String addressId;
}

class SetDefaultAddressUseCase
    extends BaseUseCase<void, SetDefaultAddressParams> {
  SetDefaultAddressUseCase(this._repository);

  final AddressesRepository _repository;

  @override
  Future<Result<void>> call(SetDefaultAddressParams params) {
    return guard(() => _repository.setDefaultAddress(params.addressId));
  }
}
