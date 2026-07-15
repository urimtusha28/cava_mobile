import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/router/app_routes.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/cart/data/local/cart_local_storage.dart';
import 'package:cava_ecommerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/presentation/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_di.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/models/product_model.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CartLocalStorage().clear();
    CartStateNotifier.reset();
    await setUpTestDependencies();
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  Future<void> pumpDetail(WidgetTester tester, {required String productId}) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => ProductDetailScreen(productId: productId),
        ),
        GoRoute(
          path: AppRoutes.cart,
          builder: (_, _) => const CartScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cart icon shows success snackbar and updates badge', (tester) async {
    await pumpDetail(tester, productId: 'wine-001');

    expect(CartStateNotifier.revision.value, 0);

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Produkti u shtua në shportë.'), findsOneWidget);
    expect(CartStateNotifier.revision.value, 1);

    final stored = await CartLocalStorage().readItems();
    expect(stored.single.quantity, 1);
  });

  testWidgets('Bli tani adds selected quantity and navigates to cart', (tester) async {
    await pumpDetail(tester, productId: 'wine-001');

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bli tani'));
    await tester.pumpAndSettle();

    expect(CartStateNotifier.revision.value, 3);

    final stored = await CartLocalStorage().readItems();
    expect(stored.single.quantity, 3);
    expect(find.byType(CartScreen), findsOneWidget);
  });

  testWidgets('out of stock product disables buy actions and shows badge', (tester) async {
    await tearDownTestDependencies();
    await configureTestDependencies(
      productDataSource: const _OutOfStockProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      cartFirestore: FakeFirebaseFirestore(),
      wishlistFirestore: FakeFirebaseFirestore(),
    );

    await pumpDetail(tester, productId: 'wine-oos');

    expect(find.text('Out of Stock'), findsOneWidget);

    await tester.tap(find.text('Bli tani'));
    await tester.pumpAndSettle();

    expect(find.text('Produkti nuk është në stok.'), findsNothing);
    expect(CartStateNotifier.revision.value, 0);
    expect(await CartLocalStorage().readItems(), isEmpty);
  });
}

class _OutOfStockProductMockDataSource extends ProductMockDataSource {
  const _OutOfStockProductMockDataSource();

  @override
  Future<ProductModel?> getProductById(String id) async {
    if (id == 'wine-oos') {
      return ProductModel.fromEntity(
        const ProductEntity(
          id: 'wine-oos',
          name: 'Out Of Stock Wine',
          brand: 'Test',
          categoryId: 'wines',
          categoryName: 'Wines',
          price: 10,
          description: 'Unavailable',
          volume: '750ml',
          type: 'Red',
          rating: 0,
          reviewCount: 0,
          stock: 0,
          isFeatured: false,
        ),
      );
    }
    return super.getProductById(id);
  }
}
