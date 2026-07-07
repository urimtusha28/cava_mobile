import 'package:cava_ecommerce/features/account/presentation/screens/profile_screen.dart';
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

  testWidgets('opens auth bottom sheet when tapping Kyçu', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kyçu'));
    await tester.pumpAndSettle();

    expect(find.text('Regjistrohu'), findsWidgets);
    expect(find.text('Mirë se vini'), findsOneWidget);
  });
}
