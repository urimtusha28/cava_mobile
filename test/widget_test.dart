import 'package:cava_ecommerce/core/locale/locale_controller.dart';
import 'package:cava_ecommerce/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    final localeController = LocaleController();
    await localeController.load();

    await tester.pumpWidget(CavaPremiumApp(localeController: localeController));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);

    // Allow splash post-frame auth navigation to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
