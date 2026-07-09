import '../../../account/domain/entities/address_entity.dart';
import '../../../account/domain/entities/auth_user_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/guest_checkout_customer.dart';

abstract final class PlaceOrderPayloadMapper {
  static Map<String, dynamic> toUserPayload({
    required AuthUserEntity user,
    required AddressEntity address,
    required List<CartItemEntity> items,
    required String paymentMethod,
    required bool termsAccepted,
  }) {
    final nameParts = _splitName(address.fullName);

    return {
      'customerType': 'user',
      // Required by placeOrder CF: context.auth.uid must equal data.userId.
      'userId': user.uid,
      'customer': {
        'firstName': nameParts.$1,
        'lastName': nameParts.$2,
        'fullName': address.fullName.trim(),
        'email': user.email?.trim() ?? '',
        'phone': address.phone.trim(),
        'address': address.street.trim(),
        'city': address.city.trim(),
        'country': address.country.trim(),
        'zip': address.zip?.trim() ?? '',
      },
      'items': _mapItems(items),
      'paymentMethod': paymentMethod,
      'termsAccepted': termsAccepted,
      'source': 'mobile',
    };
  }

  static Map<String, dynamic> toGuestPayload({
    required GuestCheckoutCustomer guest,
    required List<CartItemEntity> items,
    required String paymentMethod,
    required bool termsAccepted,
  }) {
    return {
      'customerType': 'guest',
      'userId': null,
      'customer': {
        'firstName': guest.firstName.trim(),
        'lastName': guest.lastName.trim(),
        'fullName': guest.fullName,
        'email': guest.email.trim(),
        'phone': guest.phone.trim(),
        'address': guest.address.trim(),
        'city': guest.city.trim(),
        'country': guest.country.trim(),
        'zip': guest.zip.trim(),
      },
      'items': _mapItems(items),
      'paymentMethod': paymentMethod,
      'termsAccepted': termsAccepted,
      'source': 'mobile',
    };
  }

  /// Backward-compatible alias used by existing user-checkout call sites/tests.
  static Map<String, dynamic> toPayload({
    required AuthUserEntity user,
    required AddressEntity address,
    required List<CartItemEntity> items,
    required String paymentMethod,
    required bool termsAccepted,
  }) {
    return toUserPayload(
      user: user,
      address: address,
      items: items,
      paymentMethod: paymentMethod,
      termsAccepted: termsAccepted,
    );
  }

  static List<Map<String, dynamic>> _mapItems(List<CartItemEntity> items) {
    return items
        .map(
          (item) => {
            'productId': item.product.id,
            // CF validates client price against Firestore (PRICE_EPS 0.01).
            'price': item.product.price,
            'quantity': item.quantity,
          },
        )
        .toList(growable: false);
  }

  static (String, String) _splitName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return ('', '');
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (parts.first, parts.sublist(1).join(' '));
  }
}
