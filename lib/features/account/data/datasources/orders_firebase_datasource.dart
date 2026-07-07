import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../mappers/order_mapper.dart';
import '../models/order_model.dart';
import 'orders_data_source.dart';

class OrdersFirebaseDataSource implements OrdersDataSource {
  OrdersFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<OrderModel>> getMyOrders(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConfig.ordersCollection)
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
}
