abstract final class Formatters {
  static String currency(double amount) {
    final formatted = amount.toStringAsFixed(2).replaceAll('.', ',');
    return '$formatted €';
  }
}
