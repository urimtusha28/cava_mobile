class PlaceOrderResultEntity {
  const PlaceOrderResultEntity({
    required this.orderId,
    this.orderNumber,
    required this.total,
    required this.paymentMethod,
  });

  final String orderId;
  final String? orderNumber;
  final double total;
  final String paymentMethod;

  String get displayOrderNumber {
    final number = orderNumber?.trim();
    if (number != null && number.isNotEmpty) {
      return number.startsWith('#') ? number : '#$number';
    }
    final suffix = orderId.length <= 6
        ? orderId
        : orderId.substring(orderId.length - 6);
    return '#$suffix';
  }

  factory PlaceOrderResultEntity.fromMap(Map<String, dynamic> map) {
    return PlaceOrderResultEntity(
      orderId: _readString(map, ['orderId', 'id']) ?? '',
      orderNumber: _readString(map, ['orderNumber', 'number']),
      total: _readDouble(map, ['total', 'grandTotal', 'amount']) ?? 0,
      paymentMethod: _readString(map, ['paymentMethod', 'payment']) ?? 'cash',
    );
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is num) {
        return value.toDouble();
      }
      final parsed = double.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }
}
