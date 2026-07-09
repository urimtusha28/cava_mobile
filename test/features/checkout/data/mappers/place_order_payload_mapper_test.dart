import 'package:cava_ecommerce/features/account/domain/entities/address_entity.dart';
import 'package:cava_ecommerce/features/account/domain/entities/auth_user_entity.dart';
import 'package:cava_ecommerce/features/checkout/data/mappers/place_order_payload_mapper.dart';
import 'package:cava_ecommerce/features/checkout/domain/entities/guest_checkout_customer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  const user = AuthUserEntity(
    uid: 'user-1',
    email: 'test@cava.test',
    displayName: 'Urim Tusha',
  );

  const address = AddressEntity(
    id: 'addr-1',
    label: 'Home',
    fullName: 'Urim Tusha',
    phone: '+38344111222',
    street: 'Rruga e Dielave 12',
    city: 'Prishtinë',
    country: 'Kosovë',
    zip: '10000',
    isDefault: true,
  );

  test('maps payload without total field', () {
    final payload = PlaceOrderPayloadMapper.toPayload(
      user: user,
      address: address,
      items: [testCartItem],
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(payload['customerType'], 'user');
    expect(payload['userId'], 'user-1');
    expect(payload['source'], 'mobile');
    expect(payload['paymentMethod'], 'cash');
    expect(payload['termsAccepted'], isTrue);
    expect(payload.containsKey('total'), isFalse);
    expect(payload.containsKey('discount'), isFalse);
    expect(payload.containsKey('coupon'), isFalse);

    final customer = payload['customer'] as Map<String, dynamic>;
    expect(customer['firstName'], 'Urim');
    expect(customer['lastName'], 'Tusha');
    expect(customer['fullName'], 'Urim Tusha');
    expect(customer['email'], 'test@cava.test');
    expect(customer['phone'], '+38344111222');
    expect(customer['address'], 'Rruga e Dielave 12');
    expect(customer['city'], 'Prishtinë');
    expect(customer['country'], 'Kosovë');
    expect(customer['zip'], '10000');

    final items = payload['items'] as List<dynamic>;
    expect(items, hasLength(1));
    expect(items.first['productId'], 'p1');
    expect(items.first['price'], 25.0);
    expect(items.first['quantity'], 2);
  });

  test('maps guest payload with customerType guest and null userId', () {
    final payload = PlaceOrderPayloadMapper.toGuestPayload(
      guest: const GuestCheckoutCustomer(
        firstName: 'Ana',
        lastName: 'Krasniqi',
        email: 'ana@cava.test',
        phone: '+38344111222',
        address: 'Rruga A 1',
        city: 'Prishtinë',
        country: 'Kosovë',
        zip: '10000',
      ),
      items: [testCartItem],
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(payload['customerType'], 'guest');
    expect(payload['userId'], isNull);
    expect(payload['customer']['fullName'], 'Ana Krasniqi');
    expect(payload['customer']['email'], 'ana@cava.test');
  });
}
