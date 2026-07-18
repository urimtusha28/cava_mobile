import 'package:flutter_test/flutter_test.dart';

import 'package:cava_ecommerce/features/owner_dashboard/domain/entities/owner_dashboard_entities.dart';
import 'package:cava_ecommerce/features/owner_dashboard/presentation/utils/owner_orders_grouping.dart';

void main() {
  OwnerRecentOrder order({
    required String id,
    required String status,
    DateTime? createdAt,
  }) {
    return OwnerRecentOrder(
      id: id,
      orderNumber: id,
      customerName: 'Test',
      total: 10,
      statusLabel: status,
      paymentMethod: 'cash',
      paymentStatus: 'unpaid',
      createdAt: createdAt,
    );
  }

  group('isCourierFulfillmentStatus', () {
    test('shipped and later are courier', () {
      expect(isCourierFulfillmentStatus('shipped'), isTrue);
      expect(isCourierFulfillmentStatus('in_transit'), isTrue);
      expect(isCourierFulfillmentStatus('delivered'), isTrue);
      expect(isCourierFulfillmentStatus('returned'), isTrue);
      expect(isCourierFulfillmentStatus('Fulfilled'), isTrue);
    });

    test('store pipeline is not courier', () {
      expect(isCourierFulfillmentStatus('received'), isFalse);
      expect(isCourierFulfillmentStatus('confirmed'), isFalse);
      expect(isCourierFulfillmentStatus('prepared'), isFalse);
      expect(isCourierFulfillmentStatus('canceled'), isFalse);
    });
  });

  group('filterOrdersForTab', () {
    test('moves shipped order to courier tab', () {
      final orders = [
        order(id: '1', status: 'prepared'),
        order(id: '2', status: 'shipped'),
      ];

      final store = filterOrdersForTab(orders, OwnerOrdersListTab.store);
      final courier = filterOrdersForTab(orders, OwnerOrdersListTab.courier);

      expect(store.map((o) => o.id), ['1']);
      expect(courier.map((o) => o.id), ['2']);
    });

    test('uses statusOf override after dropdown change', () {
      final orders = [order(id: '1', status: 'prepared')];

      final before = filterOrdersForTab(orders, OwnerOrdersListTab.store);
      expect(before, hasLength(1));

      final after = filterOrdersForTab(
        orders,
        OwnerOrdersListTab.courier,
        statusOf: (_) => 'shipped',
      );
      expect(after.map((o) => o.id), ['1']);
    });
  });

  group('groupOrdersByMonthAndDay', () {
    test('groups newest month and day first', () {
      final orders = [
        order(id: 'a', status: 'received', createdAt: DateTime(2026, 7, 18)),
        order(id: 'b', status: 'received', createdAt: DateTime(2026, 7, 10)),
        order(id: 'c', status: 'received', createdAt: DateTime(2026, 6, 5)),
      ];

      final groups = groupOrdersByMonthAndDay(orders);

      expect(groups, hasLength(2));
      expect(groups[0].month, DateTime(2026, 7));
      expect(groups[0].days, hasLength(2));
      expect(groups[0].days[0].day, DateTime(2026, 7, 18));
      expect(groups[0].days[0].orders.single.id, 'a');
      expect(groups[0].days[1].day, DateTime(2026, 7, 10));
      expect(groups[1].month, DateTime(2026, 6));
      expect(groups[1].days.single.orders.single.id, 'c');
    });
  });
}
