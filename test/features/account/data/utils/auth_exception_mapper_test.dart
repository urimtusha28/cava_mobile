import 'package:cava_ecommerce/features/account/data/utils/auth_exception_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthExceptionMapper', () {
    test('maps invalid credential', () {
      expect(
        AuthExceptionMapper.map(
          FirebaseAuthException(code: 'invalid-credential'),
        ),
        'Email ose fjalëkalim i pasaktë.',
      );
    });

    test('maps email already in use', () {
      expect(
        AuthExceptionMapper.map(
          FirebaseAuthException(code: 'email-already-in-use'),
        ),
        'Ky email është i regjistruar.',
      );
    });

    test('maps weak password', () {
      expect(
        AuthExceptionMapper.map(
          FirebaseAuthException(code: 'weak-password'),
        ),
        'Fjalëkalimi është shumë i dobët.',
      );
    });

    test('maps invalid email', () {
      expect(
        AuthExceptionMapper.map(
          FirebaseAuthException(code: 'invalid-email'),
        ),
        'Email nuk është valid.',
      );
    });

    test('maps network failure', () {
      expect(
        AuthExceptionMapper.map(
          FirebaseAuthException(code: 'network-request-failed'),
        ),
        'Kontrollo lidhjen me internet.',
      );
    });

    test('maps unknown code to default', () {
      expect(
        AuthExceptionMapper.map(
          FirebaseAuthException(code: 'operation-not-allowed'),
        ),
        'Diçka shkoi keq. Provo përsëri.',
      );
    });
  });
}
