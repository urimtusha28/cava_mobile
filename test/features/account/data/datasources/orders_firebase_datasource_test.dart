import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/core/firebase/firebase_functions_gateway.dart';
import 'package:cava_ecommerce/features/account/data/datasources/orders_firebase_datasource.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_fulfillment_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFunctionsGateway implements FirebaseFunctionsGateway {
  final List<Map<String, dynamic>> calls = [];

  @override
  Future<Map<String, dynamic>> call(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    calls.add({'name': functionName, ...data});
    return {'changed': true};
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late OrdersFirebaseDataSource dataSource;
  late _FakeFunctionsGateway gateway;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    gateway = _FakeFunctionsGateway();
    dataSource = OrdersFirebaseDataSource(
      firestore,
      functionsGateway: gateway,
    );
  });

  test('getMyOrders returns only current user orders sorted desc', () async {
    await firestore.collection(FirebaseConfig.ordersCollection).doc('o1').set({
      'userId': 'uid-1',
      'orderNumber': '#CP-1',
      'status': 'delivered',
      'paymentStatus': 'paid',
      'total': 10,
      'items': [{}],
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    await firestore.collection(FirebaseConfig.ordersCollection).doc('o2').set({
      'userId': 'uid-1',
      'orderNumber': '#CP-2',
      'status': 'pending',
      'paymentStatus': 'pending',
      'total': 20,
      'items': [{}, {}],
      'createdAt': Timestamp.fromDate(DateTime(2026, 2, 1)),
    });
    await firestore.collection(FirebaseConfig.ordersCollection).doc('o3').set({
      'userId': 'uid-2',
      'orderNumber': '#CP-3',
      'status': 'pending',
      'paymentStatus': 'pending',
      'total': 30,
      'items': [{}],
      'createdAt': Timestamp.fromDate(DateTime(2026, 3, 1)),
    });

    final orders = await dataSource.getMyOrders('uid-1');

    expect(orders, hasLength(2));
    expect(orders.first.orderNumber, '#CP-2');
    expect(orders.last.orderNumber, '#CP-1');
  });

  test(
    'updateOrderFulfillmentStatus calls shared callable (no direct stock write)',
    () async {
      await dataSource.updateOrderFulfillmentStatus(
        'order-9',
        FulfillmentStatusDetail.canceled,
        adminUid: 'admin-1',
      );
      expect(gateway.calls, hasLength(1));
      expect(gateway.calls.single['name'], 'updateOrderFulfillmentStatus');
      expect(gateway.calls.single['orderId'], 'order-9');
      expect(gateway.calls.single['newStatus'], 'canceled');
    },
  );
}
