import 'package:cava_ecommerce/features/checkout/domain/entities/place_order_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceOrderResultEntity.displayOrderNumber', () {
    test('prefers sequential orderNumber over Firestore id', () {
      const result = PlaceOrderResultEntity(
        orderId: 'vjMy9wAbCdEfGhIj',
        orderNumber: '10009',
        total: 12,
        paymentMethod: 'cash',
      );
      expect(result.displayOrderNumber, '#10009');
    });

    test('parses orderNumber from callable map (string or int)', () {
      final fromString = PlaceOrderResultEntity.fromMap({
        'orderId': 'vjMy9wAbCdEfGhIj',
        'orderNumber': '10009',
        'totals': {'total': 42},
        'paymentMethod': 'cash',
      });
      expect(fromString.orderNumber, '10009');
      expect(fromString.displayOrderNumber, '#10009');
      expect(fromString.total, 42);

      final fromInt = PlaceOrderResultEntity.fromMap({
        'orderId': 'vjMy9wAbCdEfGhIj',
        'orderNumber': 10009,
        'totals': {'total': 42},
      });
      expect(fromInt.orderNumber, '10009');
      expect(fromInt.displayOrderNumber, '#10009');
    });

    test('legacy fallback uses full orderId, not a truncated suffix', () {
      const result = PlaceOrderResultEntity(
        orderId: 'vjMy9wAbCdEfGhIj',
        total: 12,
        paymentMethod: 'cash',
      );
      expect(result.displayOrderNumber, '#vjMy9wAbCdEfGhIj');
      expect(result.displayOrderNumber, isNot('#vjMy9w'));
    });
  });
}
