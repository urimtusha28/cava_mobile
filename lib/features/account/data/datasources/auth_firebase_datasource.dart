import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../firebase/firebase_auth_gateway.dart';
import '../utils/auth_exception_mapper.dart';
import 'auth_data_source.dart';

class AuthFirebaseDataSource implements AuthDataSource {
  AuthFirebaseDataSource(this._authGateway, this._firestore);

  final FirebaseAuthGateway _authGateway;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthUserEntity?> authStateChanges() {
    return _authGateway.authStateChanges().map(_mapUser);
  }

  @override
  AuthUserEntity? get currentUser => _mapUser(_authGateway.currentUser);

  @override
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authGateway.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure(
          message: 'Diçka shkoi keq. Provo përsëri.',
          code: 'user-null',
        );
      }
      return _mapUser(user)!;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(
        message: AuthExceptionMapper.map(error),
        code: error.code,
      );
    }
  }

  @override
  Future<AuthUserEntity> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await _authGateway.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure(
          message: 'Diçka shkoi keq. Provo përsëri.',
          code: 'user-null',
        );
      }

      final trimmedName = name?.trim();
      if (trimmedName != null && trimmedName.isNotEmpty) {
        await _authGateway.updateDisplayName(user, trimmedName);
      }

      await _writeUserDoc(user, name: trimmedName);
      return _mapUser(user)!;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(
        message: AuthExceptionMapper.map(error),
        code: error.code,
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _authGateway.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(
        message: AuthExceptionMapper.map(error),
        code: error.code,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authGateway.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(
        message: AuthExceptionMapper.map(error),
        code: error.code,
      );
    }
  }

  Future<void> _writeUserDoc(User user, {String? name}) async {
    final ref = _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(user.uid);
    final existing = await ref.get();
    final data = <String, dynamic>{
      'email': user.email,
      'name': name ?? user.displayName ?? '',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      data['role'] = 'client';
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await ref.set(data, SetOptions(merge: true));
  }

  AuthUserEntity? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
