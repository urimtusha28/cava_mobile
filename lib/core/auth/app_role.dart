/// Application role for navigation. Maps existing backend roles:
/// - Firestore `users/{uid}.role == "admin"` or custom claim `admin == true`
///   → [AppRole.owner]
/// - `client`, missing, or anything else → [AppRole.customer]
enum AppRole {
  customer,
  owner,
}

abstract final class AppRoleMapper {
  /// Parses backend role string. Accepts `admin` (existing) and `owner` (alias).
  static AppRole fromFirestoreRole(String? role) {
    final normalized = role?.trim().toLowerCase() ?? '';
    if (normalized == 'admin' || normalized == 'owner') {
      return AppRole.owner;
    }
    return AppRole.customer;
  }

  /// Custom claim `admin == true` (same as Firestore rules `isAdmin()`).
  static AppRole fromAdminClaim(bool? isAdmin) {
    if (isAdmin == true) {
      return AppRole.owner;
    }
    return AppRole.customer;
  }
}
