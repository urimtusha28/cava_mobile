import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:cava_ecommerce/features/products/presentation/controllers/product_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_di.dart';

void main() {
  setUp(() async {
    await setUpTestDependencies();
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  testWidgets('does not show discount row when discount is zero', (tester) async {
    final controller = sl<ProductDetailController>();
    await controller.load('wine-001');
    await sl<AddToCartUseCase>()(
      AddToCartParams(product: controller.product!, quantity: 1),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CartScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zbritja'), findsNothing);
    expect(find.text('Çmimi'), findsOneWidget);
    expect(find.text('Totali:'), findsOneWidget);
  });
}
