class AddressEntity {
  const AddressEntity({
    required this.id,
    required this.fullName,
    required this.street,
    required this.city,
    required this.phone,
    this.isDefault = false,
  });

  final String id;
  final String fullName;
  final String street;
  final String city;
  final String phone;
  final bool isDefault;
}
