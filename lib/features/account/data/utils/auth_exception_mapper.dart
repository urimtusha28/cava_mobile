import 'package:firebase_auth/firebase_auth.dart';

/// Maps [FirebaseAuthException] codes to Albanian user-facing messages.
abstract final class AuthExceptionMapper {
  static String map(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ose fjalëkalim i pasaktë.';
      case 'email-already-in-use':
        return 'Ky email është i regjistruar.';
      case 'weak-password':
        return 'Fjalëkalimi është shumë i dobët.';
      case 'invalid-email':
        return 'Email nuk është valid.';
      case 'network-request-failed':
        return 'Kontrollo lidhjen me internet.';
      default:
        return 'Diçka shkoi keq. Provo përsëri.';
    }
  }
}
