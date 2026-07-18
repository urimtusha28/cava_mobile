import 'dart:async';

import 'package:cava_ecommerce/core/auth/app_role.dart';
import 'package:cava_ecommerce/core/auth/app_session_notifier.dart';
import 'package:cava_ecommerce/core/state/auth_state_notifier.dart';
import 'package:cava_ecommerce/features/account/data/datasources/orders_data_source.dart';
import 'package:cava_ecommerce/features/account/data/mock/mock_auth.dart';
import 'package:cava_ecommerce/features/account/data/models/order_model.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_customer_entity.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_entity.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_fulfillment_status.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_item_entity.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_totals_entity.dart';
import 'package:cava_ecommerce/features/account/presentation/screens/orders_screen.dart';
import 'package:cava_ecommerce/features/account/presentation/widgets/order_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/test_di.dart';

void main() {
  setUp(() async {
    await setUpTestDependencies();
    AppSessionNotifier.instance.reset();
    MockAuth.logout();
  });

  tearDown(() async {
    AppSessionNotifier.instance.reset();
    AuthStateNotifier.update(false);
    MockAuth.logout();
    await tearDownTestDependencies();
  });

  testWidgets('shows login prompt when user is guest', (tester) async {
    await pumpTestApp(tester, home: const OrdersScreen());
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
          imageUrl: 'https://example.com/wine.jpg',
        ),
      ],
      totals: OrderTotalsEntity(total: 8.5, subtotal: 8.5),
    );

    await pumpTestApp(
      tester,
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
    );

    await tester.tap(find.text('Show detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detajet e porosisë'), findsOneWidget);
    expect(find.text('#CP-100'), findsOneWidget);
    expect(find.text('U dorëzua'), findsWidgets);
    expect(find.textContaining('E paguar'), findsOneWidget);
    expect(find.text('8,50 €'), findsWidgets);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('status dropdown is hidden for non-owner users', (tester) async {
    AuthStateNotifier.update(true);
    AppSessionNotifier.instance.update(isLoggedIn: true, role: AppRole.customer);

    const order = OrderEntity(
      id: 'order-customer',
      orderNumber: '100',
      status: 'received',
      fulfillmentStatus: 'received',
      paymentMethod: 'cash',
      paymentStatus: 'unpaid',
      total: 12,
      itemCount: 1,
    );

    await pumpTestApp(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showOrderDetailBottomSheet(context: context, order: order),
            child: const Text('Show detail'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show detail'));
    await tester.pumpAndSettle();

    expect(find.text('Ndrysho statusin'), findsNothing);
  });

  testWidgets('owner confirms change, prevents double submit and updates only correct card', (tester) async {
    final datasource = _FakeOrdersDataSource(
      orders: [
        _buildOrderModel(
          id: 'order-1',
          orderNumber: '101',
          status: 'received',
          fulfillmentStatus: 'received',
          paymentMethod: 'cash',
          paymentStatus: 'unpaid',
          total: 10,
          customerName: 'Arta',
        ),
        _buildOrderModel(
          id: 'order-2',
          orderNumber: '102',
          status: 'confirmed',
          fulfillmentStatus: 'confirmed',
          paymentMethod: 'card',
          paymentStatus: 'paid',
          total: 20,
          customerName: 'Besa',
        ),
      ],
      updateDelay: Completer<void>(),
    );
    await tearDownTestDependencies();
    await setUpTestDependencies(ordersDataSource: datasource);

    MockAuth.login();
    AuthStateNotifier.update(true);
    AppSessionNotifier.instance.update(isLoggedIn: true, role: AppRole.owner);

    await pumpTestApp(tester, home: const OrdersScreen());
    await tester.pumpAndSettle();

    expect(find.text('Porosia u pranua'), findsWidgets);
    expect(find.text('U konfirmua'), findsOneWidget);

    await tester.tap(find.text('#101'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<FulfillmentStatusDetail>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('U dorëzua').last);
    await tester.pumpAndSettle();

    expect(find.text('Ndrysho statusin e #101 nga "Porosia u pranua" në "U dorëzua"?'), findsOneWidget);
    await tester.tap(find.text('Konfirmo'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.tap(find.byType(DropdownButtonFormField<FulfillmentStatusDetail>));
    await tester.pump();
    expect(find.text('Porosia u pranua'), findsWidgets);

    datasource.completeUpdate();
    await tester.pumpAndSettle();

    expect(find.text('Statusi i porosisë u përditësua.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('U dorëzua'), findsOneWidget);
    expect(find.text('U konfirmua'), findsOneWidget);
  });

  testWidgets('owner sees understandable error and old status remains on failure', (tester) async {
    final datasource = _FakeOrdersDataSource(
      orders: [
        _buildOrderModel(
          id: 'order-3',
          orderNumber: '103',
          status: 'received',
          fulfillmentStatus: 'received',
          paymentMethod: 'cash',
          paymentStatus: 'unpaid',
          total: 30,
          customerName: 'Dua',
        ),
      ],
      failureMessage: 'Ndryshimi i statusit dështoi.',
    );
    await tearDownTestDependencies();
    await setUpTestDependencies(ordersDataSource: datasource);

    MockAuth.login();
    AuthStateNotifier.update(true);
    AppSessionNotifier.instance.update(isLoggedIn: true, role: AppRole.owner);

    await pumpTestApp(tester, home: const OrdersScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('#103'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<FulfillmentStatusDetail>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('U dorëzua').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konfirmo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ndryshimi i statusit dështoi.'), findsWidgets);
    expect(find.text('Porosia u pranua'), findsWidgets);
  });
}

OrderModel _buildOrderModel({
  required String id,
  required String orderNumber,
  required String status,
  required String fulfillmentStatus,
  required String paymentMethod,
  required String paymentStatus,
  required double total,
  required String customerName,
}) {
  return OrderModel(
    id: id,
    orderNumber: orderNumber,
    status: status,
    fulfillmentStatus: fulfillmentStatus,
    paymentMethod: paymentMethod,
    paymentStatus: paymentStatus,
    total: total,
    itemCount: 1,
    items: const [
      OrderItemEntity(
        name: 'Wine',
        quantity: 1,
        price: 10,
        lineTotal: 10,
      ),
    ],
    totals: OrderTotalsEntity(total: total, subtotal: total),
    customer: OrderCustomerEntity(name: customerName, email: 'test@cava.com'),
  );
}

class _FakeOrdersDataSource implements OrdersDataSource {
  _FakeOrdersDataSource({
    required List<OrderModel> orders,
    this.updateDelay,
    this.failureMessage,
  }) : _orders = {
          for (final order in orders) order.id: order,
        };

  final Map<String, OrderModel> _orders;
  final Completer<void>? updateDelay;
  final String? failureMessage;

  void completeUpdate() {
    updateDelay?.complete();
  }

  @override
  Future<OrderModel?> getOrderById(String userId, String orderId) async => _orders[orderId];

  @override
  Future<OrderModel?> getOrderByIdForAdmin(String orderId) async => _orders[orderId];

  @override
  Future<List<OrderModel>> getMyOrders(String userId) async =>
      _orders.values.toList(growable: false);

  @override
  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatusDetail newStatus, {
    String? adminUid,
  }) async {
    if (updateDelay != null) {
      await updateDelay!.future;
    }
    if (failureMessage != null) {
      throw StateError(failureMessage!);
    }
    final current = _orders[orderId]!;
    _orders[orderId] = OrderModel(
      id: current.id,
      orderNumber: current.orderNumber,
      status: newStatus.rawValue,
      fulfillmentStatus: newStatus.rawValue,
      paymentMethod: current.paymentMethod,
      paymentStatus: newStatus == FulfillmentStatusDetail.delivered &&
              current.paymentMethod == 'cash' &&
              current.paymentStatus == 'unpaid'
          ? 'paid'
          : current.paymentStatus,
      total: current.total,
      itemCount: current.itemCount,
      createdAt: current.createdAt,
      items: current.items,
      totals: current.totals,
      customer: current.customer,
    );
  }
}
