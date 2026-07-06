import '../mock/mock_auth.dart';
import 'auth_data_source.dart';

class AuthMockDataSource implements AuthDataSource {
  const AuthMockDataSource();

  @override
  bool isLoggedIn() => MockAuth.isLoggedIn;

  @override
  String getUserName() => MockAuth.userName;

  @override
  void login() => MockAuth.login();

  @override
  void logout() => MockAuth.logout();
}
