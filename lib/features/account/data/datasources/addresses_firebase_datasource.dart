import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../mappers/address_mapper.dart';
import '../models/address_model.dart';
import 'addresses_data_source.dart';

class AddressesFirebaseDataSource implements AddressesDataSource {
  AddressesFirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .collection(FirebaseConfig.addressesSubcollection);
  }

  @override
  Future<List<AddressModel>> getAddresses(String userId) async {
    final snapshot = await _collection(userId).get();
    final addresses = <AddressModel>[];
    for (final doc in snapshot.docs) {
      final model = AddressMapper.fromFirestore(doc.id, doc.data());
      if (model != null) {
        addresses.add(model);
      }
    }
    addresses.sort((a, b) {
      if (a.isDefault == b.isDefault) {
        return a.label.compareTo(b.label);
      }
      return a.isDefault ? -1 : 1;
    });
    return addresses;
  }

  @override
  Future<void> addAddress(String userId, AddressModel address) async {
    final collection = _collection(userId);
    final existing = await collection.get();
    final shouldBeDefault = address.isDefault || existing.docs.isEmpty;
    final docRef = address.id.isEmpty ? collection.doc() : collection.doc(address.id);

    await docRef.set(
      AddressModel(
        id: docRef.id,
        label: address.label,
        fullName: address.fullName,
        phone: address.phone,
        street: address.street,
        city: address.city,
        country: address.country,
        zip: address.zip,
        isDefault: shouldBeDefault,
      ).toFirestore(),
    );

    if (shouldBeDefault) {
      await _ensureSingleDefault(userId, docRef.id);
    }
  }

  @override
  Future<void> updateAddress(String userId, AddressModel address) async {
    await _collection(userId).doc(address.id).update(address.toUpdateMap());
    if (address.isDefault) {
      await _ensureSingleDefault(userId, address.id);
    }
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    final collection = _collection(userId);
    final doc = await collection.doc(addressId).get();
    final wasDefault = doc.data()?['isDefault'] as bool? ?? false;

    await collection.doc(addressId).delete();

    if (wasDefault) {
      final remaining = await collection.get();
      if (remaining.docs.isNotEmpty) {
        await _ensureSingleDefault(userId, remaining.docs.first.id);
      }
    }
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _ensureSingleDefault(userId, addressId);
  }

  Future<void> _ensureSingleDefault(String userId, String addressId) async {
    final snapshot = await _collection(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isDefault': doc.id == addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
