import 'package:cava_ecommerce/features/checkout/data/datasources/checkout_mock_datasource.dart';
import 'package:cava_ecommerce/features/checkout/domain/entities/place_order_result_entity.dart';
import 'package:cava_ecommerce/features/checkout/presentation/screens/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_di.dart';

void main() {
  setUp(() async {
    await setUpTestDependencies(
      checkoutDataSource: CheckoutMockDataSource(),
    );
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  testWidgets('displays real order data from initial result', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrderSuccessScreen(
          initialResult: PlaceOrderResultEntity(
            orderId: 'order-1',
            orderNumber: 'CP-1001',
            total: 57,
            paymentMethod: 'cash',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#CP-1001'), findsOneWidget);
    expect(find.text('57,00 €'), findsOneWidget);
    expect(find.text('Para në dorë'), findsOneWidget);
  });
}
