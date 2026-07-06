import 'package:cava_ecommerce/core/error/app_exception.dart';
import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('toString includes message and code', () {
      const failure = ServerFailure(message: 'Server down', code: '500');
      expect(failure.toString(), contains('Server down'));
      expect(failure.toString(), contains('500'));
    });

    test('subtypes preserve type', () {
      expect(const NetworkFailure(message: 'offline'), isA<Failure>());
      expect(const AuthFailure(message: 'denied'), isA<Failure>());
      expect(const NotFoundFailure(message: 'missing'), isA<Failure>());
    });
  });

  group('mapExceptionToFailure', () {
    test('maps network AppException', () {
      const exception = AppException(message: 'No internet', code: 'network');
      final failure = mapExceptionToFailure(exception);
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'No internet');
    });

    test('maps auth AppException', () {
      const exception = AppException(message: 'Denied', code: 'auth');
      expect(mapExceptionToFailure(exception), isA<AuthFailure>());
    });

    test('maps not-found AppException', () {
      const exception = AppException(message: 'Missing', code: 'not-found');
      expect(mapExceptionToFailure(exception), isA<NotFoundFailure>());
    });

    test('maps unknown AppException code to UnknownFailure', () {
      const exception = AppException(message: 'Weird', code: 'xyz');
      expect(mapExceptionToFailure(exception), isA<UnknownFailure>());
    });

    test('maps generic error to UnknownFailure', () {
      final failure = mapExceptionToFailure(Exception('boom'));
      expect(failure, isA<UnknownFailure>());
    });
  });
}
