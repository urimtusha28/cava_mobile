import 'dart:async';

import '../../../../core/state/auth_state_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource) {
    AuthStateNotifier.update(_dataSource.isLoggedIn());
  }

  final AuthDataSource _dataSource;

  @override
  Stream<bool> watchAuthState() => AuthStateNotifier.stream;

  @override
  Future<bool> isLoggedIn() => Future.sync(_dataSource.isLoggedIn);

  @override
  Future<String> getUserName() => Future.sync(_dataSource.getUserName);

  @override
  Future<void> login() => Future.sync(() {
        _dataSource.login();
        AuthStateNotifier.update(true);
      });

  @override
  Future<void> logout() => Future.sync(() {
        _dataSource.logout();
        AuthStateNotifier.update(false);
      });
}
