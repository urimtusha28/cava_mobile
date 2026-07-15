import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sender_role.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/entities/support_status.dart';
import '../models/support_models.dart';

abstract final class SupportMapper {
  static SupportConversationModel conversationFromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final createdAt = parseDate(data['createdAt']) ?? DateTime.now();
    final updatedAt = parseDate(data['updatedAt']) ?? createdAt;
    final lastMessageAt = parseDate(data['lastMessageAt']) ?? updatedAt;

    return SupportConversationModel(
      id: id,
      customerId: (data['customerId'] as String?) ?? '',
      customerName: (data['customerName'] as String?) ?? '',
      customerEmail: (data['customerEmail'] as String?) ?? '',
      status: SupportStatus.fromString(data['status'] as String?),
      subject: (data['subject'] as String?) ?? '',
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastMessageAt: lastMessageAt,
      lastMessageSenderRole: SenderRole.fromString(
        data['lastMessageSenderRole'] as String?,
      ),
      unreadByCustomer: _asInt(data['unreadByCustomer']),
      unreadByAdmin: _asInt(data['unreadByAdmin']),
      assignedAdminId: _optionalString(data['assignedAdminId']),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static SupportMessageModel messageFromFirestore({
    required String id,
    required String conversationId,
    required Map<String, dynamic> data,
  }) {
    return SupportMessageModel(
      id: id,
      conversationId: conversationId,
      senderId: (data['senderId'] as String?) ?? '',
      senderRole: SenderRole.fromString(data['senderRole'] as String?),
      text: (data['text'] as String?) ?? '',
      type: SupportMessage.typeFromString(data['type'] as String?),
      createdAt: parseDate(data['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? parseDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static String? _optionalString(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }
}
