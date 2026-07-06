import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/get_cart_summary.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cava_ecommerce/features/cart/presentation/controllers/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetCartSummaryUseCase extends Mock implements GetCartSummaryUseCase {}

class MockUpdateCartQuantityUseCase extends Mock
    implements UpdateCartQuantityUseCase {}

class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}

void main() {
  late MockGetCartSummaryUseCase getCartSummary;
  late MockUpdateCartQuantityUseCase updateCartQuantity;
  late MockRemoveFromCartUseCase removeFromCart;
  late CartController controller;

  setUp(() {
    getCartSummary = MockGetCartSummaryUseCase();
    updateCartQuantity = MockUpdateCartQuantityUseCase();
    removeFromCart = MockRemoveFromCartUseCase();
    controller = CartController(
      getCartSummary,
      updateCartQuantity,
      removeFromCart,
    );
  });

  test('load populates summary', () async {
    final summary = CartSummaryEntity(
      items: [testCartItem],
      itemCount: 2,
      subtotal: 50,
      discount: 0,
      vat: 10,
      shipping: 2,
      total: 62,
    );
    when(() => getCartSummary()).thenAnswer((_) async => Success(summary));

    await controller.load();

    expect(controller.total, 62);
    expect(controller.items, hasLength(1));
  });

  test('removeAt refreshes summary', () async {
    when(() => removeFromCart(0)).thenAnswer((_) async => const Success(null));
    when(() => getCartSummary())
        .thenAnswer((_) async => Success(testCartSummary));

    await controller.removeAt(0);

    verify(() => removeFromCart(0)).called(1);
    verify(() => getCartSummary()).called(1);
  });
}
