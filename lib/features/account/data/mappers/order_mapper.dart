import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/order_customer_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/order_totals_entity.dart';
import '../models/order_model.dart';

abstract final class OrderMapper {
  static OrderModel? fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      final items = _parseItems(data['items']);
      final itemCount = items.isNotEmpty
          ? items.length
          : (data['itemCount'] is int ? data['itemCount'] as int : 0);
      final total = resolveTotal(data, items);
      final totals = _parseTotals(data, total, items);
      final customer = _parseCustomer(data);

      final createdAt = data['createdAt'];
      DateTime? createdDate;
      if (createdAt is Timestamp) {
        createdDate = createdAt.toDate();
      } else if (createdAt is DateTime) {
        createdDate = createdAt;
      }

      final rawOrderNumber = data['orderNumber'];
      final orderNumber = rawOrderNumber is String && rawOrderNumber.trim().isNotEmpty
          ? rawOrderNumber.trim()
          : null;

      return OrderModel(
        id: id,
        orderNumber: orderNumber,
        status: data['status'] as String? ?? 'unknown',
        paymentStatus: data['paymentStatus'] as String? ?? '',
        total: total,
        itemCount: itemCount,
        createdAt: createdDate,
        items: items,
        totals: totals,
        customer: customer,
      );
    } catch (_) {
      return null;
    }
  }

  static double resolveTotal(
    Map<String, dynamic> data,
    List<OrderItemEntity> items,
  ) {
    final totalsMap = data['totals'];
    if (totalsMap is Map) {
      final nested = _parseDoubleOptional(_readMapValue(totalsMap, 'total'));
      if (nested != null && nested > 0) {
        return nested;
      }
    }

    for (final key in ['total', 'amount', 'grandTotal']) {
      final value = _parseDoubleOptional(data[key]);
      if (value != null && value > 0) {
        return value;
      }
    }

    if (items.isNotEmpty) {
      final sum = items.fold<double>(0, (acc, item) => acc + item.lineTotal);
      if (sum > 0) {
        return sum;
      }
    }

    return 0;
  }

  static List<OrderItemEntity> _parseItems(Object? rawItems) {
    if (rawItems is! List) {
      return const [];
    }

    final parsed = <OrderItemEntity>[];
    for (final entry in rawItems) {
      final item = _parseItem(entry);
      if (item != null) {
        parsed.add(item);
      }
    }
    return parsed;
  }

  static OrderItemEntity? _parseItem(Object? raw) {
    if (raw is! Map) {
      return null;
    }

    final item = Map<String, dynamic>.from(raw);
    final name = _readString(item, ['name', 'productName', 'title']) ?? 'Produkt';
    final quantity = _parseInt(item['quantity']) ?? 1;
    final price = _parseDouble(
      item['price'] ?? item['unitPrice'] ?? item['unit_price'],
    );
    final lineTotal = _parseDoubleOptional(
      item['total'] ?? item['lineTotal'] ?? item['line_total'],
    );
    final imageUrl = _readString(item, [
      'imageUrl',
      'imageURL',
      'image',
      'thumbnail',
      'photoUrl',
    ]);
    final productId = _readString(item, ['productId', 'product_id']);

    return OrderItemEntity(
      name: name,
      quantity: quantity,
      price: price,
      lineTotal: lineTotal ?? price * quantity,
      imageUrl: imageUrl,
      productId: productId,
    );
  }

  static OrderTotalsEntity _parseTotals(
    Map<String, dynamic> data,
    double resolvedTotal,
    List<OrderItemEntity> items,
  ) {
    final totalsMap = data['totals'];
    if (totalsMap is Map) {
      final map = Map<String, dynamic>.from(totalsMap);
      return OrderTotalsEntity(
        subtotal: _parseDoubleOptional(
          map['subtotal'] ?? map['subTotal'],
        ),
        discount: _parseDoubleOptional(
          map['discount'] ?? map['discountTotal'],
        ),
        shipping: _parseDoubleOptional(
          map['shipping'] ?? map['delivery'] ?? map['deliveryFee'],
        ),
        vat: _parseDoubleOptional(map['vat'] ?? map['tax'] ?? map['tva']),
        total: resolvedTotal,
      );
    }

    final itemsSubtotal = items.fold<double>(0, (acc, item) => acc + item.lineTotal);
    return OrderTotalsEntity(
      subtotal: itemsSubtotal > 0 ? itemsSubtotal : null,
      total: resolvedTotal,
    );
  }

  static OrderCustomerEntity? _parseCustomer(Map<String, dynamic> data) {
    final customer = data['customer'];
    if (customer is Map) {
      final map = Map<String, dynamic>.from(customer);
      final entity = OrderCustomerEntity(
        name: _readString(map, ['name', 'fullName', 'full_name']),
        phone: _readString(map, ['phone', 'phoneNumber', 'mobile']),
        address: _readString(map, ['address', 'fullAddress', 'street']),
      );
      if (entity.hasInfo) {
        return entity;
      }
    }

    final shipping = data['shippingAddress'] ?? data['deliveryAddress'];
    if (shipping is Map) {
      final map = Map<String, dynamic>.from(shipping);
      final street = _readString(map, ['street', 'addressLine1', 'line1']);
      final city = _readString(map, ['city']);
      final zip = _readString(map, ['zip', 'postalCode']);
      final addressParts = [
        street,
        city,
        zip,
      ].whereType<String>().where((part) => part.trim().isNotEmpty);

      final entity = OrderCustomerEntity(
        name: _readString(map, ['fullName', 'name', 'recipientName']),
        phone: _readString(map, ['phone', 'phoneNumber']),
        address: addressParts.isEmpty ? null : addressParts.join(', '),
      );
      if (entity.hasInfo) {
        return entity;
      }
    }

    return null;
  }

  static Object? _readMapValue(Map map, String key) {
    if (map is Map<String, dynamic>) {
      return map[key];
    }
    return map[key];
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static int? _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double _parseDouble(Object? value) {
    return _parseDoubleOptional(value) ?? 0;
  }

  static double? _parseDoubleOptional(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }
}
