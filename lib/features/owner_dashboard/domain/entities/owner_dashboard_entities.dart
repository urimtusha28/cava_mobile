class OwnerDashboardSummary {
  const OwnerDashboardSummary({
    required this.salesToday,
    required this.salesLast7Days,
    required this.salesLast30Days,
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.newCustomersPeriod,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.inStockCount,
    this.lastUpdatedAt,
  });

  /// `statsDaily/{todayUTC}.revenue` — para (€), jo numër porosish.
  final double salesToday;

  /// Rolling 7 ditë UTC — si Overview admin (7 ditë).
  final double salesLast7Days;

  /// Rolling 30 ditë UTC — si Overview admin (30 ditë).
  final double salesLast30Days;

  /// Lifetime `stats/summary.totalRevenue`.
  final double totalRevenue;

  /// Lifetime `stats/summary.totalOrders`.
  final int totalOrders;

  /// Sum `donut_received` mbi 30 ditë UTC.
  final int pendingOrders;

  /// Sum `donut_confirmed|prepared|shipped|in_transit` mbi 30 ditë UTC.
  final int processingOrders;

  /// Sum `donut_delivered` mbi 30 ditë UTC.
  final int completedOrders;

  /// Sum `donut_canceled` (+ `donut_returned`) mbi 30 ditë UTC.
  final int cancelledOrders;

  /// Shuma e `uniqueBuyerCount` ditore për 30 ditë — jo unikë cross-day
  /// (si Overview "Klientë").
  final int newCustomersPeriod;

  final int lowStockCount;
  final int outOfStockCount;
  final int inStockCount;
  final DateTime? lastUpdatedAt;
}

class SalesChartPoint {
  const SalesChartPoint({
    required this.dateKey,
    required this.revenue,
    required this.orderCount,
  });

  final String dateKey;
  final double revenue;
  final int orderCount;
}

class OwnerRecentOrder {
  const OwnerRecentOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.total,
    required this.statusLabel,
    required this.paymentMethod,
    required this.paymentStatus,
    this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final double total;
  final String statusLabel;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? createdAt;
}

class TopSellingProduct {
  const TopSellingProduct({
    required this.name,
    required this.soldQuantity,
    required this.revenue,
    this.imageUrl,
  });

  final String name;
  final int soldQuantity;
  final double revenue;
  final String? imageUrl;
}

class LowStockProduct {
  const LowStockProduct({
    required this.id,
    required this.name,
    required this.stock,
    required this.thresholdMax,
  });

  final String id;
  final String name;
  final int stock;

  /// Same as web: low stock is stock in [1, thresholdMax] where thresholdMax = 9.
  final int thresholdMax;
}

class NewCustomerSummary {
  const NewCustomerSummary({
    required this.label,
    required this.count,
    required this.periodDays,
  });

  /// Display label (web semantics: daily distinct buyers sum).
  final String label;
  final int count;
  final int periodDays;
}

/// Snapshot returned by one dashboard load (mirrors web Overview data sources).
class OwnerDashboardSnapshot {
  const OwnerDashboardSnapshot({
    required this.summary,
    required this.chartLast7Days,
    required this.recentOrders,
    required this.lowStockProducts,
    required this.topSellingProducts,
    required this.newCustomers,
  });

  final OwnerDashboardSummary summary;
  final List<SalesChartPoint> chartLast7Days;
  final List<OwnerRecentOrder> recentOrders;
  final List<LowStockProduct> lowStockProducts;

  /// Empty when website has no top-selling aggregation (expected).
  final List<TopSellingProduct> topSellingProducts;
  final NewCustomerSummary newCustomers;
}
