import '../../domain/entities/sender_role.dart';
import '../../domain/entities/support_conversation.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/entities/support_status.dart';

class SupportConversationModel {
  const SupportConversationModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.status,
    required this.subject,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageSenderRole,
    required this.unreadByCustomer,
    required this.unreadByAdmin,
    this.assignedAdminId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final SupportStatus status;
  final String subject;
  final String lastMessage;
  final DateTime lastMessageAt;
  final SenderRole lastMessageSenderRole;
  final int unreadByCustomer;
  final int unreadByAdmin;
  final String? assignedAdminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportConversation toEntity() {
    return SupportConversation(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      status: status,
      subject: subject,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      lastMessageSenderRole: lastMessageSenderRole,
      unreadByCustomer: unreadByCustomer,
      unreadByAdmin: unreadByAdmin,
      assignedAdminId: assignedAdminId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class SupportMessageModel {
  const SupportMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final SenderRole senderRole;
  final String text;
  final SupportMessageType type;
  final DateTime createdAt;

  SupportMessage toEntity() {
    return SupportMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderRole: senderRole,
      text: text,
      type: type,
      createdAt: createdAt,
    );
  }
}
