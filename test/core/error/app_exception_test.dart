import 'package:cava_ecommerce/core/error/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    test('toString includes message code and cause', () {
      const exception = AppException(
        message: 'Failed',
        code: 'server',
        cause: 'timeout',
      );
      expect(exception.toString(), contains('Failed'));
      expect(exception.toString(), contains('server'));
      expect(exception.toString(), contains('timeout'));
    });
  });
}
