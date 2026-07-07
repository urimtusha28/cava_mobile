import 'package:cava_ecommerce/features/account/domain/entities/order_item_entity.dart';
import 'package:cava_ecommerce/features/account/presentation/utils/order_item_image_resolver.dart';
import 'package:cava_ecommerce/features/account/presentation/widgets/order_detail_item_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderItemImageSource extends Mock implements OrderItemImageSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const OrderItemEntity(
        name: 'Verë',
        quantity: 1,
        price: 1,
        lineTotal: 1,
      ),
    );
  });

  testWidgets('renders premium product row with resolved image', (tester) async {
    final resolver = MockOrderItemImageSource();
    when(() => resolver.resolve(any())).thenAnswer(
      (_) async => 'https://example.com/wine.jpg',
    );

    const item = OrderItemEntity(
      name: 'Stone Castle Merlot',
      quantity: 2,
      price: 4.25,
      lineTotal: 8.5,
      productId: 'p1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderDetailItemRow(
            item: item,
            imageResolver: resolver,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stone Castle Merlot'), findsOneWidget);
    expect(find.text('2 x 4,25 €'), findsOneWidget);
    expect(find.text('8,50 €'), findsOneWidget);
    verify(() => resolver.resolve(item)).called(1);
  });
}
