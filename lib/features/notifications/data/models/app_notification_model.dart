import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.orderId,
    this.orderNumber,
    this.productId,
    this.promotionId,
    this.actionType,
    this.actionValue,
    this.conversationId,
    this.eventKey,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? orderId;
  final String? orderNumber;
  final String? productId;
  final String? promotionId;
  final String? actionType;
  final String? actionValue;
  final String? conversationId;
  final String? eventKey;

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
      orderId: orderId,
      orderNumber: orderNumber,
      productId: productId,
      promotionId: promotionId,
      actionType: actionType,
      actionValue: actionValue,
      conversationId: conversationId,
      eventKey: eventKey,
    );
  }
}
