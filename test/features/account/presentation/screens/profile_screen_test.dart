import 'package:cava_ecommerce/features/account/presentation/screens/profile_screen.dart';
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

  testWidgets('opens auth bottom sheet when tapping Kyçu', (tester) async {
    await pumpTestApp(tester, home: const ProfileScreen());
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('sq'));
    await tester.tap(find.text(l10n.tapToLogin));
    await tester.pumpAndSettle();

    expect(find.text(l10n.register), findsWidgets);
    expect(find.text(l10n.authWelcome), findsOneWidget);
  });
}
