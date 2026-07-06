abstract class AuthRepository {
  bool isLoggedIn();

  String getUserName();

  void login();

  void logout();
}
