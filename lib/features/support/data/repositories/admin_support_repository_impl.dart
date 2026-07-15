import '../../../../core/error/failures.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../domain/entities/support_conversation.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/entities/support_status.dart';
import '../../domain/repositories/admin_support_repository.dart';
import '../datasources/admin_support_firebase_datasource.dart';

class AdminSupportRepositoryImpl implements AdminSupportRepository {
  AdminSupportRepositoryImpl(this._dataSource, this._authRepository);

  final AdminSupportFirebaseDataSource _dataSource;
  final AuthRepository _authRepository;

  Future<String> _requireUid() async {
    final uid = await _authRepository.getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      throw const AuthFailure(
        message: 'Duhet të jeni të kyçur si admin.',
        code: 'NOT_SIGNED_IN',
      );
    }
    return uid;
  }

  @override
  Stream<List<SupportConversation>> watchConversations({
    SupportStatus? statusFilter,
  }) {
    return _dataSource.watchConversations(statusFilter: statusFilter).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
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
  Future<void> sendAdminMessage({
    required String conversationId,
    required String text,
  }) async {
    final uid = await _requireUid();
    await _dataSource.sendAdminMessage(
      conversationId: conversationId,
      adminId: uid,
      text: text,
    );
  }

  @override
  Future<void> updateStatus({
    required String conversationId,
    required SupportStatus status,
  }) {
    return _dataSource.updateStatus(
      conversationId: conversationId,
      status: status,
    );
  }

  @override
  Future<void> assignToSelf(String conversationId) async {
    final uid = await _requireUid();
    await _dataSource.assignToSelf(
      conversationId: conversationId,
      adminId: uid,
    );
  }

  @override
  Future<void> markReadByAdmin(String conversationId) {
    return _dataSource.markReadByAdmin(conversationId);
  }

  @override
  Stream<int> watchUnreadByAdmin() {
    return _dataSource.watchUnreadByAdmin();
  }
}
