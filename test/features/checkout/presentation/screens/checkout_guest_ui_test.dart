import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/datasources/addresses_mock_datasource.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:cava_ecommerce/features/checkout/data/datasources/checkout_mock_datasource.dart';
import 'package:cava_ecommerce/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_di.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CartStateNotifier.reset();
    MockAuth.logout();
    await configureTestDependencies(
      productDataSource: const ProductMockDataSource(),
      categoryDataSource: const CategoryMockDataSource(),
      checkoutDataSource: CheckoutMockDataSource(),
      addressesDataSource: AddressesMockDataSource(),
      wishlistFirestore: FakeFirebaseFirestore(),
      cartFirestore: FakeFirebaseFirestore(),
    );
    await sl<AddToCartUseCase>()(
      AddToCartParams(product: MockProducts.products.first, quantity: 1),
    );
  });

  tearDown(() async {
    MockAuth.logout();
    await tearDownTestDependencies();
  });

  testWidgets('guest checkout shows three action buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nuk je i kyçur.'), findsOneWidget);
    expect(find.text('Bli pa u regjistruar'), findsOneWidget);
    expect(find.text('Hyr'), findsOneWidget);
    expect(find.text('Regjistrohu'), findsOneWidget);
    expect(find.text('Shto adresë'), findsNothing);
  });

  testWidgets('Bli pa u regjistruar opens guest info sheet', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bli pa u regjistruar'));
    await tester.pumpAndSettle();

    expect(find.text('Të dhënat e dorëzimit'), findsOneWidget);
    expect(find.widgetWithText(TextField, ''), findsWidgets);
    expect(find.text('Emri'), findsWidgets);
    expect(find.text('Mbiemri'), findsWidgets);
    expect(find.byType(FilledButton), findsWidgets);
  });

  testWidgets('Hyr opens auth bottom sheet in login mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hyr'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Kyçu'), findsWidgets);
  });

  testWidgets('Regjistrohu opens auth bottom sheet in register mode',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Regjistrohu'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Regjistro'), findsWidgets);
  });
}
