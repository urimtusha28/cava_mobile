import 'package:flutter_test/flutter_test.dart';

import 'package:cava_ecommerce/features/owner_dashboard/domain/entities/owner_dashboard_entities.dart';
import 'package:cava_ecommerce/features/owner_dashboard/presentation/utils/owner_dashboard_today.dart';

void main() {
  OwnerRecentOrder order(String id, DateTime? createdAt) {
    return OwnerRecentOrder(
      id: id,
      orderNumber: id,
      customerName: 'A',
      total: 1,
      statusLabel: 'received',
      paymentMethod: 'cash',
      paymentStatus: 'unpaid',
      createdAt: createdAt,
    );
  }

  test('filterTodaysOrders keeps only local calendar today', () {
    final now = DateTime(2026, 7, 18, 15);
    final list = filterTodaysOrders(
      [
        order('1', DateTime(2026, 7, 18, 9)),
        order('2', DateTime(2026, 7, 17, 22)),
        order('3', null),
        order('4', DateTime(2026, 7, 18, 23, 50)),
      ],
      now: now,
    );

    expect(list.map((o) => o.id), ['1', '4']);
  });
}
