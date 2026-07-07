import '../../domain/entities/auth_user_entity.dart';

abstract class AuthDataSource {
  Stream<AuthUserEntity?> authStateChanges();

  AuthUserEntity? get currentUser;

  Future<AuthUserEntity> login({
    required String email,
    required String password,
  });

  Future<AuthUserEntity> register({
    required String email,
    required String password,
    String? name,
  });

  Future<void> forgotPassword({required String email});

  Future<void> logout();
}
