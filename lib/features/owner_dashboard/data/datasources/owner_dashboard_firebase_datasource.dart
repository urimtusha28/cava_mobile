import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/owner_dashboard_entities.dart';
import '../../domain/utils/owner_dashboard_metrics.dart';
import '../mappers/owner_dashboard_mapper.dart';
import 'owner_dashboard_data_source.dart';

/// Mirrors web admin Overview data sources:
/// - `statsDaily/{YYYY-MM-DD}` via rolling UTC keys
/// - `stats/summary`
/// - `stats/productsSummary`
/// - recent `orders` (createdAt desc; overview UI takes first 8)
/// - low-stock product list (stock 1..9, limit 10)
class OwnerDashboardFirebaseDataSource implements OwnerDashboardDataSource {
  OwnerDashboardFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Higher limit so the dedicated Orders screen can group by month/day.
  /// Overview still shows only the first 8 via `.take(8)`.
  static const _recentOrdersLimit = 80;
  static const _lowStockListLimit = 10;

  @override
  Future<OwnerDashboardSnapshot> fetchSnapshot() async {
    try {
      final keys7 = statsDailyKeysRollingUtc(7);
      final keys30 = statsDailyKeysRollingUtc(30);
      final todayKey = statsDailyTodayUtcKey();

      final last7Future = _fetchDailyAggregate(keys7);
      final last30Future = _fetchDailyAggregate(keys30);
      final summaryFuture = _fetchStatsSummary();
      final productsFuture = _fetchProductsSummary();
      final recentFuture = _fetchRecentOrders();
      final lowStockFuture = _fetchLowStockProducts();
      final todayFuture = _fetchSingleDayRevenue(todayKey);

      final last7 = await last7Future;
      final last30 = await last30Future;
      final summaryDoc = await summaryFuture;
      final products = await productsFuture;
      final recent = await recentFuture;
      final lowStockList = await lowStockFuture;
      final salesToday = await todayFuture;

      final summary = OwnerDashboardMapper.buildSummary(
        salesToday: salesToday,
        last7: last7,
        last30: last30,
        lifetimeRevenue: summaryDoc.revenue,
        lifetimeOrders: summaryDoc.orders,
        lowStockCount: products.lowStock,
        outOfStockCount: products.outStock,
        inStockCount: products.inStock,
      );

      return OwnerDashboardSnapshot(
        summary: summary,
        chartLast7Days: last7.series,
        recentOrders: recent,
        lowStockProducts: lowStockList,
        // Website admin has no top-selling aggregation — keep empty.
        topSellingProducts: const [],
        newCustomers: NewCustomerSummary(
          label: 'Blerës unikë ditorë (30 ditë)',
          count: last30.uniqueBuyersDailySum,
          periodDays: 30,
        ),
      );
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw const AuthFailure(
          message: 'Nuk ke të drejta për dashboard-in e pronarit.',
          code: 'PERMISSION_DENIED',
        );
      }
      throw ServerFailure(
        message: 'Dashboard nuk u ngarkua. Provo përsëri.',
        code: error.code,
      );
    }
  }

  Future<StatsDailyAggregateModel> _fetchDailyAggregate(
    List<String> dateKeys,
  ) async {
    final docs = await Future.wait(
      dateKeys.map((key) async {
        final snap =
            await _firestore.collection(FirebaseConfig.statsDailyCollection).doc(key).get();
        if (!snap.exists) {
          return <String, dynamic>{};
        }
        return snap.data() ?? <String, dynamic>{};
      }),
    );
    return OwnerDashboardMapper.aggregateDailyDocs(
      dateKeys: dateKeys,
      dayDocs: docs,
    );
  }

  Future<double> _fetchSingleDayRevenue(String dayKey) async {
    final snap = await _firestore
        .collection(FirebaseConfig.statsDailyCollection)
        .doc(dayKey)
        .get();
    if (!snap.exists) {
      return 0;
    }
    return OwnerDashboardMapper.numAgg(snap.data()?['revenue']);
  }

  Future<({double revenue, int orders})> _fetchStatsSummary() async {
    final snap = await _firestore
        .collection(FirebaseConfig.statsCollection)
        .doc('summary')
        .get();
    if (!snap.exists) {
      return (revenue: 0.0, orders: 0);
    }
    final data = snap.data() ?? {};
    return (
      revenue: OwnerDashboardMapper.numAgg(data['totalRevenue']),
      orders: OwnerDashboardMapper.intAgg(data['totalOrders']),
    );
  }

  Future<({int lowStock, int outStock, int inStock})>
      _fetchProductsSummary() async {
    final snap = await _firestore
        .collection(FirebaseConfig.statsCollection)
        .doc('productsSummary')
        .get();
    if (!snap.exists) {
      return (lowStock: 0, outStock: 0, inStock: 0);
    }
    final data = snap.data() ?? {};
    return (
      lowStock: OwnerDashboardMapper.intAgg(data['lowStock']),
      outStock: OwnerDashboardMapper.intAgg(data['outStock']),
      inStock: OwnerDashboardMapper.intAgg(data['inStock']),
    );
  }

  Future<List<OwnerRecentOrder>> _fetchRecentOrders() async {
    final snap = await _firestore
        .collection(FirebaseConfig.ordersCollection)
        .orderBy('createdAt', descending: true)
        .limit(_recentOrdersLimit)
        .get();
    return snap.docs
        .map(
          (doc) => OwnerDashboardMapper.recentOrderFromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<LowStockProduct>> _fetchLowStockProducts() async {
    try {
      final snap = await _firestore
          .collection(FirebaseConfig.productsCollection)
          .where('stock', isLessThan: OwnerStockThresholds.inStockMin)
          .orderBy('stock')
          .limit(_lowStockListLimit * 2)
          .get();

      final items = <LowStockProduct>[];
      for (final doc in snap.docs) {
        final stock = OwnerDashboardMapper.intAgg(doc.data()['stock']);
        if (!OwnerStockThresholds.isLowStock(stock)) {
          continue;
        }
        items.add(OwnerDashboardMapper.lowStockFromFirestore(doc.id, doc.data()));
        if (items.length >= _lowStockListLimit) {
          break;
        }
      }
      return items;
    } on FirebaseException {
      return const [];
    }
  }
}
