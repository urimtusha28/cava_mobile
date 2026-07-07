import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/datasources/addresses_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/models/address_model.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:cava_ecommerce/features/checkout/data/datasources/checkout_mock_datasource.dart';
import 'package:cava_ecommerce/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:cava_ecommerce/features/checkout/presentation/models/checkout_session_state.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_di.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CheckoutMockDataSource checkoutDataSource;
  late CheckoutController checkoutController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CartStateNotifier.reset();
    MockAuth.login();

    checkoutDataSource = CheckoutMockDataSource();
    final addressesDataSource = AddressesMockDataSource();
    await addressesDataSource.addAddress(
      MockAuth.currentUser.uid,
      const AddressModel(
        id: '',
        label: 'Home',
        fullName: 'Urim Tusha',
        phone: '+38344111222',
        street: 'Rruga e Dielave 12',
        city: 'Prishtinë',
        country: 'Kosovë',
        zip: '10000',
        isDefault: true,
      ),
    );

    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      checkoutDataSource: checkoutDataSource,
      addressesDataSource: addressesDataSource,
    );

    final addToCart = sl<AddToCartUseCase>();
    await addToCart(
      AddToCartParams(product: MockProducts.products.first, quantity: 2),
    );

    checkoutController = sl<CheckoutController>();
  });

  tearDown(() async {
    MockAuth.logout();
    await tearDownTestDependencies();
  });

  test('load exposes user address and cart totals', () async {
    await checkoutController.load();

    expect(checkoutController.isLoggedIn, isTrue);
    expect(checkoutController.customerInfo.email, MockAuth.userEmail);
    expect(checkoutController.customerInfo.addressLine, contains('Rruga'));
    expect(checkoutController.hasItems, isTrue);
    expect(checkoutController.total, greaterThan(0));
  });

  test('submitOrder clears cart only on success', () async {
    await checkoutController.load();

    final result = await checkoutController.submitOrder(
      paymentMethod: 'cash',
      termsAccepted: true,
    );

    expect(result.status, CheckoutSubmitStatus.success);
    expect(result.order?.orderId, 'order-1');
    expect(CartStateNotifier.revision.value, 0);
    expect(checkoutDataSource.lastPayload?.containsKey('total'), isFalse);
  });

  test('submitOrder does not clear cart on failure', () async {
    await tearDownTestDependencies();
    MockAuth.login();

    final failingSource = CheckoutMockDataSource(
      onPlaceOrder: (_) async {
        throw const ServerFailure(message: 'fail', code: 'OUT_OF_STOCK');
      },
    );
    final addressesDataSource = AddressesMockDataSource();
    await addressesDataSource.addAddress(
      MockAuth.currentUser.uid,
      const AddressModel(
        id: 'addr-1',
        label: 'Home',
        fullName: 'Urim Tusha',
        phone: '+38344111222',
        street: 'Rruga e Dielave 12',
        city: 'Prishtinë',
        country: 'Kosovë',
        isDefault: true,
      ),
    );

    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      checkoutDataSource: failingSource,
      addressesDataSource: addressesDataSource,
    );

    await sl<AddToCartUseCase>()(
      AddToCartParams(product: MockProducts.products.first, quantity: 2),
    );
    checkoutController = sl<CheckoutController>();
    await checkoutController.load();
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

  test('blocks order when no address exists', () async {
    await tearDownTestDependencies();
    MockAuth.login();
    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      checkoutDataSource: checkoutDataSource,
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

    expect(result.message, 'Shto një adresë para porosisë.');
  });
}
