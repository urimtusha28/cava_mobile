import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/utils/user_profile_name_splitter.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.role = 'client',
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromFirestore({
    required String uid,
    required Map<String, dynamic> data,
    String? authEmailFallback,
  }) {
    final rawFirst = (data['firstName'] as String?)?.trim();
    final rawLast = (data['lastName'] as String?)?.trim();
    final rawName = (data['name'] as String?)?.trim() ?? '';

    late final String firstName;
    late final String lastName;

    if ((rawFirst != null && rawFirst.isNotEmpty) ||
        (rawLast != null && rawLast.isNotEmpty)) {
      firstName = rawFirst ?? '';
      lastName = rawLast ?? '';
    } else {
      final split = UserProfileNameSplitter.split(rawName);
      firstName = split.$1;
      lastName = split.$2;
    }

    final email = (data['email'] as String?)?.trim();
    final resolvedEmail = (email != null && email.isNotEmpty)
        ? email
        : (authEmailFallback?.trim() ?? '');

    final phone = (data['phone'] as String?)?.trim();
    final name = rawName.isNotEmpty
        ? rawName
        : UserProfileNameSplitter.combine(firstName, lastName);

    return UserProfileModel(
      uid: uid,
      name: name,
      firstName: firstName,
      lastName: lastName,
      email: resolvedEmail,
      phone: phone == null || phone.isEmpty ? null : phone,
      role: (data['role'] as String?)?.trim().isNotEmpty == true
          ? (data['role'] as String).trim()
          : 'client',
      status: (data['status'] as String?)?.trim().isNotEmpty == true
          ? (data['status'] as String).trim()
          : 'active',
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      uid: uid,
      name: name,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      role: role,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Fields allowed for client profile updates — never role/status.
  static Map<String, dynamic> updatePayload({
    required String firstName,
    required String lastName,
    String? phone,
  }) {
    final trimmedFirst = firstName.trim();
    final trimmedLast = lastName.trim();
    final trimmedPhone = phone?.trim();

    return {
      'firstName': trimmedFirst,
      'lastName': trimmedLast,
      'name': UserProfileNameSplitter.combine(trimmedFirst, trimmedLast),
      'phone': trimmedPhone == null || trimmedPhone.isEmpty ? null : trimmedPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
