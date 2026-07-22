import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:cava_ecommerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:cava_ecommerce/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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

  testWidgets('shows empty state when wishlist has no items', (tester) async {
    await pumpTestApp(tester, home: const WishlistScreen());
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('sq'));
    expect(find.text(l10n.wishlistEmpty), findsOneWidget);
    expect(find.text('Stone Castle Merlot'), findsNothing);
  });

  testWidgets(
    'refreshes when the wishlist changes elsewhere while the screen stays '
    'mounted (e.g. behind a pushed product grid route)',
    (tester) async {
      await pumpTestApp(tester, home: const WishlistScreen());
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('sq'));
      expect(find.text(l10n.wishlistEmpty), findsOneWidget);

      // Simulate a toggle happening on another screen (product grid) that is
      // pushed above this one — the WishlistScreen State stays alive and
      // must pick up the change instead of showing the stale empty list.
      final product = MockProducts.products.first;
      await sl<WishlistRepository>().add(product);
      await tester.pumpAndSettle();

      expect(find.text(l10n.wishlistEmpty), findsNothing);
      expect(find.text(product.name), findsOneWidget);
    },
  );
}
