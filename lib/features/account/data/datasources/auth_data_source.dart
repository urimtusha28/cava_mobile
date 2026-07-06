abstract class AuthDataSource {
  bool isLoggedIn();

  String getUserName();

  void login();

  void logout();
}
