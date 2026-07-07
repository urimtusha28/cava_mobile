import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/account/data/datasources/orders_firebase_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late OrdersFirebaseDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = OrdersFirebaseDataSource(firestore);
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
}
