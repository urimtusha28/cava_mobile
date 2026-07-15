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

  /// Customer-facing order label: prefers sequential [orderNumber] (e.g. #10009).
  /// Legacy fallback uses the full Firestore [orderId], never a truncated suffix.
  String get displayOrderNumber {
    final number = orderNumber?.trim();
    if (number != null && number.isNotEmpty) {
      return number.startsWith('#') ? number : '#$number';
    }
    if (orderId.isEmpty) {
      return '—';
    }
    return orderId.startsWith('#') ? orderId : '#$orderId';
  }

  factory PlaceOrderResultEntity.fromMap(Map<String, dynamic> map) {
    final totalsRaw = map['totals'];
    final totals = totalsRaw is Map
        ? Map<String, dynamic>.from(totalsRaw)
        : const <String, dynamic>{};

    return PlaceOrderResultEntity(
      orderId: _readString(map, ['orderId', 'id']) ?? '',
      orderNumber: _readOrderNumber(map),
      total: _readDouble(map, ['total', 'grandTotal', 'amount']) ??
          _readDouble(totals, ['total', 'grandTotal', 'amount']) ??
          0,
      paymentMethod: _readString(map, ['paymentMethod', 'payment']) ?? 'cash',
    );
  }

  /// Reads sequential orderNumber from callable response (string or int).
  static String? _readOrderNumber(Map<String, dynamic> map) {
    for (final key in ['orderNumber', 'number']) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is num) {
        return value.toInt().toString();
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
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
