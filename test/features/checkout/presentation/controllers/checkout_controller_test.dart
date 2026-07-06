import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/get_cart_summary.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cava_ecommerce/features/cart/presentation/controllers/cart_controller.dart';
import 'package:cava_ecommerce/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetCartSummaryUseCase extends Mock implements GetCartSummaryUseCase {}

class MockUpdateCartQuantityUseCase extends Mock
    implements UpdateCartQuantityUseCase {}

class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}

void main() {
  late CartController cartController;
  late CheckoutController checkoutController;
  late MockGetCartSummaryUseCase getCartSummary;

  setUp(() {
    getCartSummary = MockGetCartSummaryUseCase();
    cartController = CartController(
      getCartSummary,
      MockUpdateCartQuantityUseCase(),
      MockRemoveFromCartUseCase(),
    );
    checkoutController = CheckoutController(cartController);
  });

  test('delegates totals to cart controller', () async {
    final summary = CartSummaryEntity(
      items: [testCartItem],
      itemCount: 2,
      subtotal: 50,
      discount: 5,
      vat: 10,
      shipping: 2,
      total: 57,
    );
    when(() => getCartSummary()).thenAnswer((_) async => Success(summary));

    await checkoutController.load();

    expect(checkoutController.total, 57);
    expect(checkoutController.subtotal, 50);
    expect(checkoutController.vat, 10);
    expect(checkoutController.shipping, 2);
    expect(checkoutController.discount, 5);
  });

  test('notifies when cart controller updates', () async {
    when(() => getCartSummary()).thenAnswer((_) async => Success(testCartSummary));

    var notifications = 0;
    checkoutController.addListener(() => notifications++);

    await checkoutController.load();

    expect(notifications, greaterThan(0));
  });
}
