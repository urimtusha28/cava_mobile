import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/order_fulfillment_status.dart';
import '../../domain/utils/order_fulfillment_status_machine.dart';
import '../mappers/order_mapper.dart';
import '../models/order_model.dart';
import 'orders_data_source.dart';

class OrdersFirebaseDataSource implements OrdersDataSource {
  OrdersFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirebaseConfig.ordersCollection);

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(FirebaseConfig.productsCollection);

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
  }) {
    final orderRef = _orders.doc(orderId);

    return _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(orderRef);
      if (!snap.exists) {
        throw StateError('Order not found');
      }

      final data = snap.data();
      if (data == null) {
        throw StateError('Order not found');
      }

      final currentStatus =
          (data['fulfillmentStatus'] as String?) ??
          (data['status'] as String?) ??
          '';
      final current = normalizeFulfillmentForTransitions(currentStatus);
      if (current == newStatus) {
        return;
      }

      final timelineRaw = data['statusTimeline'];
      final timeline = timelineRaw is List ? timelineRaw : const [];
      final lastEntry = timeline.isNotEmpty ? timeline.last : null;
      if (lastEntry is Map && lastEntry['status'] == newStatus.rawValue) {
        return;
      }

      assertAllowedFulfillmentTransition(current, newStatus);

      if (newStatus == FulfillmentStatusDetail.canceled &&
          current != FulfillmentStatusDetail.canceled) {
        final itemsRaw = data['items'];
        final items = itemsRaw is List ? itemsRaw : const [];
        final qtyRestoreByProductId = <String, int>{};
        for (final raw in items) {
          if (raw is! Map) {
            continue;
          }
          final item = Map<String, dynamic>.from(raw);
          final productId = (item['productId'] as String?)?.trim() ?? '';
          if (productId.isEmpty) {
            continue;
          }
          final quantity = _parseQuantity(item['quantity'] ?? item['qty']);
          if (quantity <= 0) {
            continue;
          }
          qtyRestoreByProductId[productId] =
              (qtyRestoreByProductId[productId] ?? 0) + quantity;
        }

        for (final entry in qtyRestoreByProductId.entries) {
          final productRef = _products.doc(entry.key);
          final productSnap = await transaction.get(productRef);
          if (!productSnap.exists) {
            continue;
          }
          final productData = productSnap.data();
          final oldStock = _parseQuantity(productData?['stock']);
          transaction.update(productRef, {
            'stock': oldStock + entry.value,
          });
        }
      }

      final paymentPatch = _paymentPatchForFulfillmentOnly(
        newStatus: newStatus,
        paymentMethod: data['paymentMethod'],
        currentPaymentRaw: data['paymentStatus'],
      );

      final newEntry = <String, dynamic>{
        'status': newStatus.rawValue,
        'label': newStatus.albanianLabel,
        'at': Timestamp.now(),
        if (adminUid != null && adminUid.trim().isNotEmpty) 'by': adminUid,
      };

      transaction.update(orderRef, {
        'fulfillmentStatus': newStatus.rawValue,
        'status': newStatus.rawValue,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusTimeline': FieldValue.arrayUnion([newEntry]),
        ...paymentPatch,
      });
    });
  }

  int _parseQuantity(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse('$value') ?? 0;
  }

  Map<String, String> _paymentPatchForFulfillmentOnly({
    required FulfillmentStatusDetail newStatus,
    required Object? paymentMethod,
    required Object? currentPaymentRaw,
  }) {
    if (newStatus != FulfillmentStatusDetail.delivered) {
      return const {};
    }
    if (paymentMethod != 'cash') {
      return const {};
    }
    final payment = '$currentPaymentRaw'.trim().toLowerCase();
    if (payment != 'unpaid') {
      return const {};
    }
    return const {'paymentStatus': 'paid'};
  }
}
