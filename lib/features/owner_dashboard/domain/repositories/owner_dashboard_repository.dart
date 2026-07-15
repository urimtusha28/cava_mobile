import '../entities/owner_dashboard_entities.dart';

abstract class OwnerDashboardRepository {
  /// One-shot load matching web Overview sources (`statsDaily`, `stats/summary`,
  /// `stats/productsSummary`, recent `orders`).
  Future<OwnerDashboardSnapshot> getDashboardSnapshot();
}
