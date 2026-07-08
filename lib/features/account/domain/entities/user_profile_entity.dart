class UserProfileEntity {
  const UserProfileEntity({
    required this.uid,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.role = 'client',
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    final combined = '$firstName $lastName'.trim();
    if (combined.isNotEmpty) return combined;
    if (name.trim().isNotEmpty) return name.trim();
    return email;
  }
}
