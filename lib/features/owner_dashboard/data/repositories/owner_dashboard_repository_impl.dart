import '../../domain/entities/owner_dashboard_entities.dart';
import '../../domain/repositories/owner_dashboard_repository.dart';
import '../datasources/owner_dashboard_data_source.dart';

class OwnerDashboardRepositoryImpl implements OwnerDashboardRepository {
  OwnerDashboardRepositoryImpl(this._dataSource);

  final OwnerDashboardDataSource _dataSource;

  @override
  Future<OwnerDashboardSnapshot> getDashboardSnapshot() {
    return _dataSource.fetchSnapshot();
  }
}
