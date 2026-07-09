import 'package:cava_ecommerce/features/checkout/domain/entities/guest_checkout_customer.dart';
import 'package:cava_ecommerce/features/checkout/domain/utils/guest_checkout_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validateCustomer requires complete guest info', () {
    expect(
      GuestCheckoutFormValidator.validateCustomer(null),
      'Plotëso të dhënat për dorëzim.',
    );
    expect(
      GuestCheckoutFormValidator.validateCustomer(
        const GuestCheckoutCustomer(
          firstName: 'Ana',
          lastName: '',
          email: 'ana@cava.test',
          phone: '1',
          address: 'A',
          city: 'B',
          country: 'C',
        ),
      ),
      'Plotëso të dhënat për dorëzim.',
    );
    expect(
      GuestCheckoutFormValidator.validateCustomer(
        const GuestCheckoutCustomer(
          firstName: 'Ana',
          lastName: 'Krasniqi',
          email: 'ana@cava.test',
          phone: '+383',
          address: 'Rruga',
          city: 'Prishtinë',
          country: 'Kosovë',
        ),
      ),
      isNull,
    );
  });

  test('field validators require values', () {
    expect(GuestCheckoutFormValidator.validateEmail('bad'), isNotNull);
    expect(
      GuestCheckoutFormValidator.validateEmail('ana@cava.test'),
      isNull,
    );
  });
}
