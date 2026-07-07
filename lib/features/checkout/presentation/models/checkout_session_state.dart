import '../../../account/domain/entities/address_entity.dart';
import '../../../account/domain/entities/auth_user_entity.dart';
import '../../domain/entities/place_order_result_entity.dart';

enum CheckoutSubmitStatus {
  success,
  validationError,
  requestError,
}

class CheckoutSubmitResult {
  const CheckoutSubmitResult._({
    required this.status,
    this.order,
    this.message,
  });

  final CheckoutSubmitStatus status;
  final PlaceOrderResultEntity? order;
  final String? message;

  factory CheckoutSubmitResult.success(PlaceOrderResultEntity order) {
    return CheckoutSubmitResult._(
      status: CheckoutSubmitStatus.success,
      order: order,
    );
  }

  factory CheckoutSubmitResult.validationError(String message) {
    return CheckoutSubmitResult._(
      status: CheckoutSubmitStatus.validationError,
      message: message,
    );
  }

  factory CheckoutSubmitResult.requestError(String message) {
    return CheckoutSubmitResult._(
      status: CheckoutSubmitStatus.requestError,
      message: message,
    );
  }
}

class CheckoutCustomerInfo {
  const CheckoutCustomerInfo({
    required this.email,
    required this.addressLine,
    required this.city,
    required this.country,
  });

  final String email;
  final String addressLine;
  final String city;
  final String country;

  static const empty = CheckoutCustomerInfo(
    email: '',
    addressLine: '',
    city: '',
    country: '',
  );
}

class CheckoutSessionState {
  const CheckoutSessionState({
    required this.isLoggedIn,
    required this.customer,
    required this.hasAddress,
    required this.hasItems,
    this.user,
    this.defaultAddress,
  });

  final bool isLoggedIn;
  final CheckoutCustomerInfo customer;
  final bool hasAddress;
  final bool hasItems;
  final AuthUserEntity? user;
  final AddressEntity? defaultAddress;
}
