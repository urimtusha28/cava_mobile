import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] for testability.
abstract class FirebaseAuthGateway {
  Stream<User?> authStateChanges();

  User? get currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();

  Future<void> updateDisplayName(User user, String displayName);

  /// Returns custom claim `admin` when present; null if signed out or missing.
  Future<bool?> getAdminClaim({bool forceRefresh = true});
}

class FirebaseAuthGatewayImpl implements FirebaseAuthGateway {
  const FirebaseAuthGatewayImpl(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> updateDisplayName(User user, String displayName) {
    return user.updateDisplayName(displayName);
  }

  @override
  Future<bool?> getAdminClaim({bool forceRefresh = true}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    final token = await user.getIdTokenResult(forceRefresh);
    final claim = token.claims?['admin'];
    if (claim is bool) {
      return claim;
    }
    return null;
  }
}
