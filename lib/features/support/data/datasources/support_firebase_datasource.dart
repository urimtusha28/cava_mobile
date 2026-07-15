import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/sender_role.dart';
import '../../domain/entities/store_contact.dart';
import '../../domain/entities/support_status.dart';
import '../mappers/support_mapper.dart';
import '../models/support_models.dart';

class SupportFirebaseDataSource {
  SupportFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const maxMessageLength = 2000;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection(FirebaseConfig.supportConversationsCollection);

  CollectionReference<Map<String, dynamic>> _messages(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection(FirebaseConfig.supportMessagesSubcollection);
  }

  String normalizeText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure(message: 'Mesazhi nuk mund të jetë bosh.');
    }
    if (trimmed.length > maxMessageLength) {
      throw const ValidationFailure(
        message: 'Mesazhi është shumë i gjatë (max 2000).',
      );
    }
    return trimmed;
  }

  Stream<SupportConversationModel?> watchActiveConversation(String customerId) {
    return _conversations
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: [
          SupportStatus.open.firestoreValue,
          SupportStatus.pending.firestoreValue,
        ])
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return SupportMapper.conversationFromFirestore(doc.id, doc.data());
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

  Future<SupportConversationModel?> findActiveConversation(
    String customerId,
  ) async {
    final snapshot = await _conversations
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: [
          SupportStatus.open.firestoreValue,
          SupportStatus.pending.firestoreValue,
        ])
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return SupportMapper.conversationFromFirestore(doc.id, doc.data());
  }

  Future<SupportConversationModel> createConversation({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String text,
  }) async {
    final normalized = normalizeText(text);
    final docRef = _conversations.doc();
    final messageRef = _messages(docRef.id).doc();
    final now = FieldValue.serverTimestamp();

    final batch = _firestore.batch();
    batch.set(docRef, {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'status': SupportStatus.open.firestoreValue,
      'subject': _subjectFromText(normalized),
      'lastMessage': normalized,
      'lastMessageAt': now,
      'lastMessageSenderRole': SenderRole.customer.firestoreValue,
      'unreadByCustomer': 0,
      'unreadByAdmin': 1,
      'assignedAdminId': null,
      'createdAt': now,
      'updatedAt': now,
    });
    batch.set(messageRef, {
      'senderId': customerId,
      'senderRole': SenderRole.customer.firestoreValue,
      'text': normalized,
      'type': 'text',
      'createdAt': now,
    });
    await batch.commit();

    final created = await docRef.get();
    return SupportMapper.conversationFromFirestore(
      docRef.id,
      created.data() ?? {},
    );
  }

  Future<void> sendCustomerMessage({
    required String conversationId,
    required String customerId,
    required String text,
  }) async {
    final normalized = normalizeText(text);
    final conversationRef = _conversations.doc(conversationId);
    final messageRef = _messages(conversationId).doc();
    final now = FieldValue.serverTimestamp();

    final batch = _firestore.batch();
    batch.set(messageRef, {
      'senderId': customerId,
      'senderRole': SenderRole.customer.firestoreValue,
      'text': normalized,
      'type': 'text',
      'createdAt': now,
    });
    batch.update(conversationRef, {
      'lastMessage': normalized,
      'lastMessageAt': now,
      'lastMessageSenderRole': SenderRole.customer.firestoreValue,
      'unreadByAdmin': FieldValue.increment(1),
      'updatedAt': now,
      'status': SupportStatus.open.firestoreValue,
    });
    await batch.commit();
  }

  Future<void> markConversationReadByCustomer(String conversationId) async {
    await _conversations.doc(conversationId).update({
      'unreadByCustomer': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> watchUnreadByCustomer(String customerId) {
    return _conversations
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: [
          SupportStatus.open.firestoreValue,
          SupportStatus.pending.firestoreValue,
        ])
        .snapshots()
        .map((snapshot) {
      var total = 0;
      for (final doc in snapshot.docs) {
        total += SupportMapper.conversationFromFirestore(doc.id, doc.data())
            .unreadByCustomer;
      }
      return total;
    });
  }

  Future<StoreContact> getStoreContact() async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.settingsCollection)
          .doc(FirebaseConfig.homepageSettingsDoc)
          .get();
      final data = doc.data();
      if (data == null) return StoreContact.fallback;

      final contact = data['contact'];
      if (contact is! Map) return StoreContact.fallback;

      final email = (contact['email'] as String?)?.trim();
      final phone = (contact['phone'] as String?)?.trim();
      return StoreContact(
        email: (email != null && email.isNotEmpty)
            ? email
            : StoreContact.fallback.email,
        phone: (phone != null && phone.isNotEmpty)
            ? phone
            : StoreContact.fallback.phone,
      );
    } catch (_) {
      return StoreContact.fallback;
    }
  }

  String _subjectFromText(String text) {
    if (text.length <= 60) return text;
    return '${text.substring(0, 57)}...';
  }
}
