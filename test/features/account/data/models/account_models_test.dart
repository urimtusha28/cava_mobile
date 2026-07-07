import 'package:cava_ecommerce/features/account/data/mappers/order_mapper.dart';
import 'package:cava_ecommerce/features/account/data/models/order_model.dart';
import 'package:cava_ecommerce/features/account/presentation/utils/order_formatters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderModel', () {
    test('toEntity maps fields', () {
      const model = OrderModel(
        id: 'o1',
        orderNumber: '#CP-1',
        status: 'shipped',
        paymentStatus: 'paid',
        total: 18.9,
        itemCount: 2,
        createdAt: null,
      );

      final entity = model.toEntity();
      expect(entity.id, 'o1');
      expect(entity.displayOrderNumber, '#CP-1');
      expect(entity.itemCount, 2);
    });
  });

  group('OrderMapper', () {
    test('maps totals.total from nested totals object', () {
      final model = OrderMapper.fromFirestore('o1', {
        'orderNumber': '#CP-1',
        'status': 'delivered',
        'paymentStatus': 'paid',
        'total': 0,
        'totals': {'total': 8.5, 'subtotal': 8.5},
        'items': [
          {'name': 'Verë', 'quantity': 1, 'price': 8.5, 'total': 8.5},
        ],
        'createdAt': Timestamp.fromDate(DateTime(2026, 2, 1)),
        'userId': 'uid-1',
      });

      expect(model?.total, 8.5);
      expect(model?.totals?.subtotal, 8.5);
    });

    test('falls back to items sum when totals missing', () {
      final model = OrderMapper.fromFirestore('o1', {
        'status': 'pending',
        'paymentStatus': 'pending',
        'items': [
          {'name': 'A', 'quantity': 2, 'price': 4.25},
          {'name': 'B', 'quantity': 1, 'price': 3.0, 'total': 3.0},
        ],
      });

      expect(model?.total, closeTo(11.5, 0.001));
      expect(model?.itemCount, 2);
    });

    test('uses orderNumber when present', () {
      final model = OrderMapper.fromFirestore('long-order-id-123456', {
        'orderNumber': '#CP-99',
        'status': 'pending',
        'paymentStatus': 'paid',
        'totals': {'total': 10},
      });

      expect(model?.toEntity().displayOrderNumber, '#CP-99');
    });

    test('uses short id suffix when orderNumber missing', () {
      final model = OrderMapper.fromFirestore('long-order-id-123456', {
        'status': 'pending',
        'paymentStatus': 'paid',
        'totals': {'total': 10},
      });

      expect(model?.toEntity().displayOrderNumber, 'Porosia #123456');
    });

    test('maps customer and items without crash on missing fields', () {
      final model = OrderMapper.fromFirestore('o1', {
        'status': 'pending',
        'paymentStatus': 'paid',
        'totals': {'total': 5},
      });

      expect(model, isNotNull);
      expect(model!.items, isEmpty);
      expect(model.customer, isNull);
    });
  });

  group('formatPaymentStatus', () {
    test('maps paid to Albanian label', () {
      expect(formatPaymentStatus('paid'), 'E paguar');
    });
  });
}
