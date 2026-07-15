import '../../domain/entities/owner_dashboard_entities.dart';

abstract class OwnerDashboardDataSource {
  Future<OwnerDashboardSnapshot> fetchSnapshot();
}
