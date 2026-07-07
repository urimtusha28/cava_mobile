import 'dart:async';

import '../../domain/entities/auth_user_entity.dart';
import '../mock/mock_auth.dart';
import 'auth_data_source.dart';

class AuthMockDataSource implements AuthDataSource {
  const AuthMockDataSource();

  @override
  Stream<AuthUserEntity?> authStateChanges() {
    late final StreamController<AuthUserEntity?> controller;

    void emit() {
      if (!controller.isClosed) {
        controller.add(MockAuth.isLoggedIn ? MockAuth.currentUser : null);
      }
    }

    controller = StreamController<AuthUserEntity?>(
      onListen: () {
        emit();
        MockAuth.revision.addListener(emit);
      },
      onCancel: () => MockAuth.revision.removeListener(emit),
    );

    return controller.stream;
  }

  @override
  AuthUserEntity? get currentUser =>
      MockAuth.isLoggedIn ? MockAuth.currentUser : null;

  @override
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    MockAuth.login();
    return MockAuth.currentUser;
  }

  @override
  Future<AuthUserEntity> register({
    required String email,
    required String password,
    String? name,
  }) async {
    MockAuth.login();
    return AuthUserEntity(
      uid: MockAuth.currentUser.uid,
      email: email.trim(),
      displayName: name?.trim().isNotEmpty == true ? name!.trim() : null,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> logout() {
    MockAuth.logout();
    return Future<void>.value();
  }
}
