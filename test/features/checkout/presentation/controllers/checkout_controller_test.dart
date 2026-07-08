import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/datasources/addresses_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/models/address_model.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:cava_ecommerce/features/checkout/data/datasources/checkout_mock_datasource.dart';
import 'package:cava_ecommerce/features/checkout/data/local/checkout_selected_address_storage.dart';
import 'package:cava_ecommerce/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:cava_ecommerce/features/checkout/presentation/models/checkout_session_state.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_di.dart';

const _homeAddress = AddressModel(
  id: 'addr-home',
  label: 'Home',
  fullName: 'Urim Tusha',
  phone: '+38344111222',
  street: 'Rruga e Dielave 12',
  city: 'Prishtinë',
  country: 'Kosovë',
  zip: '10000',
  isDefault: true,
);

const _officeAddress = AddressModel(
  id: 'addr-office',
  label: 'Office',
  fullName: 'Urim Tusha',
  phone: '+38344333444',
  street: 'Rruga B 5',
  city: 'Prizren',
  country: 'Kosovë',
  zip: '20000',
  isDefault: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CheckoutMockDataSource checkoutDataSource;
  late AddressesMockDataSource addressesDataSource;
  late CheckoutController checkoutController;

  Future<void> seedAddresses({bool includeOffice = false}) async {
    await addressesDataSource.addAddress(MockAuth.currentUser.uid, _homeAddress);
    if (includeOffice) {
      await addressesDataSource.addAddress(
        MockAuth.currentUser.uid,
        _officeAddress,
      );
    }
  }

  Future<void> configureCheckout({
    CheckoutMockDataSource? checkoutSource,
    bool includeOffice = false,
  }) async {
    checkoutDataSource = checkoutSource ?? CheckoutMockDataSource();
    addressesDataSource = AddressesMockDataSource();
    await seedAddresses(includeOffice: includeOffice);

    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      checkoutDataSource: checkoutDataSource,
      addressesDataSource: addressesDataSource,
      wishlistFirestore: FakeFirebaseFirestore(),
      cartFirestore: FakeFirebaseFirestore(),
    );

    final addToCart = sl<AddToCartUseCase>();
    await addToCart(
      AddToCartParams(product: MockProducts.products.first, quantity: 2),
    );

    checkoutController = sl<CheckoutController>();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CartStateNotifier.reset();
    MockAuth.login();
    await configureCheckout();
  });

  tearDown(() async {
    MockAuth.logout();
    await tearDownTestDependencies();
  });

  test('load exposes addresses without auto-selecting default', () async {
    await checkoutController.load();

    expect(checkoutController.isLoggedIn, isTrue);
    expect(checkoutController.addresses, hasLength(1));
    expect(checkoutController.selectedAddress, isNull);
    expect(checkoutController.customerInfo.email, MockAuth.userEmail);
    expect(checkoutController.customerInfo.addressLine, isEmpty);
    expect(checkoutController.hasItems, isTrue);
    expect(checkoutController.total, greaterThan(0));
  });

  test('selectAddress updates checkout and persists id', () async {
    await checkoutController.load();
    final address = checkoutController.addresses.first;

    await checkoutController.selectAddress(address);

    expect(checkoutController.selectedAddress?.id, address.id);
    expect(checkoutController.customerInfo.addressLine, contains('Rruga'));
    expect(checkoutController.customerInfo.city, 'Prishtinë');

    final persistedId = await sl<CheckoutSelectedAddressStorage>().readAddressId();
    expect(persistedId, address.id);
  });

  test('restores persisted address on next checkout load', () async {
    await checkoutController.load();
    await checkoutController.selectAddress(checkoutController.addresses.first);

    checkoutController = sl<CheckoutController>();
    await checkoutController.load();

    expect(checkoutController.selectedAddress?.id, 'addr-home');
    expect(checkoutController.customerInfo.addressLine, contains('Rruga'));
  });

  test('falls back when persisted address was deleted', () async {
    await configureCheckout(includeOffice: true);
    await checkoutController.load();
    await checkoutController.selectAddress(
      checkoutController.addresses.firstWhere((address) => address.id == 'addr-office'),
    );

    await addressesDataSource.deleteAddress(
      MockAuth.currentUser.uid,
      'addr-office',
    );
    await checkoutController.refreshAddresses();

    expect(checkoutController.selectedAddress?.id, 'addr-home');
    expect(
      await sl<CheckoutSelectedAddressStorage>().readAddressId(),
      'addr-home',
    );
  });

  test('submitOrder uses selected address in payload', () async {
    await configureCheckout(includeOffice: true);
    await checkoutController.load();
    await checkoutController.selectAddress(
      checkoutController.addresses.firstWhere((address) => address.id == 'addr-office'),
    );

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.status, CheckoutSubmitStatus.success);
    expect(
      checkoutDataSource.lastPayload?['customer']['address'],
      'Rruga B 5',
    );
    expect(checkoutDataSource.lastPayload?.containsKey('total'), isFalse);
  });

  test('submitOrder clears cart only on success', () async {
    await checkoutController.load();
    await checkoutController.selectAddress(checkoutController.addresses.first);

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.status, CheckoutSubmitStatus.success);
    expect(result.order?.orderId, 'order-1');
    expect(CartStateNotifier.revision.value, 0);
  });

  test('submitOrder does not clear cart on failure', () async {
    await tearDownTestDependencies();
    MockAuth.login();

    final failingSource = CheckoutMockDataSource(
      onPlaceOrder: (_) async {
        throw const ServerFailure(message: 'fail', code: 'OUT_OF_STOCK');
      },
    );
    await configureCheckout(checkoutSource: failingSource);
    await checkoutController.load();
    await checkoutController.selectAddress(checkoutController.addresses.first);
    final countBefore = CartStateNotifier.revision.value;

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.status, CheckoutSubmitStatus.requestError);
    expect(result.message, contains('stok'));
    expect(CartStateNotifier.revision.value, countBefore);
  });

  test('blocks order when cart is empty', () async {
    await sl<ClearCartUseCase>()();
    await checkoutController.load();
    await checkoutController.selectAddress(checkoutController.addresses.first);

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.status, CheckoutSubmitStatus.validationError);
    expect(result.message, 'Shporta është bosh.');
  });

  test('blocks guest checkout', () async {
    MockAuth.logout();
    await checkoutController.load();

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.message, 'Kyçu për të vazhduar me porosinë.');
  });

  test('load reads active Firestore cart when logged in', () async {
    await tearDownTestDependencies();
    MockAuth.login();

    final firestore = FakeFirebaseFirestore();
    final product = MockProducts.products.first;
    await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(MockAuth.currentUser.uid)
        .collection(FirebaseConfig.cartSubcollection)
        .doc(product.id)
        .set({
      'productId': product.id,
      'quantity': 2,
      'addedAt': DateTime.utc(2026, 1, 1),
      'updatedAt': DateTime.utc(2026, 1, 1),
    });

    checkoutDataSource = CheckoutMockDataSource();
    addressesDataSource = AddressesMockDataSource();
    await seedAddresses();

    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      checkoutDataSource: checkoutDataSource,
      addressesDataSource: addressesDataSource,
      wishlistFirestore: FakeFirebaseFirestore(),
      cartFirestore: firestore,
    );

    checkoutController = sl<CheckoutController>();
    await checkoutController.load();

    expect(checkoutController.hasItems, isTrue);
    expect(checkoutController.subtotal, product.price * 2);
  });

  test('blocks order when no address exists', () async {
    await tearDownTestDependencies();
    MockAuth.login();
    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      checkoutDataSource: checkoutDataSource,
      wishlistFirestore: FakeFirebaseFirestore(),
      cartFirestore: FakeFirebaseFirestore(),
    );

    final addToCart = sl<AddToCartUseCase>();
    await addToCart(
      AddToCartParams(product: MockProducts.products.first, quantity: 1),
    );
    checkoutController = sl<CheckoutController>();
    await checkoutController.load();

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.message, 'Shto ose zgjidh një adresë.');
  });

  test('blocks order when address exists but none selected', () async {
    await checkoutController.load();

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.status, CheckoutSubmitStatus.validationError);
    expect(result.message, 'Shto ose zgjidh një adresë.');
  });
}
