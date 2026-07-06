import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success exposes data', () {
      const result = Success<int>(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('Error exposes failure', () {
      const failure = UnknownFailure(message: 'err', code: 'x');
      const result = Error<int>(failure);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('fold routes to correct callback', () {
      const success = Success<String>('ok');
      expect(
        success.fold(onSuccess: (d) => d, onFailure: (_) => 'fail'),
        'ok',
      );

      const error = Error<String>(
        UnknownFailure(message: 'err', code: 'x'),
      );
      expect(
        error.fold(onSuccess: (_) => 'ok', onFailure: (f) => f.message),
        'err',
      );
    });
  });

  group('guard', () {
    test('returns Success on happy path', () async {
      final result = await guard(() async => 7);
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 7);
    });

    test('returns Error on thrown Failure', () async {
      final result = await guard(() async {
        throw const NetworkFailure(message: 'offline', code: 'network');
      });
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('returns UnknownFailure on generic exception', () async {
      final result = await guard(() async {
        throw Exception('boom');
      });
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });

  group('guardSync', () {
    test('returns Success synchronously', () {
      final result = guardSync(() => 'sync');
      expect(result.dataOrNull, 'sync');
    });
  });
}
