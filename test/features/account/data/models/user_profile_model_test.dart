import 'package:cava_ecommerce/features/account/data/models/user_profile_model.dart';
import 'package:cava_ecommerce/features/account/domain/utils/user_profile_name_splitter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileNameSplitter', () {
    test('splits first and last', () {
      expect(
        UserProfileNameSplitter.split('Urim Tusha'),
        ('Urim', 'Tusha'),
      );
    });

    test('single token becomes firstName only', () {
      expect(UserProfileNameSplitter.split('Urim'), ('Urim', ''));
    });

    test('empty name yields empty parts', () {
      expect(UserProfileNameSplitter.split(''), ('', ''));
      expect(UserProfileNameSplitter.split(null), ('', ''));
    });
  });

  group('UserProfileModel.fromFirestore', () {
    test('uses firstName/lastName when present', () {
      final model = UserProfileModel.fromFirestore(
        uid: 'u1',
        data: {
          'name': 'Ignored',
          'firstName': 'Ada',
          'lastName': 'Lovelace',
          'email': 'ada@cava.test',
          'phone': '+38344111222',
          'role': 'client',
          'status': 'active',
        },
      );

      expect(model.firstName, 'Ada');
      expect(model.lastName, 'Lovelace');
      expect(model.email, 'ada@cava.test');
      expect(model.phone, '+38344111222');
    });

    test('splits name when first/last missing', () {
      final model = UserProfileModel.fromFirestore(
        uid: 'u1',
        data: {
          'name': 'Urim Tusha',
          'email': 'mock@cava.test',
        },
      );

      expect(model.firstName, 'Urim');
      expect(model.lastName, 'Tusha');
      expect(model.name, 'Urim Tusha');
    });

    test('email fallback from auth', () {
      final model = UserProfileModel.fromFirestore(
        uid: 'u1',
        data: const {},
        authEmailFallback: 'auth@cava.test',
      );

      expect(model.email, 'auth@cava.test');
    });

    test('updatePayload never includes role or status', () {
      final payload = UserProfileModel.updatePayload(
        firstName: 'Urim',
        lastName: 'Tusha',
        phone: '+38344111222',
      );

      expect(payload.containsKey('role'), isFalse);
      expect(payload.containsKey('status'), isFalse);
      expect(payload['name'], 'Urim Tusha');
      expect(payload['firstName'], 'Urim');
      expect(payload['lastName'], 'Tusha');
      expect(payload['phone'], '+38344111222');
      expect(payload['updatedAt'], isA<FieldValue>());
    });
  });
}
