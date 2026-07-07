import 'package:cava_ecommerce/features/account/data/utils/auth_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFormValidator', () {
    test('rejects empty email', () {
      expect(AuthFormValidator.validateEmail(''), isNotNull);
    });

    test('rejects invalid email', () {
      expect(AuthFormValidator.validateEmail('bad-email'), isNotNull);
    });

    test('accepts valid email', () {
      expect(AuthFormValidator.validateEmail('user@cava.test'), isNull);
    });

    test('rejects short password', () {
      expect(AuthFormValidator.validatePassword('12345'), isNotNull);
    });

    test('accepts password with 6 chars', () {
      expect(AuthFormValidator.validatePassword('123456'), isNull);
    });

    test('requires name for register', () {
      expect(AuthFormValidator.validateName('   '), isNotNull);
    });

    test('rejects mismatched confirm password', () {
      expect(
        AuthFormValidator.validateConfirmPassword('123456', '654321'),
        isNotNull,
      );
    });

    test('accepts matching confirm password', () {
      expect(
        AuthFormValidator.validateConfirmPassword('123456', '123456'),
        isNull,
      );
    });
  });
}
