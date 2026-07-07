import '../../../../core/error/failures.dart';
import '../../../account/domain/entities/address_entity.dart';
import '../../../account/domain/repositories/addresses_repository.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
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
  );

  final CheckoutDataSource _dataSource;
  final AuthRepository _authRepository;
  final AddressesRepository _addressesRepository;
  final CartRepository _cartRepository;

  @override
  Future<PlaceOrderResultEntity> placeOrder(PlaceOrderRequest request) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw const AuthFailure(
        message: 'Kyçu për të vazhduar.',
        code: 'UNAUTHENTICATED',
      );
    }

    final items = await _loadCartItems();
    final address = await _resolveDefaultAddress();

    final payload = PlaceOrderPayloadMapper.toPayload(
      user: user,
      address: address,
      items: items,
      paymentMethod: request.paymentMethod,
      termsAccepted: request.termsAccepted,
    );

    return _dataSource.placeOrder(payload);
  }

  Future<List<CartItemEntity>> _loadCartItems() async {
    await _cartRepository.hydrateFromStorage();
    return _cartRepository.getItems();
  }

  Future<AddressEntity> _resolveDefaultAddress() async {
    final addresses = await _addressesRepository.getAddresses();
    if (addresses.isEmpty) {
      throw const ValidationFailure(
        message: 'Shto një adresë para porosisë.',
        code: 'ADDRESS_REQUIRED',
      );
    }

    return addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => addresses.first,
    );
  }
}
