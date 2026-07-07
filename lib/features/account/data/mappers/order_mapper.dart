import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

abstract final class OrderMapper {
  static OrderModel? fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      final items = data['items'];
      var itemCount = 0;
      if (items is List) {
        itemCount = items.length;
      } else if (data['itemCount'] is int) {
        itemCount = data['itemCount'] as int;
      }

      final createdAt = data['createdAt'];
      DateTime? createdDate;
      if (createdAt is Timestamp) {
        createdDate = createdAt.toDate();
      } else if (createdAt is DateTime) {
        createdDate = createdAt;
      }

      return OrderModel(
        id: id,
        orderNumber: data['orderNumber'] as String? ?? id,
        status: data['status'] as String? ?? 'unknown',
        paymentStatus: data['paymentStatus'] as String? ?? '',
        total: _parseDouble(data['total']),
        itemCount: itemCount,
        createdAt: createdDate,
      );
    } catch (_) {
      return null;
    }
  }

  static double _parseDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }
}
