import 'package:cava_ecommerce/core/widgets/product_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const placeholder = Icon(Icons.image, key: Key('placeholder'));

  testWidgets('shows placeholder when imageUrl is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductImageView(
            imageUrl: null,
            placeholder: placeholder,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('placeholder')), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows placeholder when imageUrl is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductImageView(
            imageUrl: '   ',
            placeholder: placeholder,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('placeholder')), findsOneWidget);
  });

  testWidgets('builds CachedNetworkImage when imageUrl is set', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductImageView(
            imageUrl: 'https://example.com/product.jpg',
            placeholder: placeholder,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('placeholder')), findsOneWidget);
    await tester.pump();
  });

  testWidgets('clips network image when borderRadius is set', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductImageView(
            imageUrl: 'https://example.com/product.jpg',
            placeholder: placeholder,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(ClipRRect), findsOneWidget);
  });

  test('hasUrl returns false for null and blank', () {
    expect(ProductImageView.hasUrl(null), isFalse);
    expect(ProductImageView.hasUrl(''), isFalse);
    expect(ProductImageView.hasUrl('  '), isFalse);
    expect(ProductImageView.hasUrl('https://a.b/img.jpg'), isTrue);
  });
}
