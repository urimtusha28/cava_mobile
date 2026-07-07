import 'package:cava_ecommerce/core/state/auth_state_notifier.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_entity.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_item_entity.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_totals_entity.dart';
import 'package:cava_ecommerce/features/account/presentation/screens/orders_screen.dart';
import 'package:cava_ecommerce/features/account/presentation/widgets/order_detail_bottom_sheet.dart';
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

  testWidgets('shows login prompt when user is guest', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrdersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kyçu për të parë porositë e tua.'), findsOneWidget);
  });

  testWidgets('opens order detail bottom sheet on card tap', (tester) async {
    AuthStateNotifier.update(true);

    const order = OrderEntity(
      id: 'order-abc123',
      orderNumber: '#CP-100',
      status: 'delivered',
      paymentStatus: 'paid',
      total: 8.5,
      itemCount: 1,
      items: [
        OrderItemEntity(
          name: 'Stone Castle Merlot',
          quantity: 1,
          price: 8.5,
          lineTotal: 8.5,
        ),
      ],
      totals: OrderTotalsEntity(total: 8.5, subtotal: 8.5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showOrderDetailBottomSheet(context: context, order: order);
                  },
                  child: const Text('Show detail'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detajet e porosisë'), findsOneWidget);
    expect(find.text('#CP-100'), findsOneWidget);
    expect(find.text('Përfunduar'), findsOneWidget);
    expect(find.text('E paguar'), findsOneWidget);
    expect(find.text('8,50 €'), findsWidgets);
    expect(find.text('Mbyll'), findsOneWidget);
  });
}
