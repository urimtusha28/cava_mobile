import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/account/data/datasources/user_profile_firebase_datasource.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late UserProfileFirebaseDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = UserProfileFirebaseDataSource(firestore);
  });

  test('getProfile maps doc and auth email fallback', () async {
    await firestore.collection(FirebaseConfig.usersCollection).doc('uid-1').set({
      'name': 'Urim Tusha',
      'role': 'client',
      'status': 'active',
    });

    final profile = await dataSource.getProfile(
      'uid-1',
      authEmail: 'auth@cava.test',
    );

    expect(profile, isNotNull);
    expect(profile!.firstName, 'Urim');
    expect(profile.lastName, 'Tusha');
    expect(profile.email, 'auth@cava.test');
    expect(profile.role, 'client');
  });

  test('updateProfile does not change role/status', () async {
    await firestore.collection(FirebaseConfig.usersCollection).doc('uid-1').set({
      'name': 'Old',
      'firstName': 'Old',
      'lastName': '',
      'email': 'user@cava.test',
      'role': 'client',
      'status': 'active',
    });

    final updated = await dataSource.updateProfile(
      uid: 'uid-1',
      firstName: 'Urim',
      lastName: 'Tusha',
      phone: '+38344111222',
      authEmail: 'user@cava.test',
    );

    expect(updated.name, 'Urim Tusha');
    expect(updated.phone, '+38344111222');

    final doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc('uid-1')
        .get();
    expect(doc.data()?['role'], 'client');
    expect(doc.data()?['status'], 'active');
    expect(doc.data()?['firstName'], 'Urim');
    expect(doc.data()?['lastName'], 'Tusha');
    expect(doc.data()?.containsKey('role'), isTrue);
  });

  test('ensureUserDocExists creates client profile fields', () async {
    await dataSource.ensureUserDocExists(
      uid: 'uid-2',
      email: 'new@cava.test',
      name: 'Ada Lovelace',
    );

    final doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc('uid-2')
        .get();

    expect(doc.exists, isTrue);
    expect(doc.data()?['role'], 'client');
    expect(doc.data()?['status'], 'active');
    expect(doc.data()?['firstName'], 'Ada');
    expect(doc.data()?['lastName'], 'Lovelace');
    expect(doc.data()?['phone'], isNull);
  });
}
