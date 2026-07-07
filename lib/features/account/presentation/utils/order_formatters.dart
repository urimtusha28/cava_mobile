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

String formatOrderStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Në pritje';
    case 'processing':
      return 'Duke u përpunuar';
    case 'shipped':
    case 'in_transit':
      return 'Në rrugëtim';
    case 'delivered':
    case 'completed':
      return 'Përfunduar';
    case 'cancelled':
      return 'Anuluar';
    default:
      return status;
  }
}

String formatPaymentStatus(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return 'E paguar';
    case 'pending':
      return 'Në pritje';
    case 'failed':
      return 'Dështoi';
    case 'refunded':
      return 'E rimbursuar';
    default:
      return status.isEmpty ? '—' : status;
  }
}
