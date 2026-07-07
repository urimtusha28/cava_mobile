import 'package:cava_ecommerce/features/account/presentation/utils/order_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatOrderStatus', () {
    test('maps known statuses to Albanian', () {
      expect(formatOrderStatus('open'), 'E hapur');
      expect(formatOrderStatus('delivered'), 'E dorëzuar');
      expect(formatOrderStatus('processing'), 'Në përpunim');
      expect(formatOrderStatus('pending'), 'Në pritje');
      expect(formatOrderStatus('cancelled'), 'E anuluar');
    });

    test('formats unknown status cleanly', () {
      expect(formatOrderStatus('awaiting_pickup'), 'Awaiting Pickup');
    });
  });

  group('formatPaymentStatus', () {
    test('maps known payment statuses to Albanian', () {
      expect(formatPaymentStatus('paid'), 'E paguar');
      expect(formatPaymentStatus('unpaid'), 'E papaguar');
      expect(formatPaymentStatus('pending'), 'Në pritje');
      expect(formatPaymentStatus('failed'), 'Dështuar');
      expect(formatPaymentStatus('refunded'), 'E rimbursuar');
    });

    test('formats unknown payment status cleanly', () {
      expect(formatPaymentStatus('partially_paid'), 'Partially Paid');
    });
  });
}
