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
}
