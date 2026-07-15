import '../../../../core/error/failures.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../domain/entities/store_contact.dart';
import '../../domain/entities/support_conversation.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_firebase_datasource.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl(this._dataSource, this._authRepository);

  final SupportFirebaseDataSource _dataSource;
  final AuthRepository _authRepository;

  Future<String> _requireUid() async {
    final uid = await _authRepository.getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      throw const AuthFailure(
        message: 'Kyçu për të kontaktuar support-in.',
        code: 'NOT_SIGNED_IN',
      );
    }
    return uid;
  }

  @override
  Stream<SupportConversation?> watchActiveConversation() async* {
    final uid = await _authRepository.getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      yield null;
      return;
    }
    yield* _dataSource
        .watchActiveConversation(uid)
        .map((model) => model?.toEntity());
  }

  @override
  Stream<List<SupportMessage>> watchMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return _dataSource
        .watchMessages(conversationId, limit: limit)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<SupportConversation> getOrCreateActiveConversation({
    required String text,
  }) async {
    final uid = await _requireUid();
    final user = await _authRepository.getCurrentUser();
    final existing = await _dataSource.findActiveConversation(uid);
    if (existing != null) {
      await _dataSource.sendCustomerMessage(
        conversationId: existing.id,
        customerId: uid,
        text: text,
      );
      final refreshed = await _dataSource.findActiveConversation(uid);
      return (refreshed ?? existing).toEntity();
    }

    final created = await _dataSource.createConversation(
      customerId: uid,
      customerName: user?.displayLabel ?? '',
      customerEmail: user?.email ?? '',
      text: text,
    );
    return created.toEntity();
  }

  @override
  Future<void> sendCustomerMessage({
    required String conversationId,
    required String text,
  }) async {
    final uid = await _requireUid();
    await _dataSource.sendCustomerMessage(
      conversationId: conversationId,
      customerId: uid,
      text: text,
    );
  }

  @override
  Future<void> markConversationReadByCustomer(String conversationId) async {
    await _requireUid();
    await _dataSource.markConversationReadByCustomer(conversationId);
  }

  @override
  Stream<int> watchUnreadByCustomer() async* {
    final uid = await _authRepository.getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      yield 0;
      return;
    }
    yield* _dataSource.watchUnreadByCustomer(uid);
  }

  @override
  Future<StoreContact> getStoreContact() {
    return _dataSource.getStoreContact();
  }
}
