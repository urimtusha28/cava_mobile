import 'auth_data_source.dart';

/// Firebase Auth placeholder — not wired in Phase 5.
///
/// TODO(Phase 6): Implement with `firebase_auth` when Firebase is enabled.
class AuthFirebaseDataSource implements AuthDataSource {
  const AuthFirebaseDataSource();

  Never _todo() => throw UnimplementedError(
        'AuthFirebaseDataSource is not implemented yet.',
      );

  @override
  bool isLoggedIn() => _todo();

  @override
  String getUserName() => _todo();

  @override
  void login() => _todo();

  @override
  void logout() => _todo();
}
