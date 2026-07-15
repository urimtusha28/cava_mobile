import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/owner_dashboard/domain/entities/owner_dashboard_entities.dart';
import 'package:cava_ecommerce/features/owner_dashboard/domain/repositories/owner_dashboard_repository.dart';
import 'package:cava_ecommerce/features/owner_dashboard/domain/usecases/get_owner_dashboard_snapshot.dart';
import 'package:cava_ecommerce/features/owner_dashboard/presentation/controllers/owner_dashboard_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOwnerDashboardRepository extends Mock
    implements OwnerDashboardRepository {}

void main() {
  late MockOwnerDashboardRepository repository;
  late OwnerDashboardController controller;

  OwnerDashboardSnapshot emptySnapshot() {
    return const OwnerDashboardSnapshot(
      summary: OwnerDashboardSummary(
        salesToday: 0,
        salesLast7Days: 0,
        salesLast30Days: 0,
        totalRevenue: 0,
        totalOrders: 0,
        pendingOrders: 0,
        processingOrders: 0,
        completedOrders: 0,
        cancelledOrders: 0,
        newCustomersPeriod: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        inStockCount: 0,
      ),
      chartLast7Days: [],
      recentOrders: [],
      lowStockProducts: [],
      topSellingProducts: [],
      newCustomers: NewCustomerSummary(
        label: 'Blerës unikë ditorë (30 ditë)',
        count: 0,
        periodDays: 30,
      ),
    );
  }

  OwnerDashboardSnapshot populatedSnapshot() {
    return const OwnerDashboardSnapshot(
      summary: OwnerDashboardSummary(
        salesToday: 100,
        salesLast7Days: 500,
        salesLast30Days: 2000,
        totalRevenue: 10000,
        totalOrders: 40,
        pendingOrders: 2,
        processingOrders: 3,
        completedOrders: 30,
        cancelledOrders: 1,
        newCustomersPeriod: 12,
        lowStockCount: 4,
        outOfStockCount: 1,
        inStockCount: 50,
      ),
      chartLast7Days: [
        SalesChartPoint(dateKey: '2026-07-12', revenue: 100, orderCount: 1),
      ],
      recentOrders: [
        OwnerRecentOrder(
          id: '1',
          orderNumber: '10001',
          customerName: 'Test',
          total: 50,
          statusLabel: 'received',
          paymentMethod: 'cash',
          paymentStatus: 'unpaid',
        ),
      ],
      lowStockProducts: [],
      topSellingProducts: [],
      newCustomers: NewCustomerSummary(
        label: 'Blerës unikë ditorë (30 ditë)',
        count: 12,
        periodDays: 30,
      ),
    );
  }

  setUp(() {
    repository = MockOwnerDashboardRepository();
    controller = OwnerDashboardController(
      GetOwnerDashboardSnapshotUseCase(repository),
    );
  });

  test('load success with data', () async {
    when(() => repository.getDashboardSnapshot())
        .thenAnswer((_) async => populatedSnapshot());

    await controller.load();

    expect(controller.status, OwnerDashboardViewStatus.success);
    expect(controller.snapshot?.summary.salesToday, 100);
    expect(controller.snapshot?.topSellingProducts, isEmpty);
  });

  test('load empty when no orders and no sales', () async {
    when(() => repository.getDashboardSnapshot())
        .thenAnswer((_) async => emptySnapshot());

    await controller.load();

    expect(controller.status, OwnerDashboardViewStatus.empty);
  });

  test('load error on permission denied', () async {
    when(() => repository.getDashboardSnapshot()).thenThrow(
      const AuthFailure(
        message: 'Nuk ke të drejta për dashboard-in e pronarit.',
        code: 'PERMISSION_DENIED',
      ),
    );

    await controller.load();

    expect(controller.status, OwnerDashboardViewStatus.error);
    expect(controller.sectionError, contains('të drejta'));
  });

  test('refresh keeps previous snapshot on failure', () async {
    when(() => repository.getDashboardSnapshot())
        .thenAnswer((_) async => populatedSnapshot());
    await controller.load();

    when(() => repository.getDashboardSnapshot()).thenThrow(
      const ServerFailure(message: 'Rifreskimi dështoi.', code: 'unavailable'),
    );
    await controller.refresh();

    expect(controller.snapshot?.summary.totalOrders, 40);
    expect(controller.status, OwnerDashboardViewStatus.success);
    expect(controller.sectionError, isNotNull);
  });

  test('use case wraps repository errors', () async {
    when(() => repository.getDashboardSnapshot()).thenThrow(
      const AuthFailure(message: 'denied', code: 'PERMISSION_DENIED'),
    );
    final useCase = GetOwnerDashboardSnapshotUseCase(repository);
    final result = await useCase();
    expect(result.isFailure, isTrue);
    expect(result, isA<Error<OwnerDashboardSnapshot>>());
  });
}
