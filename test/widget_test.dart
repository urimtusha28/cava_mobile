import 'package:flutter_test/flutter_test.dart';

import 'package:cava_ecommerce/main.dart';

void main() {
  testWidgets('App loads Gjirafa-style home', (WidgetTester tester) async {
    await tester.pumpWidget(const CavaPremiumApp());
    await tester.pumpAndSettle();

    expect(find.text('CAVA PREMIUM'), findsOneWidget);
    expect(find.text('Të rekomanduara'), findsOneWidget);
    expect(find.text('Kërko produkte…'), findsOneWidget);
  });
}
