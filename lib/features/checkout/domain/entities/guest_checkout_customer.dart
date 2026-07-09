/// Guest delivery / contact fields for checkout (no Firebase Auth account).
class GuestCheckoutCustomer {
  const GuestCheckoutCustomer({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    this.zip = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String zip;

  String get fullName {
    final parts = [firstName.trim(), lastName.trim()]
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    return parts.join(' ');
  }

  bool get isComplete {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        email.contains('@') &&
        phone.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        city.trim().isNotEmpty &&
        country.trim().isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'city': city.trim(),
        'country': country.trim(),
        'zip': zip.trim(),
      };

  factory GuestCheckoutCustomer.fromJson(Map<String, dynamic> json) {
    return GuestCheckoutCustomer(
      firstName: (json['firstName'] as String?)?.trim() ?? '',
      lastName: (json['lastName'] as String?)?.trim() ?? '',
      email: (json['email'] as String?)?.trim() ?? '',
      phone: (json['phone'] as String?)?.trim() ?? '',
      address: (json['address'] as String?)?.trim() ?? '',
      city: (json['city'] as String?)?.trim() ?? '',
      country: (json['country'] as String?)?.trim() ?? '',
      zip: (json['zip'] as String?)?.trim() ?? '',
    );
  }
}
