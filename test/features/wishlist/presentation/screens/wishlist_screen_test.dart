import 'package:cava_ecommerce/features/wishlist/presentation/screens/wishlist_screen.dart';
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

  testWidgets('shows empty state when wishlist has no items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WishlistScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wishlist është bosh.'), findsOneWidget);
    expect(find.text('Stone Castle Merlot'), findsNothing);
  });
}
