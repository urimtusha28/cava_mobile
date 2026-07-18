class OrderCustomerEntity {
  const OrderCustomerEntity({
    this.name,
    this.email,
    this.phone,
    this.address,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? address;

  bool get hasInfo =>
      (name != null && name!.trim().isNotEmpty) ||
      (email != null && email!.trim().isNotEmpty) ||
      (phone != null && phone!.trim().isNotEmpty) ||
      (address != null && address!.trim().isNotEmpty);
}
