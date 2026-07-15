import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/sender_role.dart';
import '../../domain/entities/support_status.dart';
import '../mappers/support_mapper.dart';
import '../models/support_models.dart';
import 'support_firebase_datasource.dart';

class AdminSupportFirebaseDataSource {
  AdminSupportFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection(FirebaseConfig.supportConversationsCollection);

  CollectionReference<Map<String, dynamic>> _messages(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection(FirebaseConfig.supportMessagesSubcollection);
  }

  Stream<List<SupportConversationModel>> watchConversations({
    SupportStatus? statusFilter,
  }) {
    Query<Map<String, dynamic>> query = _conversations;
    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.firestoreValue);
    }
    return query
        .orderBy('lastMessageAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SupportMapper.conversationFromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<SupportMessageModel>> watchMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return _messages(conversationId)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SupportMapper.messageFromFirestore(
          id: doc.id,
          conversationId: conversationId,
          data: doc.data(),
        );
      }).toList();
    });
  }

  Future<void> sendAdminMessage({
    required String conversationId,
    required String adminId,
    required String text,
  }) async {
    final normalized = _normalizeText(text);
    final conversationRef = _conversations.doc(conversationId);
    final conversationSnap = await conversationRef.get();
    if (!conversationSnap.exists) {
      throw const NotFoundFailure(message: 'Biseda nuk u gjet.');
    }
    final conversationData = conversationSnap.data() ?? {};
    final customerId = conversationData['customerId'] as String? ?? '';
    final messageRef = _messages(conversationId).doc();
    final now = FieldValue.serverTimestamp();

    final batch = _firestore.batch();
    batch.set(messageRef, {
      'senderId': adminId,
      'senderRole': SenderRole.admin.firestoreValue,
      'text': normalized,
      'type': 'text',
      'createdAt': now,
    });
    batch.update(conversationRef, {
      'lastMessage': normalized,
      'lastMessageAt': now,
      'lastMessageSenderRole': SenderRole.admin.firestoreValue,
      'unreadByCustomer': FieldValue.increment(1),
      'updatedAt': now,
      'status': SupportStatus.pending.firestoreValue,
    });

    if (customerId.isNotEmpty) {
      final notifRef = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(customerId)
          .collection(FirebaseConfig.notificationsSubcollection)
          .doc();
      batch.set(notifRef, {
        'userId': customerId,
        'type': 'support_reply',
        'title': 'Përgjigje nga Support',
        'body': normalized.length > 120
            ? '${normalized.substring(0, 117)}...'
            : normalized,
        'isRead': false,
        'read': false,
        'createdAt': now,
        'updatedAt': now,
        'actionType': 'open_support',
        'conversationId': conversationId,
        'eventKey': 'support_reply_${messageRef.id}',
      });
    }

    await batch.commit();
  }

  Future<void> updateStatus({
    required String conversationId,
    required SupportStatus status,
  }) async {
    await _conversations.doc(conversationId).update({
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignToSelf({
    required String conversationId,
    required String adminId,
  }) async {
    await _conversations.doc(conversationId).update({
      'assignedAdminId': adminId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markReadByAdmin(String conversationId) async {
    await _conversations.doc(conversationId).update({
      'unreadByAdmin': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Unread badge from recent conversations (client-side sum, no extra index).
  Stream<int> watchUnreadByAdmin() {
    return _conversations
        .orderBy('lastMessageAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      var total = 0;
      for (final doc in snapshot.docs) {
        total += SupportMapper.conversationFromFirestore(doc.id, doc.data())
            .unreadByAdmin;
      }
      return total;
    });
  }

  String _normalizeText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure(message: 'Mesazhi nuk mund të jetë bosh.');
    }
    if (trimmed.length > SupportFirebaseDataSource.maxMessageLength) {
      throw const ValidationFailure(
        message: 'Mesazhi është shumë i gjatë (max 2000).',
      );
    }
    return trimmed;
  }
}
