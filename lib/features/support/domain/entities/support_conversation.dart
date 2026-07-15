import 'sender_role.dart';
import 'support_status.dart';

class SupportConversation {
  const SupportConversation({
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
}
