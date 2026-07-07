import 'package:cava_ecommerce/features/account/data/mappers/address_mapper.dart';
import 'package:cava_ecommerce/features/account/data/mappers/order_mapper.dart';
import 'package:cava_ecommerce/features/account/data/models/address_model.dart';
import 'package:cava_ecommerce/features/account/data/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderModel', () {
    test('toEntity maps fields', () {
      final model = OrderModel(
        id: 'o1',
        orderNumber: '#CP-1',
        status: 'shipped',
        paymentStatus: 'paid',
        total: 18.9,
        itemCount: 2,
        createdAt: DateTime(2026, 1, 1),
      );

      final entity = model.toEntity();
      expect(entity.id, 'o1');
      expect(entity.orderNumber, '#CP-1');
      expect(entity.itemCount, 2);
    });
  });

  group('OrderMapper', () {
    test('maps firestore document', () {
      final model = OrderMapper.fromFirestore('o1', {
        'orderNumber': '#CP-1',
        'status': 'delivered',
        'paymentStatus': 'paid',
        'total': 32,
        'items': [{}, {}],
        'createdAt': Timestamp.fromDate(DateTime(2026, 2, 1)),
        'userId': 'uid-1',
      });

      expect(model?.orderNumber, '#CP-1');
      expect(model?.itemCount, 2);
      expect(model?.total, 32);
    });
  });

  group('AddressModel', () {
    test('toEntity maps fields', () {
      final model = AddressModel(
        id: 'a1',
        label: 'Shtëpi',
        fullName: 'Urim Tusha',
        phone: '+38344111222',
        street: 'Rruga 1',
        city: 'Ferizaj',
        country: 'Kosovë',
        zip: '70000',
        isDefault: true,
      );

      final entity = model.toEntity();
      expect(entity.label, 'Shtëpi');
      expect(entity.isDefault, isTrue);
      expect(entity.displayLine, 'Rruga 1, Ferizaj');
    });
  });

  group('AddressMapper', () {
    test('maps firestore document', () {
      final model = AddressMapper.fromFirestore('a1', {
        'label': 'Punë',
        'fullName': 'Urim',
        'phone': '044',
        'street': 'Bulevardi',
        'city': 'Prishtinë',
        'country': 'Kosovë',
        'zip': '10000',
        'isDefault': false,
      });

      expect(model?.label, 'Punë');
      expect(model?.city, 'Prishtinë');
    });
  });
}
