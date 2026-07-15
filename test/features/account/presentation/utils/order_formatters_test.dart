import 'package:cava_ecommerce/features/account/presentation/utils/order_formatters.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('sq'));

  group('formatOrderStatus', () {
    test('maps known statuses to Albanian', () {
      expect(formatOrderStatus('open', l10n), l10n.orderStatusOpen);
      expect(formatOrderStatus('delivered', l10n), l10n.orderStatusDelivered);
      expect(formatOrderStatus('processing', l10n), l10n.orderStatusProcessing);
      expect(formatOrderStatus('pending', l10n), l10n.orderStatusPending);
      expect(formatOrderStatus('cancelled', l10n), l10n.orderStatusCancelled);
    });

    test('formats unknown status cleanly', () {
      expect(formatOrderStatus('awaiting_pickup', l10n), 'Awaiting Pickup');
    });
  });

  group('formatPaymentStatus', () {
    test('maps known payment statuses to Albanian', () {
      expect(formatPaymentStatus('paid', l10n), l10n.paymentStatusPaid);
      expect(formatPaymentStatus('unpaid', l10n), l10n.paymentStatusUnpaid);
      expect(formatPaymentStatus('pending', l10n), l10n.paymentStatusPending);
      expect(formatPaymentStatus('failed', l10n), l10n.paymentStatusFailed);
      expect(formatPaymentStatus('refunded', l10n), l10n.paymentStatusRefunded);
    });

    test('formats unknown payment status cleanly', () {
      expect(formatPaymentStatus('partially_paid', l10n), 'Partially Paid');
    });
  });
}
