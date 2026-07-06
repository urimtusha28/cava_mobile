abstract class AuthRepository {
  Stream<bool> watchAuthState();

  Future<bool> isLoggedIn();

  Future<String> getUserName();

  Future<void> login();

  Future<void> logout();
}
