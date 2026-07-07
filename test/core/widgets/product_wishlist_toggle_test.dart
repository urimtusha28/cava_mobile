import 'package:cava_ecommerce/core/state/wishlist_state_notifier.dart';
import 'package:cava_ecommerce/core/widgets/product_grid_card.dart';
import 'package:cava_ecommerce/core/widgets/product_wishlist_toggle.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/local_wishlist_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_di.dart';

void main() {
  setUp(() async {
    await setUpTestDependencies();
    LocalWishlistStore.clear();
    WishlistStateNotifier.reset();
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  testWidgets('product card shows wishlist toggle left of price', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: ProductGridCard.homeRowHeight,
            child: ProductGridCard(product: testProductEntity, compact: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProductWishlistToggle), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });

  testWidgets('tapping wishlist toggle adds product to wishlist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: ProductGridCard.homeRowHeight,
            child: ProductGridCard(product: testProductEntity, compact: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProductWishlistToggle));
    await tester.pumpAndSettle();

    expect(LocalWishlistStore.contains('p1'), isTrue);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });
}
