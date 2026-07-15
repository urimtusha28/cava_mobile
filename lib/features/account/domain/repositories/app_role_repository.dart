import '../../../../core/auth/app_role.dart';

/// Resolves the signed-in user's app role from backend sources only.
abstract class AppRoleRepository {
  /// Prefers Firebase custom claim `admin`, then `users/{uid}.role`.
  /// Missing / unknown → [AppRole.customer]. Guest → [AppRole.customer].
  Future<AppRole> resolveCurrentRole();
}
