import '../entities/support_conversation.dart';
import '../entities/support_message.dart';
import '../entities/store_contact.dart';

abstract class SupportRepository {
  Stream<SupportConversation?> watchActiveConversation();

  Stream<List<SupportMessage>> watchMessages(
    String conversationId, {
    int limit = 50,
  });

  Future<SupportConversation> getOrCreateActiveConversation({
    required String text,
  });

  Future<void> sendCustomerMessage({
    required String conversationId,
    required String text,
  });

  Future<void> markConversationReadByCustomer(String conversationId);

  Stream<int> watchUnreadByCustomer();

  Future<StoreContact> getStoreContact();
}
