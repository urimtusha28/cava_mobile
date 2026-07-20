import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../../../../core/firebase/firebase_functions_gateway.dart';
import '../../domain/entities/order_fulfillment_status.dart';
import '../mappers/order_mapper.dart';
import '../models/order_model.dart';
import 'orders_data_source.dart';

class OrdersFirebaseDataSource implements OrdersDataSource {
  OrdersFirebaseDataSource(
    this._firestore, {
    required FirebaseFunctionsGateway functionsGateway,
  }) : _functionsGateway = functionsGateway;

  final FirebaseFirestore _firestore;
  final FirebaseFunctionsGateway _functionsGateway;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirebaseConfig.ordersCollection);

  @override
  Future<List<OrderModel>> getMyOrders(String userId) async {
    final snapshot = await _orders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    final orders = <OrderModel>[];
    for (final doc in snapshot.docs) {
      final model = OrderMapper.fromFirestore(doc.id, doc.data());
      if (model != null) {
        orders.add(model);
      }
    }
    return orders;
  }

  @override
  Future<OrderModel?> getOrderById(String userId, String orderId) async {
    final doc = await _orders.doc(orderId).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    if (data == null || data['userId'] != userId) {
      return null;
    }

    return OrderMapper.fromFirestore(doc.id, data);
  }

  @override
  Future<OrderModel?> getOrderByIdForAdmin(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    if (data == null) {
      return null;
    }

    return OrderMapper.fromFirestore(doc.id, data);
  }

  @override
  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatusDetail newStatus, {
    String? adminUid,
  }) async {
    try {
      await _functionsGateway.call(
        'updateOrderFulfillmentStatus',
        <String, dynamic>{
          'orderId': orderId,
          'newStatus': newStatus.rawValue,
        },
      );
    } on FirebaseFunctionsException catch (error) {
      final message = (error.message ?? '').trim();
      throw StateError(
        message.isNotEmpty
            ? message
            : 'Përditësimi i statusit dështoi (${error.code}).',
      );
    }
  }
}
