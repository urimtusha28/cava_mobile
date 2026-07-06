import '../../../../core/state/auth_state_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource) {
    AuthStateNotifier.update(_dataSource.isLoggedIn());
  }

  final AuthDataSource _dataSource;

  void _notifyChange() {
    AuthStateNotifier.update(_dataSource.isLoggedIn());
  }

  @override
  bool isLoggedIn() => _dataSource.isLoggedIn();

  @override
  String getUserName() => _dataSource.getUserName();

  @override
  void login() {
    _dataSource.login();
    _notifyChange();
  }

  @override
  void logout() {
    _dataSource.logout();
    _notifyChange();
  }
}
