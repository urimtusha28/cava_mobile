import 'package:cava_ecommerce/features/account/presentation/screens/orders_screen.dart';
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

  testWidgets('shows login prompt when user is guest', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrdersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kyçu për të parë porositë e tua.'), findsOneWidget);
  });
}
