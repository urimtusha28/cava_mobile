import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/utils/user_profile_name_splitter.dart';
import '../models/user_profile_model.dart';
import 'user_profile_data_source.dart';

class UserProfileFirebaseDataSource implements UserProfileDataSource {
  UserProfileFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.collection(FirebaseConfig.usersCollection).doc(uid);
  }

  @override
  Future<UserProfileModel?> getProfile(String uid, {String? authEmail}) async {
    try {
      final snapshot = await _doc(uid).get();
      if (!snapshot.exists || snapshot.data() == null) {
        if (authEmail == null || authEmail.trim().isEmpty) {
          return null;
        }
        return UserProfileModel.fromFirestore(
          uid: uid,
          data: const {},
          authEmailFallback: authEmail,
        );
      }

      return UserProfileModel.fromFirestore(
        uid: uid,
        data: snapshot.data()!,
        authEmailFallback: authEmail,
      );
    } on FirebaseException catch (error) {
      throw NetworkFailure(
        message: 'Profili nuk u lexua. Provo përsëri.',
        code: error.code,
      );
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
    String? phone,
    String? authEmail,
  }) async {
    try {
      final payload = UserProfileModel.updatePayload(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      await _doc(uid).set(payload, SetOptions(merge: true));
      final updated = await getProfile(uid, authEmail: authEmail);
      if (updated == null) {
        throw const UnknownFailure(
          message: 'Profili nuk u përditësua. Provo përsëri.',
        );
      }
      return updated;
    } on FirebaseException catch (error) {
      throw NetworkFailure(
        message: 'Profili nuk u përditësua. Provo përsëri.',
        code: error.code,
      );
    }
  }

  @override
  Future<void> ensureUserDocExists({
    required String uid,
    required String email,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final ref = _doc(uid);
      final existing = await ref.get();

      String resolvedFirst = firstName?.trim() ?? '';
      String resolvedLast = lastName?.trim() ?? '';
      if (resolvedFirst.isEmpty && resolvedLast.isEmpty) {
        final split = UserProfileNameSplitter.split(name);
        resolvedFirst = split.$1;
        resolvedLast = split.$2;
      }

      final resolvedName = (name?.trim().isNotEmpty == true)
          ? name!.trim()
          : UserProfileNameSplitter.combine(resolvedFirst, resolvedLast);

      final data = <String, dynamic>{
        'email': email.trim(),
        'name': resolvedName,
        'firstName': resolvedFirst,
        'lastName': resolvedLast,
        'phone': phone,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!existing.exists) {
        data['role'] = 'client';
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await ref.set(data, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw NetworkFailure(
        message: 'Profili nuk u krijua. Provo përsëri.',
        code: error.code,
      );
    }
  }
}
