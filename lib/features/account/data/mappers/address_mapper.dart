import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address_model.dart';

abstract final class AddressMapper {
  static AddressModel? fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      return AddressModel(
        id: id,
        label: data['label'] as String? ?? '',
        fullName: data['fullName'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        street: data['street'] as String? ?? '',
        city: data['city'] as String? ?? '',
        country: data['country'] as String? ?? '',
        zip: data['zip'] as String?,
        isDefault: data['isDefault'] as bool? ?? false,
        createdAt: _parseDate(data['createdAt']),
        updatedAt: _parseDate(data['updatedAt']),
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseDate(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
