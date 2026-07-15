import 'package:cava_ecommerce/core/widgets/visit_store_banner.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows store location image preview', (WidgetTester tester) async {
    await pumpTestApp(
      tester,
      home: const Scaffold(body: VisitStoreBanner()),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Cava Premium'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_rounded), findsNothing);
  });

  testWidgets('shows Ferizaj store address', (WidgetTester tester) async {
    await pumpTestApp(
      tester,
      home: const Scaffold(body: VisitStoreBanner()),
    );

    final l10n = lookupAppLocalizations(const Locale('sq'));
    expect(find.text(l10n.visitStoreAddress), findsOneWidget);
    expect(find.text('Rruga e Dibrës 12, Tiranë'), findsNothing);
  });

  testWidgets('tap opens maps confirmation dialog', (WidgetTester tester) async {
    await pumpTestApp(
      tester,
      home: const Scaffold(body: VisitStoreBanner()),
    );

    await tester.tap(find.byType(VisitStoreBanner));
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('sq'));
    expect(find.text(l10n.openMapsTitle), findsOneWidget);
    expect(find.text(l10n.openMapsMessage), findsOneWidget);
    expect(find.text(l10n.openMapsCancel), findsOneWidget);
    expect(find.text(l10n.openMapsConfirm), findsOneWidget);
  });

  testWidgets('cancel dismisses maps dialog', (WidgetTester tester) async {
    await pumpTestApp(
      tester,
      home: const Scaffold(body: VisitStoreBanner()),
    );

    final l10n = lookupAppLocalizations(const Locale('sq'));
    await tester.tap(find.byType(VisitStoreBanner));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.openMapsCancel));
    await tester.pumpAndSettle();

    expect(find.text(l10n.openMapsTitle), findsNothing);
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
