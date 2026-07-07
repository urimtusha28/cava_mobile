import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await configureTestDependencies();
  });

  tearDown(() async {
    await resetDependencies();
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
