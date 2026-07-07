import '../entities/auth_user_entity.dart';

abstract class AuthRepository {
  Stream<bool> watchAuthState();

  Future<bool> isLoggedIn();

  Future<String> getUserName();

  Future<String?> getCurrentUserId();

  Future<AuthUserEntity?> getCurrentUser();

  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String email,
    required String password,
    String? name,
  });

  Future<void> forgotPassword({required String email});

  Future<void> logout();
}
