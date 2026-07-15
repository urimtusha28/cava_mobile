import 'package:cava_ecommerce/l10n/app_localizations.dart';

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
    case 'open':
      return l10n.orderStatusOpen;
    case 'pending':
      return l10n.orderStatusPending;
    case 'processing':
      return l10n.orderStatusProcessing;
    case 'shipped':
    case 'in_transit':
      return l10n.orderStatusShipped;
    case 'delivered':
    case 'completed':
      return l10n.orderStatusDelivered;
    case 'cancelled':
    case 'canceled':
      return l10n.orderStatusCancelled;
    default:
      return formatUnknownLabel(status, l10n);
  }
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
