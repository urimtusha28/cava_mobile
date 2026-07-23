import 'package:cava_ecommerce/core/widgets/product_filter_bottom_sheet.dart';
import 'package:cava_ecommerce/features/products/domain/filtering/product_filter_options.dart';
import 'package:cava_ecommerce/features/products/domain/filtering/product_filter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

const _fullOptions = ProductFilterOptions(
  brands: ['A', 'B', 'C', 'D'],
  countries: ['Italy', 'France', 'Spain'],
  categories: ['Wines', 'Spirits'],
  subcategories: ['Red', 'White'],
  volumes: ['0.7L', '0.75L', '1L'],
  minPrice: 0,
  maxPrice: 500,
);

void main() {
  testWidgets(
    'caps the sheet height well below the full screen even with many filter '
    'sections, so it opens compact and scrolls internally',
    (tester) async {
      await pumpTestApp(
        tester,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showProductFilterSheet(
                    context: context,
                    initial: ProductFilterState.empty,
                    options: _fullOptions,
                  ),
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      // The visible sheet is the rounded, decorated Container nested inside
      // ProductFilterBottomSheet — its own outer render box (Padding/Align)
      // fills the whole route, so it isn't a useful height signal by itself.
      final sheetBox = tester.renderObject<RenderBox>(
        find
            .descendant(
              of: find.byType(ProductFilterBottomSheet),
              matching: find.byWidgetPredicate(
                (w) => w is Container && w.decoration is BoxDecoration,
              ),
            )
            .first,
      );

      expect(sheetBox.size.height, lessThanOrEqualTo(screenHeight * 0.7 + 1));
      expect(sheetBox.size.height, greaterThan(screenHeight * 0.5));
    },
  );

  testWidgets(
    'dismisses a focused search field before opening, so the sheet is not '
    'pushed up by a lingering keyboard inset',
    (tester) async {
      final searchController = TextEditingController();
      final searchFocusNode = FocusNode();
      addTearDown(searchFocusNode.dispose);

      await pumpTestApp(
        tester,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                  ),
                  ElevatedButton(
                    onPressed: () => showProductFilterSheet(
                      context: context,
                      initial: ProductFilterState.empty,
                      options: ProductFilterOptions.empty,
                    ),
                    child: const Text('open'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(searchFocusNode.hasFocus, isTrue);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(searchFocusNode.hasFocus, isFalse);
    },
  );
}
