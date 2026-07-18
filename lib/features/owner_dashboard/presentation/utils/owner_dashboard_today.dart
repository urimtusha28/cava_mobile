import '../../domain/entities/owner_dashboard_entities.dart';

/// Orders whose [OwnerRecentOrder.createdAt] falls on the local calendar day
/// of [now] (defaults to [DateTime.now]).
List<OwnerRecentOrder> filterTodaysOrders(
  List<OwnerRecentOrder> orders, {
  DateTime? now,
}) {
  final ref = (now ?? DateTime.now()).toLocal();
  return orders
      .where((o) {
        final created = o.createdAt?.toLocal();
        if (created == null) return false;
        return created.year == ref.year &&
            created.month == ref.month &&
            created.day == ref.day;
      })
      .toList(growable: false);
}
