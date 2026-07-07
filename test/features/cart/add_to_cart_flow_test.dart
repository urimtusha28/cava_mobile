import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/cart/data/local/cart_local_storage.dart';
import 'package:cava_ecommerce/features/cart/domain/add_to_cart_result.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/products/presentation/controllers/product_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_di.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CartLocalStorage().clear();
    CartStateNotifier.reset();
    await setUpTestDependencies();
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  test('ProductDetailController addToCart updates badge and persists', () async {
    final controller = sl<ProductDetailController>();
    await controller.load('wine-001');

    expect(controller.product, isNotNull);

    final result = await controller.addToCart(quantity: 2);

    expect(result, AddToCartResult.success);
    expect(CartStateNotifier.revision.value, 2);

    final stored = await CartLocalStorage().readItems();
    expect(stored, hasLength(1));
    expect(stored.first.productId, 'wine-001');
    expect(stored.first.quantity, 2);
  });

  test('AddToCartUseCase merges duplicate lines', () async {
    final addToCart = sl<AddToCartUseCase>();
    final controller = sl<ProductDetailController>();
    await controller.load('wine-001');
    final product = controller.product!;

    await addToCart(AddToCartParams(product: product, quantity: 1));
    await addToCart(AddToCartParams(product: product, quantity: 3));

    expect(CartStateNotifier.revision.value, 4);

    final stored = await CartLocalStorage().readItems();
    expect(stored.single.quantity, 4);
  });
}
