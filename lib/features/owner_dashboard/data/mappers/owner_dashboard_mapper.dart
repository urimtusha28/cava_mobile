import '../../domain/entities/owner_dashboard_entities.dart';
import '../../domain/utils/owner_dashboard_metrics.dart';

class StatsDailyAggregateModel {
  const StatsDailyAggregateModel({
    required this.revenue,
    required this.orderCount,
    required this.uniqueBuyersDailySum,
    required this.donutBySegment,
    required this.series,
  });

  final double revenue;
  final int orderCount;
  final int uniqueBuyersDailySum;
  final Map<String, int> donutBySegment;
  final List<SalesChartPoint> series;
}

abstract final class OwnerDashboardMapper {
  static double numAgg(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static int intAgg(Object? value) => numAgg(value).round();

  static StatsDailyAggregateModel aggregateDailyDocs({
    required List<String> dateKeys,
    required List<Map<String, dynamic>> dayDocs,
  }) {
    var revenue = 0.0;
    var orderCount = 0;
    var uniqueBuyers = 0;
    final donut = <String, int>{};
    final series = <SalesChartPoint>[];

    for (var i = 0; i < dateKeys.length; i++) {
      final d = i < dayDocs.length ? dayDocs[i] : const <String, dynamic>{};
      final dayRevenue = numAgg(d['revenue']);
      final dayOrders = intAgg(d['orderCount']);
      series.add(
        SalesChartPoint(
          dateKey: dateKeys[i],
          revenue: dayRevenue,
          orderCount: dayOrders,
        ),
      );
      revenue += dayRevenue;
      orderCount += dayOrders;
      uniqueBuyers += intAgg(d['uniqueBuyerCount']);
      for (final entry in d.entries) {
        if (!entry.key.startsWith('donut_')) {
          continue;
        }
        final seg = entry.key.substring('donut_'.length);
        final add = intAgg(entry.value);
        if (add != 0) {
          donut[seg] = (donut[seg] ?? 0) + add;
        }
      }
    }

    return StatsDailyAggregateModel(
      revenue: revenue,
      orderCount: orderCount,
      uniqueBuyersDailySum: uniqueBuyers,
      donutBySegment: donut,
      series: series,
    );
  }

  static OwnerDashboardSummary buildSummary({
    required double salesToday,
    required StatsDailyAggregateModel last7,
    required StatsDailyAggregateModel last30,
    required double lifetimeRevenue,
    required int lifetimeOrders,
    required int lowStockCount,
    required int outOfStockCount,
    required int inStockCount,
  }) {
    final donut = last30.donutBySegment;
    return OwnerDashboardSummary(
      salesToday: salesToday,
      salesLast7Days: last7.revenue,
      salesLast30Days: last30.revenue,
      totalRevenue: lifetimeRevenue,
      totalOrders: lifetimeOrders,
      pendingOrders: OwnerOrderStatusBuckets.pendingFromDonut(donut),
      processingOrders: OwnerOrderStatusBuckets.processingFromDonut(donut),
      completedOrders: OwnerOrderStatusBuckets.completedFromDonut(donut),
      cancelledOrders: OwnerOrderStatusBuckets.cancelledFromDonut(donut),
      newCustomersPeriod: last30.uniqueBuyersDailySum,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      inStockCount: inStockCount,
      lastUpdatedAt: DateTime.now().toUtc(),
    );
  }

  static OwnerRecentOrder recentOrderFromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final customer = data['customer'];
    final customerMap =
        customer is Map ? Map<String, dynamic>.from(customer) : null;
    final fullName = (customerMap?['fullName'] as String?)?.trim() ?? '';
    final first = (customerMap?['firstName'] as String?)?.trim() ?? '';
    final last = (customerMap?['lastName'] as String?)?.trim() ?? '';
    final name = fullName.isNotEmpty
        ? fullName
        : '$first $last'.trim().isEmpty
            ? '—'
            : '$first $last'.trim();

    final orderNumberRaw = data['orderNumber'];
    final orderNumber = switch (orderNumberRaw) {
      num n => n.toInt().toString(),
      String s when s.trim().isNotEmpty => s.trim(),
      _ => id.length >= 6 ? id.substring(id.length - 6).toUpperCase() : id,
    };

    final totals = data['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final total = numAgg(totalsMap?['total'] ?? data['total']);

    final fulfillment = (data['fulfillmentStatus'] as String?)?.trim() ??
        (data['status'] as String?)?.trim() ??
        '';
    final paymentMethod = (data['paymentMethod'] as String?)?.trim() ?? '';
    final paymentStatus = (data['paymentStatus'] as String?)?.trim() ?? '';

    DateTime? createdAt;
    final rawCreated = data['createdAt'];
    if (rawCreated is DateTime) {
      createdAt = rawCreated;
    } else if (rawCreated != null) {
      try {
        // cloud_firestore Timestamp
        createdAt = (rawCreated as dynamic).toDate() as DateTime?;
      } catch (_) {
        createdAt = null;
      }
    }

    return OwnerRecentOrder(
      id: id,
      orderNumber: orderNumber,
      customerName: name,
      total: total,
      // Raw fulfillment / status code — localize in presentation via
      // [OwnerOrderStatusL10n.labelOf].
      statusLabel: fulfillment,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
    );
  }

  static LowStockProduct lowStockFromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return LowStockProduct(
      id: id,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : id,
      stock: intAgg(data['stock']),
      thresholdMax: OwnerStockThresholds.lowStockMax,
    );
  }
}
