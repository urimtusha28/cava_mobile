import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/address_entity.dart';

class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.country,
    this.zip,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String country;
  final String? zip;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      label: label,
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      country: country,
      zip: zip,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toFirestore({bool includeTimestamps = true}) {
    final data = <String, dynamic>{
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'country': country,
      'isDefault': isDefault,
    };
    if (zip != null && zip!.trim().isNotEmpty) {
      data['zip'] = zip!.trim();
    }
    if (includeTimestamps) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
    }
    return data;
  }

  Map<String, dynamic> toUpdateMap() {
    final data = <String, dynamic>{
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'country': country,
      'isDefault': isDefault,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (zip != null && zip!.trim().isNotEmpty) {
      data['zip'] = zip!.trim();
    } else {
      data['zip'] = FieldValue.delete();
    }
    return data;
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? country,
    String? zip,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
      zip: zip ?? this.zip,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
