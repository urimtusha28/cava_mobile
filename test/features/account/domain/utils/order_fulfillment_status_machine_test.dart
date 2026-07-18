import 'package:cava_ecommerce/features/account/domain/entities/order_fulfillment_status.dart';
import 'package:cava_ecommerce/features/account/domain/utils/order_fulfillment_status_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeFulfillmentForTransitions', () {
    test('normalizes legacy fulfilled to delivered', () {
      expect(
        normalizeFulfillmentForTransitions('fulfilled'),
        FulfillmentStatusDetail.delivered,
      );
    });

    test('falls back to received for unknown values', () {
      expect(
        normalizeFulfillmentForTransitions('mystery'),
        FulfillmentStatusDetail.received,
      );
    });
  });

  group('allowedStatusesForCurrent', () {
    test('returns all statuses for non-terminal status', () {
      expect(
        allowedStatusesForCurrent('received'),
        fulfillmentStatusDetailValues,
      );
    });

    test('returns only current status for terminal states', () {
      expect(
        allowedStatusesForCurrent('canceled'),
        [FulfillmentStatusDetail.canceled],
      );
      expect(
        allowedStatusesForCurrent('returned'),
        [FulfillmentStatusDetail.returned],
      );
    });
  });
}
