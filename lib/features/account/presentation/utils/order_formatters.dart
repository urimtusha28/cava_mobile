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
  switch (status.toLowerCase().trim()) {
    case 'open':
      return 'E hapur';
    case 'pending':
      return 'Në pritje';
    case 'processing':
      return 'Në përpunim';
    case 'shipped':
    case 'in_transit':
      return 'Në rrugëtim';
    case 'delivered':
    case 'completed':
      return 'E dorëzuar';
    case 'cancelled':
    case 'canceled':
      return 'E anuluar';
    default:
      return formatUnknownLabel(status);
  }
}

String formatPaymentStatus(String status) {
  switch (status.toLowerCase().trim()) {
    case 'paid':
      return 'E paguar';
    case 'unpaid':
      return 'E papaguar';
    case 'pending':
      return 'Në pritje';
    case 'failed':
      return 'Dështuar';
    case 'refunded':
      return 'E rimbursuar';
    default:
      return status.isEmpty ? '—' : formatUnknownLabel(status);
  }
}

String formatUnknownLabel(String value) {
  final cleaned = value.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  if (cleaned.isEmpty) {
    return '—';
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
