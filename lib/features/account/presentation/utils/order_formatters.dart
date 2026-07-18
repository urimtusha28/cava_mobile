import 'package:cava_ecommerce/l10n/app_localizations.dart';

import 'order_fulfillment_status_l10n.dart';

String formatOrderDate(DateTime? date) {
  if (date == null) {
    return '';
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  return '$day.$month.$year';
}

String formatOrderTotal(double total) {
  return '${total.toStringAsFixed(2).replaceAll('.', ',')} €';
}

String formatOrderStatus(String status, AppLocalizations l10n) {
  switch (status.toLowerCase().trim()) {
    case 'received':
    case 'confirmed':
    case 'prepared':
    case 'shipped':
    case 'in_transit':
    case 'delivered':
    case 'completed':
    case 'returned':
    case 'canceled':
    case 'cancelled':
      return OrderFulfillmentStatusL10n.labelOfRaw(l10n, status);
    case 'open':
      return l10n.orderStatusOpen;
    case 'pending':
      return l10n.orderStatusPending;
    case 'processing':
      return l10n.orderStatusProcessing;
    default:
      return formatUnknownLabel(status, l10n);
  }
}

String formatPaymentMethod(String? method, AppLocalizations l10n) {
  switch (method?.trim().toLowerCase()) {
    case 'cash':
      return l10n.paymentMethodCash;
    case 'card':
    case 'stripe':
      return l10n.paymentMethodCard;
    case 'bank':
      return l10n.paymentMethodBank;
    case null:
    case '':
      return l10n.emDash;
    default:
      return formatUnknownLabel(method!, l10n);
  }
}

String formatPaymentSummary({
  required String? method,
  required String paymentStatus,
  required AppLocalizations l10n,
}) {
  return '${formatPaymentMethod(method, l10n)} · ${formatPaymentStatus(paymentStatus, l10n)}';
}

String formatPaymentStatus(String status, AppLocalizations l10n) {
  switch (status.toLowerCase().trim()) {
    case 'paid':
      return l10n.paymentStatusPaid;
    case 'unpaid':
      return l10n.paymentStatusUnpaid;
    case 'pending':
      return l10n.paymentStatusPending;
    case 'failed':
      return l10n.paymentStatusFailed;
    case 'refunded':
      return l10n.paymentStatusRefunded;
    default:
      return status.isEmpty ? l10n.emDash : formatUnknownLabel(status, l10n);
  }
}

String formatUnknownLabel(String value, AppLocalizations l10n) {
  final cleaned = value.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  if (cleaned.isEmpty) {
    return l10n.emDash;
  }
  return cleaned
      .split(RegExp(r'\s+'))
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
