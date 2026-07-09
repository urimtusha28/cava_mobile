import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../account/domain/entities/address_entity.dart';
import '../../../account/domain/repositories/addresses_repository.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/place_order_result_entity.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_data_source.dart';
import '../mappers/place_order_payload_mapper.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl(
    this._dataSource,
    this._authRepository,
    this._addressesRepository,
    this._cartRepository,
    this._productRepository,
  );

  final CheckoutDataSource _dataSource;
  final AuthRepository _authRepository;
  final AddressesRepository _addressesRepository;
  final CartRepository _cartRepository;
  final ProductRepository _productRepository;

  @override
  Future<PlaceOrderResultEntity> placeOrder(PlaceOrderRequest request) async {
    final items = await _loadCartItems();

    final Map<String, dynamic> payload;
    if (request.customerType == PlaceOrderCustomerType.guest) {
      final guest = request.guestCustomer;
      if (guest == null || !guest.isComplete) {
        throw const ValidationFailure(
          message: 'Plotëso të dhënat për dorëzim.',
          code: 'GUEST_INFO_REQUIRED',
        );
      }
  // Guest orders must not carry a signed-in Firebase user (CF rule).
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        throw const ValidationFailure(
          message: 'Plotëso të dhënat për dorëzim.',
          code: 'GUEST_MUST_BE_UNAUTHENTICATED',
        );
      }
      payload = PlaceOrderPayloadMapper.toGuestPayload(
        guest: guest,
        items: items,
        paymentMethod: request.paymentMethod,
        termsAccepted: request.termsAccepted,
      );
    } else {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw const AuthFailure(
          message: 'Kyçu për të vazhduar.',
          code: 'UNAUTHENTICATED',
        );
      }
      final addressId = request.addressId;
      if (addressId == null || addressId.isEmpty) {
        throw const ValidationFailure(
          message: 'Shto ose zgjidh një adresë.',
          code: 'ADDRESS_REQUIRED',
        );
      }
      final address = await _resolveAddress(addressId);
      payload = PlaceOrderPayloadMapper.toUserPayload(
        user: user,
        address: address,
        items: items,
        paymentMethod: request.paymentMethod,
        termsAccepted: request.termsAccepted,
      );
    }

    _logPlaceOrderPayload(
      payload: payload,
      items: items,
      subtotal: await _cartRepository.getSubtotal(),
      vat: await _cartRepository.getVat(),
      transport: await _cartRepository.getShipping(),
      discount: await _cartRepository.getDiscount(),
      total: await _cartRepository.getTotal(),
    );

    return _dataSource.placeOrder(payload);
  }

  Future<List<CartItemEntity>> _loadCartItems() async {
    await _cartRepository.hydrateFromStorage();
    final items = await _cartRepository.getItems();
    return _refreshItemPrices(items);
  }

  /// Re-reads each product from Firestore so checkout sends current unit prices.
  Future<List<CartItemEntity>> _refreshItemPrices(
    List<CartItemEntity> items,
  ) async {
    final refreshed = <CartItemEntity>[];
    for (final item in items) {
      final latest = await _productRepository.getById(item.product.id);
      refreshed.add(
        CartItemEntity(
          product: latest ?? item.product,
          quantity: item.quantity,
        ),
      );
    }
    return refreshed;
  }

  void _logPlaceOrderPayload({
    required Map<String, dynamic> payload,
    required List<CartItemEntity> items,
    required double subtotal,
    required double vat,
    required double transport,
    required double discount,
    required double total,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[Checkout] placeOrder payload=$payload');
    for (final item in items) {
      debugPrint(
        '[Checkout] placeOrder item '
        'productId=${item.product.id} '
        'unitPrice=${item.product.price} '
        'quantity=${item.quantity} '
        'lineSubtotal=${item.lineTotal}',
      );
    }
    debugPrint(
      '[Checkout] placeOrder totals '
      'subtotal=$subtotal '
      'vat=$vat '
      'transport=$transport '
      'discount=$discount '
      'total=$total '
      'paymentMethod=${payload['paymentMethod']}',
    );
  }

  Future<AddressEntity> _resolveAddress(String addressId) async {
    final addresses = await _addressesRepository.getAddresses();
    if (addresses.isEmpty) {
      throw const ValidationFailure(
        message: 'Shto ose zgjidh një adresë.',
        code: 'ADDRESS_REQUIRED',
      );
    }

    for (final address in addresses) {
      if (address.id == addressId) {
        return address;
      }
    }

    throw const ValidationFailure(
      message: 'Shto ose zgjidh një adresë.',
      code: 'ADDRESS_REQUIRED',
    );
  }
}
