import 'package:cava_ecommerce/features/account/data/utils/address_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requires fullName, phone, street, city, country', () {
    expect(AddressFormValidator.validateFullName(''), isNotNull);
    expect(AddressFormValidator.validatePhone(''), isNotNull);
    expect(AddressFormValidator.validateStreet(''), isNotNull);
    expect(AddressFormValidator.validateCity(''), isNotNull);
    expect(AddressFormValidator.validateCountry(''), isNotNull);
  });

  test('accepts valid values', () {
    expect(AddressFormValidator.validateFullName('Urim'), isNull);
    expect(AddressFormValidator.validatePhone('044'), isNull);
    expect(AddressFormValidator.validateStreet('Rruga 1'), isNull);
    expect(AddressFormValidator.validateCity('Ferizaj'), isNull);
    expect(AddressFormValidator.validateCountry('Kosovë'), isNull);
  });
}
