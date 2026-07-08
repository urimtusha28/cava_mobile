import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stored_cart_item_model.dart';

abstract final class CartFirestoreMapper {
  static StoredCartItemModel? fromDocument(
    String documentId,
    Map<String, dynamic> data,
  ) {
    try {
      final productId = (data['productId'] as String?)?.trim();
      final resolvedId =
          productId != null && productId.isNotEmpty ? productId : documentId;
      final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
      if (quantity <= 0) {
        return null;
      }

      return StoredCartItemModel(
        productId: resolvedId,
        quantity: quantity,
        selectedVariant: data['selectedVariant'] as String?,
        addedAt: _readAddedAt(data['addedAt']),
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> toFirestore(StoredCartItemModel entry) {
    return {
      'productId': entry.productId,
      'quantity': entry.quantity,
      if (entry.selectedVariant != null)
        'selectedVariant': entry.selectedVariant,
      'addedAt': Timestamp.fromDate(DateTime.parse(entry.addedAt).toUtc()),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String _readAddedAt(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc().toIso8601String();
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return DateTime.now().toUtc().toIso8601String();
  }
}
