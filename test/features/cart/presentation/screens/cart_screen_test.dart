import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/widgets/product_image_view.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:cava_ecommerce/features/products/presentation/controllers/product_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';
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

    await pumpTestApp(tester, home: const CartScreen());
    await tester.pumpAndSettle();

    expect(find.text('Zbritja'), findsNothing);
    expect(find.text('Çmimi'), findsOneWidget);
    expect(find.text('Totali:'), findsOneWidget);
  });

  testWidgets('shows ProductImageView for cart items', (tester) async {
    final product = MockProducts.products.first;
    await sl<AddToCartUseCase>()(
      AddToCartParams(product: product, quantity: 1),
    );

    await pumpTestApp(tester, home: const CartScreen());
    await tester.pumpAndSettle();

    expect(find.byType(ProductImageView), findsOneWidget);
    final imageView = tester.widget<ProductImageView>(
      find.byType(ProductImageView),
    );
    expect(imageView.imageUrl, product.imageUrl);
    expect(imageView.width, 56);
    expect(imageView.height, 72);
  });
}
