/// Lightweight authenticated user snapshot for the account feature.
class AuthUserEntity {
  const AuthUserEntity({
    required this.uid,
    this.email,
    this.displayName,
  });

  final String uid;
  final String? email;
  final String? displayName;

  String get displayLabel {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return email ?? '';
  }
}
