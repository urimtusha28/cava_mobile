enum SenderRole {
  customer,
  admin,
  owner;

  static SenderRole fromString(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'customer' => SenderRole.customer,
      'admin' => SenderRole.admin,
      'owner' => SenderRole.owner,
      _ => SenderRole.customer,
    };
  }

  String get firestoreValue => name;

  bool get isStaff => this == SenderRole.admin || this == SenderRole.owner;
}
