import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/notification_type.dart';
import '../mappers/notification_mapper.dart';
import '../models/app_notification_model.dart';

class NotificationsFirebaseDataSource {
  NotificationsFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(uid)
        .collection(FirebaseConfig.notificationsSubcollection);
  }

  /// Ordered by createdAt desc. Badge unread count is derived client-side
  /// from this limited window to avoid dual-field index issues (`isRead` vs
  /// legacy `read`).
  Stream<List<AppNotificationModel>> watchUserNotifications({
    required String userId,
    int limit = 20,
  }) {
    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationMapper.fromFirestore(
          id: doc.id,
          userId: userId,
          data: doc.data(),
        );
      }).toList();
    });
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _collection(userId).doc(notificationId).update({
      'isRead': true,
      'read': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllAsRead({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _collection(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final batch = _firestore.batch();
    var writes = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final isRead = data['isRead'] == true || data['read'] == true;
      if (isRead) continue;
      batch.update(doc.reference, {
        'isRead': true,
        'read': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      writes++;
    }
    if (writes > 0) {
      await batch.commit();
    }
  }

  Future<void> createNotificationForUser({
    required String recipientUid,
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    final now = FieldValue.serverTimestamp();
    await _collection(recipientUid).add({
      'title': title,
      'body': body,
      'message': body,
      'type': type.firestoreValue,
      'isRead': false,
      'read': false,
      'createdAt': now,
      'updatedAt': now,
    });
  }
}
