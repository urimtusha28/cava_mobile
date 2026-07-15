import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_type.dart';
import '../models/app_notification_model.dart';

abstract final class NotificationMapper {
  /// Accepts both schemas:
  /// - New: `isRead`, `body`, `type`, `orderNumber`, `createdAt` Timestamp
  /// - Legacy web: `read`, `message` (→ body), missing type → general
  static AppNotificationModel fromFirestore({
    required String id,
    required String userId,
    required Map<String, dynamic> data,
  }) {
    final isRead = _resolveIsRead(data);
    final body = _resolveBody(data);
    final createdAt = _parseDate(data['createdAt']) ?? DateTime.now();
    final updatedAt = _parseDate(data['updatedAt']) ?? createdAt;

    return AppNotificationModel(
      id: id,
      userId: userId,
      type: NotificationType.fromString(data['type'] as String?),
      title: (data['title'] as String?)?.trim() ?? '',
      body: body,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
      orderId: _optionalString(data['orderId']),
      orderNumber: _optionalString(data['orderNumber']),
      productId: _optionalString(data['productId']),
      promotionId: _optionalString(data['promotionId']),
      actionType: _optionalString(data['actionType']),
      actionValue: _optionalString(data['actionValue']),
      conversationId: _optionalString(data['conversationId']),
      eventKey: _optionalString(data['eventKey']),
    );
  }

  static bool _resolveIsRead(Map<String, dynamic> data) {
    if (data.containsKey('isRead')) {
      return data['isRead'] == true;
    }
    if (data.containsKey('read')) {
      return data['read'] == true;
    }
    return false;
  }

  static String _resolveBody(Map<String, dynamic> data) {
    final body = data['body'];
    if (body is String && body.trim().isNotEmpty) {
      return body.trim();
    }
    final message = data['message'];
    if (message is String) {
      return message.trim();
    }
    return '';
  }

  static DateTime? _parseDate(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String? _optionalString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }
}
