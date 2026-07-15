import '../entities/support_conversation.dart';
import '../entities/support_message.dart';
import '../entities/support_status.dart';

abstract class AdminSupportRepository {
  Stream<List<SupportConversation>> watchConversations({
    SupportStatus? statusFilter,
  });

  Stream<List<SupportMessage>> watchMessages(
    String conversationId, {
    int limit = 50,
  });

  Future<void> sendAdminMessage({
    required String conversationId,
    required String text,
  });

  Future<void> updateStatus({
    required String conversationId,
    required SupportStatus status,
  });

  Future<void> assignToSelf(String conversationId);

  Future<void> markReadByAdmin(String conversationId);

  Stream<int> watchUnreadByAdmin();
}
