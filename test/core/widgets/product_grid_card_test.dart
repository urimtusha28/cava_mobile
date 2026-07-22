import 'package:cava_ecommerce/core/widgets/product_grid_card.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_di.dart';

const _outOfStockProduct = ProductEntity(
  id: 'p2',
  name: 'Sold Out Wine',
  brand: 'Test Brand',
  categoryId: 'wines',
  categoryName: 'Wines',
  price: 25.0,
  description: 'A test wine',
  volume: '750ml',
  type: 'Red',
  rating: 4.5,
  reviewCount: 100,
  stock: 0,
  isFeatured: false,
);

void main() {
  setUp(() async {
    await setUpTestDependencies();
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  testWidgets('in-stock product renders without blur or out-of-stock label', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      home: Scaffold(body: ProductGridCard(product: testProductEntity)),
    );
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('sq'));
    expect(find.text(l10n.outOfStockBadge), findsNothing);
    expect(find.byType(ImageFiltered), findsNothing);
  });

  testWidgets('out-of-stock product blurs the image and shows the label', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      home: Scaffold(body: ProductGridCard(product: _outOfStockProduct)),
    );
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('sq'));
    expect(find.text(l10n.outOfStockBadge), findsOneWidget);

    final filter = tester.widget<ImageFiltered>(find.byType(ImageFiltered));
    expect(filter.imageFilter, isNotNull);
  });
}
