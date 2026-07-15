/// UTC day keys compatible with Cloud Functions `dayKeyFromCreatedAt`
/// (`toISOString().slice(0, 10)`) and web `statsDailyKeysRollingUtc`.
List<String> statsDailyKeysRollingUtc(int dayCount) {
  if (dayCount <= 0) {
    return const [];
  }
  final now = DateTime.now().toUtc();
  final out = <String>[];
  for (var i = dayCount - 1; i >= 0; i--) {
    final day = DateTime.utc(now.year, now.month, now.day - i);
    out.add(_formatUtcDayKey(day));
  }
  return out;
}

String statsDailyTodayUtcKey() => statsDailyKeysRollingUtc(1).single;

String _formatUtcDayKey(DateTime utcDay) {
  final y = utcDay.year.toString().padLeft(4, '0');
  final m = utcDay.month.toString().padLeft(2, '0');
  final d = utcDay.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Maps web `donut_*` segments into mobile status buckets (display only).
abstract final class OwnerOrderStatusBuckets {
  static int pendingFromDonut(Map<String, int> donut) =>
      donut['received'] ?? 0;

  static int processingFromDonut(Map<String, int> donut) {
    return (donut['confirmed'] ?? 0) +
        (donut['prepared'] ?? 0) +
        (donut['shipped'] ?? 0) +
        (donut['in_transit'] ?? 0);
  }

  static int completedFromDonut(Map<String, int> donut) =>
      donut['delivered'] ?? 0;

  static int cancelledFromDonut(Map<String, int> donut) {
    return (donut['canceled'] ?? 0) + (donut['returned'] ?? 0);
  }
}

/// Same thresholds as `productStatsShared.productStockTier` on web.
abstract final class OwnerStockThresholds {
  static const int inStockMin = 10;
  static const int lowStockMax = 9; // stock 1..9
  static const int outOfStockMax = 0;

  static bool isLowStock(int stock) => stock >= 1 && stock <= lowStockMax;
}
