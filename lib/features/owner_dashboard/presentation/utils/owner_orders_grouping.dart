import '../../domain/entities/owner_dashboard_entities.dart';

/// Tab filter for owner orders list.
enum OwnerOrdersListTab {
  /// In-store pipeline: received → confirmed → prepared (+ canceled).
  store,

  /// Handed to courier and beyond: shipped → in_transit → delivered (+ returned).
  courier,
}

/// Statuses that belong on the Postieri (courier) tab.
///
/// Trigger: choosing «U dërgua te postieri» (`shipped`) moves the order here;
/// later courier statuses stay on this tab.
bool isCourierFulfillmentStatus(String raw) {
  final lower = raw.trim().toLowerCase();
  return lower == 'shipped' ||
      lower == 'in_transit' ||
      lower == 'delivered' ||
      lower == 'fulfilled' ||
      lower == 'returned';
}

List<OwnerRecentOrder> filterOrdersForTab(
  List<OwnerRecentOrder> orders,
  OwnerOrdersListTab tab, {
  String Function(OwnerRecentOrder order)? statusOf,
}) {
  String resolve(OwnerRecentOrder o) =>
      statusOf?.call(o) ?? o.statusLabel;

  return orders
      .where((o) {
        final courier = isCourierFulfillmentStatus(resolve(o));
        return tab == OwnerOrdersListTab.courier ? courier : !courier;
      })
      .toList(growable: false);
}

/// Day bucket under a month.
class OwnerOrdersDayGroup {
  const OwnerOrdersDayGroup({
    required this.day,
    required this.orders,
  });

  /// Date-only (time stripped) for the group header.
  final DateTime day;
  final List<OwnerRecentOrder> orders;
}

/// Month bucket containing day groups (newest day first).
class OwnerOrdersMonthGroup {
  const OwnerOrdersMonthGroup({
    required this.month,
    required this.days,
  });

  /// First day of the month (local).
  final DateTime month;
  final List<OwnerOrdersDayGroup> days;
}

/// Groups orders by month → day. Orders without [createdAt] go under “unknown”
/// as a single day bucket with epoch day (caller can label specially if needed).
List<OwnerOrdersMonthGroup> groupOrdersByMonthAndDay(
  List<OwnerRecentOrder> orders,
) {
  if (orders.isEmpty) return const [];

  final byMonth = <String, Map<String, List<OwnerRecentOrder>>>{};

  for (final order in orders) {
    final created = order.createdAt?.toLocal();
    final day = created == null
        ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: false)
        : DateTime(created.year, created.month, created.day);
    final monthKey = '${day.year}-${day.month.toString().padLeft(2, '0')}';
    final dayKey =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

    byMonth.putIfAbsent(monthKey, () => <String, List<OwnerRecentOrder>>{});
    byMonth[monthKey]!.putIfAbsent(dayKey, () => <OwnerRecentOrder>[]);
    byMonth[monthKey]![dayKey]!.add(order);
  }

  final monthKeys = byMonth.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  return [
    for (final monthKey in monthKeys)
      OwnerOrdersMonthGroup(
        month: _parseYearMonth(monthKey),
        days: () {
          final dayMap = byMonth[monthKey]!;
          final dayKeys = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));
          return [
            for (final dayKey in dayKeys)
              OwnerOrdersDayGroup(
                day: _parseYearMonthDay(dayKey),
                orders: List<OwnerRecentOrder>.unmodifiable(dayMap[dayKey]!),
              ),
          ];
        }(),
      ),
  ];
}

DateTime _parseYearMonth(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]));
}

DateTime _parseYearMonthDay(String key) {
  final parts = key.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
