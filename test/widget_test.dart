import 'package:cava_ecommerce/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CavaPremiumApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);

    // Allow splash post-frame auth navigation to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
