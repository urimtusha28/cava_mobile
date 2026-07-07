import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/account/data/datasources/addresses_firebase_datasource.dart';
import 'package:cava_ecommerce/features/account/data/models/address_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AddressesFirebaseDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = AddressesFirebaseDataSource(firestore);
  });

  AddressModel sample({bool isDefault = false, String label = 'Shtëpi'}) {
    return AddressModel(
      id: '',
      label: label,
      fullName: 'Urim Tusha',
      phone: '044111222',
      street: 'Rruga 1',
      city: 'Ferizaj',
      country: 'Kosovë',
      zip: '70000',
      isDefault: isDefault,
    );
  }

  test('addAddress writes users/{uid}/addresses document', () async {
    await dataSource.addAddress('uid-1', sample());

    final docs = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc('uid-1')
        .collection(FirebaseConfig.addressesSubcollection)
        .get();

    expect(docs.docs, hasLength(1));
    expect(docs.docs.first.data()['fullName'], 'Urim Tusha');
    expect(docs.docs.first.data()['role'], isNull);
  });

  test('first address becomes default automatically', () async {
    await dataSource.addAddress('uid-1', sample(isDefault: false));

    final addresses = await dataSource.getAddresses('uid-1');
    expect(addresses.single.isDefault, isTrue);
  });

  test('setDefaultAddress keeps only one default', () async {
    await dataSource.addAddress('uid-1', sample(label: 'A'));
    await dataSource.addAddress(
      'uid-1',
      sample(label: 'B').copyWith(fullName: 'Second'),
    );

    final created = await dataSource.getAddresses('uid-1');
    final secondId = created.firstWhere((item) => item.label == 'B').id;

    await dataSource.setDefaultAddress('uid-1', secondId);

    final addresses = await dataSource.getAddresses('uid-1');
    expect(addresses.where((item) => item.isDefault), hasLength(1));
    expect(addresses.firstWhere((item) => item.isDefault).id, secondId);
  });

  test('deleteAddress removes document', () async {
    await dataSource.addAddress('uid-1', sample());
    final created = await dataSource.getAddresses('uid-1');

    await dataSource.deleteAddress('uid-1', created.single.id);

    final addresses = await dataSource.getAddresses('uid-1');
    expect(addresses, isEmpty);
  });
}
