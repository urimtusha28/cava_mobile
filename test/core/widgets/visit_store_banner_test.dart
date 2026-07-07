import 'package:cava_ecommerce/core/widgets/visit_store_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows store location image preview', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VisitStoreBanner(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Cava Premium'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_rounded), findsNothing);
  });

  testWidgets('shows Ferizaj store address', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VisitStoreBanner(),
        ),
      ),
    );

    expect(find.text(VisitStoreBanner.storeAddress), findsOneWidget);
    expect(find.text('Rruga e Dibrës 12, Tiranë'), findsNothing);
  });

  testWidgets('tap opens maps confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VisitStoreBanner(),
        ),
      ),
    );

    await tester.tap(find.byType(VisitStoreBanner));
    await tester.pumpAndSettle();

    expect(find.text('Open Maps?'), findsOneWidget);
    expect(find.text('Dëshiron ta hapësh lokacionin në Maps?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Open Maps'), findsOneWidget);
  });

  testWidgets('cancel dismisses maps dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VisitStoreBanner(),
        ),
      ),
    );

    await tester.tap(find.byType(VisitStoreBanner));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Open Maps?'), findsNothing);
  });

  test('mapsUrl points to Google Maps search for store', () {
    final uri = Uri.parse(VisitStoreBanner.mapsUrl);
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/search/');
    expect(uri.queryParameters['api'], '1');
    expect(
      uri.queryParameters['query'],
      'The Village Shopping Fun 1 Ahmet Kaciku Ferizaj 70000',
    );
  });
}
