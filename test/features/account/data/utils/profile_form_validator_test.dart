import 'package:cava_ecommerce/features/account/data/utils/profile_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first name required', () {
    expect(ProfileFormValidator.validateFirstName(''), isNotNull);
    expect(ProfileFormValidator.validateFirstName('Urim'), isNull);
  });

  test('phone optional but validated when set', () {
    expect(ProfileFormValidator.validatePhone(''), isNull);
    expect(ProfileFormValidator.validatePhone('+38344111222'), isNull);
    expect(ProfileFormValidator.validatePhone('123'), isNotNull);
    expect(ProfileFormValidator.validatePhone('abcdefgh'), isNotNull);
  });
}
