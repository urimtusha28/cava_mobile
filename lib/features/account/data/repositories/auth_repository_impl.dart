import 'dart:async';

import '../../../../core/state/auth_state_notifier.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource) {
    _authSubscription = _dataSource.authStateChanges().listen((user) {
      AuthStateNotifier.update(user != null);
    });
  }

  final AuthDataSource _dataSource;
  StreamSubscription<AuthUserEntity?>? _authSubscription;

  @override
  Stream<bool> watchAuthState() => AuthStateNotifier.stream;

  @override
  Future<bool> isLoggedIn() async => _dataSource.currentUser != null;

  @override
  Future<String> getUserName() async {
    return _dataSource.currentUser?.displayLabel ?? '';
  }

  @override
  Future<String?> getCurrentUserId() async => _dataSource.currentUser?.uid;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) {
    return _dataSource.login(email: email, password: password);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) {
    return _dataSource.register(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) {
    return _dataSource.forgotPassword(email: email);
  }

  @override
  Future<void> logout() {
    return _dataSource.logout();
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}
