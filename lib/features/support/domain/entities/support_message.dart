import 'sender_role.dart';

enum SupportMessageType { text, system }

class SupportMessage {
  const SupportMessage({
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

  static SupportMessageType typeFromString(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'system' => SupportMessageType.system,
      _ => SupportMessageType.text,
    };
  }
}
