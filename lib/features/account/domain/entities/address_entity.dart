class AddressEntity {
  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.country,
    this.zip,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String country;
  final String? zip;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayLine => '$street, $city';
}
