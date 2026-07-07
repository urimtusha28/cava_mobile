import '../../../account/domain/entities/address_entity.dart';
import '../../../account/domain/entities/auth_user_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

abstract final class PlaceOrderPayloadMapper {
  static Map<String, dynamic> toPayload({
    required AuthUserEntity user,
    required AddressEntity address,
    required List<CartItemEntity> items,
    required String paymentMethod,
    required bool termsAccepted,
  }) {
    final nameParts = _splitName(address.fullName);

    return {
      'customerType': 'user',
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
      'items': items
          .map(
            (item) => {
              'productId': item.product.id,
              'quantity': item.quantity,
            },
          )
          .toList(growable: false),
      'paymentMethod': paymentMethod,
      'termsAccepted': termsAccepted,
      'source': 'mobile',
    };
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
