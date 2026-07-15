import 'package:cava_ecommerce/features/owner_dashboard/data/mappers/owner_dashboard_mapper.dart';
import 'package:cava_ecommerce/features/owner_dashboard/domain/utils/owner_dashboard_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('statsDailyKeysRollingUtc', () {
    test('returns requested day count of YYYY-MM-DD keys', () {
      final keys = statsDailyKeysRollingUtc(7);
      expect(keys, hasLength(7));
      for (final key in keys) {
        expect(key, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      }
      expect(keys.last, statsDailyTodayUtcKey());
    });

    test('returns empty for non-positive count', () {
      expect(statsDailyKeysRollingUtc(0), isEmpty);
      expect(statsDailyKeysRollingUtc(-1), isEmpty);
    });
  });

  group('OwnerOrderStatusBuckets', () {
    test('maps donut segments like mobile status cards', () {
      final donut = {
        'received': 3,
        'confirmed': 1,
        'prepared': 2,
        'shipped': 1,
        'in_transit': 1,
        'delivered': 10,
        'canceled': 2,
        'returned': 1,
      };
      expect(OwnerOrderStatusBuckets.pendingFromDonut(donut), 3);
      expect(OwnerOrderStatusBuckets.processingFromDonut(donut), 5);
      expect(OwnerOrderStatusBuckets.completedFromDonut(donut), 10);
      expect(OwnerOrderStatusBuckets.cancelledFromDonut(donut), 3);
    });
  });

  group('OwnerStockThresholds', () {
    test('matches web productStockTier low band 1..9', () {
      expect(OwnerStockThresholds.isLowStock(0), isFalse);
      expect(OwnerStockThresholds.isLowStock(1), isTrue);
      expect(OwnerStockThresholds.isLowStock(9), isTrue);
      expect(OwnerStockThresholds.isLowStock(10), isFalse);
    });
  });

  group('OwnerDashboardMapper.aggregateDailyDocs', () {
    test('sums revenue, orders, buyers and donut fields', () {
      final agg = OwnerDashboardMapper.aggregateDailyDocs(
        dateKeys: const ['2026-07-11', '2026-07-12'],
        dayDocs: const [
          {
            'revenue': 100,
            'orderCount': 2,
            'uniqueBuyerCount': 2,
            'donut_received': 1,
            'donut_delivered': 1,
          },
          {
            'revenue': 50.5,
            'orderCount': 1,
            'uniqueBuyerCount': 1,
            'donut_received': 0,
            'donut_delivered': 1,
          },
        ],
      );
      expect(agg.revenue, 150.5);
      expect(agg.orderCount, 3);
      expect(agg.uniqueBuyersDailySum, 3);
      expect(agg.donutBySegment['received'], 1);
      expect(agg.donutBySegment['delivered'], 2);
      expect(agg.series, hasLength(2));
      expect(agg.series.first.dateKey, '2026-07-11');
    });

    test('missing day docs count as zeros', () {
      final agg = OwnerDashboardMapper.aggregateDailyDocs(
        dateKeys: const ['2026-07-12'],
        dayDocs: const [{}],
      );
      expect(agg.revenue, 0);
      expect(agg.orderCount, 0);
    });
  });

  group('OwnerDashboardMapper.recentOrderFromFirestore', () {
    test('prefers orderNumber over document id', () {
      final order = OwnerDashboardMapper.recentOrderFromFirestore(
        'abcdef123456',
        {
          'orderNumber': 10042,
          'customer': {'fullName': 'Arben K.'},
          'totals': {'total': 89},
          'fulfillmentStatus': 'received',
          'paymentMethod': 'cash',
          'paymentStatus': 'unpaid',
        },
      );
      expect(order.orderNumber, '10042');
      expect(order.customerName, 'Arben K.');
      expect(order.total, 89);
      expect(order.statusLabel, 'received');
    });
  });

  group('OwnerDashboardMapper.buildSummary', () {
    test('builds status buckets from 30-day donut aggregate', () {
      final last7 = OwnerDashboardMapper.aggregateDailyDocs(
        dateKeys: const ['d1'],
        dayDocs: const [
          {'revenue': 10, 'orderCount': 1, 'uniqueBuyerCount': 1},
        ],
      );
      final last30 = OwnerDashboardMapper.aggregateDailyDocs(
        dateKeys: const ['d1'],
        dayDocs: const [
          {
            'revenue': 200,
            'orderCount': 5,
            'uniqueBuyerCount': 4,
            'donut_received': 2,
            'donut_confirmed': 1,
            'donut_delivered': 2,
            'donut_canceled': 1,
          },
        ],
      );
      final summary = OwnerDashboardMapper.buildSummary(
        salesToday: 10,
        last7: last7,
        last30: last30,
        lifetimeRevenue: 1000,
        lifetimeOrders: 50,
        lowStockCount: 3,
        outOfStockCount: 1,
        inStockCount: 20,
      );
      expect(summary.salesToday, 10);
      expect(summary.salesLast7Days, 10);
      expect(summary.salesLast30Days, 200);
      expect(summary.totalRevenue, 1000);
      expect(summary.totalOrders, 50);
      expect(summary.pendingOrders, 2);
      expect(summary.processingOrders, 1);
      expect(summary.completedOrders, 2);
      expect(summary.cancelledOrders, 1);
      expect(summary.newCustomersPeriod, 4);
    });
  });
}
