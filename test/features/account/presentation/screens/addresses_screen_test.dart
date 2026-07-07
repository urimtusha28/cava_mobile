import 'package:cava_ecommerce/features/account/presentation/screens/addresses_screen.dart';
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
        home: AddressesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kyçu për të menaxhuar adresat e tua.'), findsOneWidget);
  });
}
