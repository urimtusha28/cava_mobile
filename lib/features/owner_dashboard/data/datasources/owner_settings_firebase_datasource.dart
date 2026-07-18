import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/owner_settings_entities.dart';
import 'owner_settings_data_source.dart';

class OwnerSettingsFirebaseDataSource implements OwnerSettingsDataSource {
  OwnerSettingsFirebaseDataSource(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirebaseConfig.usersCollection);

  DocumentReference<Map<String, dynamic>> get _homepage =>
      _firestore
          .collection(FirebaseConfig.settingsCollection)
          .doc(FirebaseConfig.homepageSettingsDoc);

  DocumentReference<Map<String, dynamic>> get _legal =>
      _firestore
          .collection(FirebaseConfig.settingsCollection)
          .doc(FirebaseConfig.legalSettingsDoc);

  @override
  Future<List<OwnerListedUser>> listUsers({int limit = 100}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snap;
      try {
        snap = await _users
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } on FirebaseException {
        // Fallback if createdAt index/field is missing on some docs.
        snap = await _users.limit(limit).get();
      }

      final users = snap.docs.map(_userFromDoc).toList();
      users.sort((a, b) {
        final aAt = a.createdAt;
        final bAt = b.createdAt;
        if (aAt == null && bAt == null) return 0;
        if (aAt == null) return 1;
        if (bAt == null) return -1;
        return bAt.compareTo(aAt);
      });
      return List<OwnerListedUser>.unmodifiable(users);
    } on FirebaseException catch (error) {
      throw _mapFirebase(error, 'Përdoruesit nuk u ngarkuan.');
    }
  }

  @override
  Future<HomepageSettings> getHomepageSettings() async {
    try {
      final doc = await _homepage.get();
      if (!doc.exists) return HomepageSettings.empty;
      return _homepageFromData(doc.data());
    } on FirebaseException catch (error) {
      throw _mapFirebase(error, 'Cilësimet e dyqanit nuk u ngarkuan.');
    }
  }

  @override
  Future<HomepageSettings> updateStoreBanner({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  }) async {
    try {
      final ext = fileExtension.replaceAll('.', '').toLowerCase();
      final safeExt = (ext == 'png' || ext == 'webp' || ext == 'jpeg')
          ? (ext == 'jpeg' ? 'jpg' : ext)
          : 'jpg';
      final path =
          '${FirebaseConfig.bannerImagesPath}/${FirebaseConfig.storeVisitBannerFile}.$safeExt';
      final ref = _storage.ref(path);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      final url = await ref.getDownloadURL();
      await _homepage.set(
        {
          'storeBannerImageUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return getHomepageSettings();
    } on FirebaseException catch (error) {
      throw _mapFirebase(error, 'Foto e bannerit nuk u ngarkua.');
    }
  }

  @override
  Future<HomepageSettings> updateStoreContact({
    String? email,
    String? phone,
    String? storeAddress,
    String? mapsUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (storeAddress != null) {
        payload['storeAddress'] = storeAddress.trim();
      }
      if (mapsUrl != null) {
        payload['mapsUrl'] = mapsUrl.trim();
      }
      if (email != null || phone != null) {
        final contact = <String, dynamic>{};
        if (email != null) contact['email'] = email.trim();
        if (phone != null) contact['phone'] = phone.trim();
        payload['contact'] = contact;
      }
      await _homepage.set(payload, SetOptions(merge: true));
      return getHomepageSettings();
    } on FirebaseException catch (error) {
      throw _mapFirebase(error, 'Kontakti i dyqanit nuk u ruajt.');
    }
  }

  @override
  Future<LegalSettings> getLegalSettings() async {
    try {
      final doc = await _legal.get();
      if (!doc.exists) return LegalSettings.empty;
      return _legalFromData(doc.data());
    } on FirebaseException catch (error) {
      throw _mapFirebase(error, 'Dokumentet legale nuk u ngarkuan.');
    }
  }

  @override
  Future<LegalSettings> uploadLegalPdf({
    required LegalDocumentType type,
    required Uint8List bytes,
  }) async {
    try {
      final fileName = type == LegalDocumentType.terms
          ? FirebaseConfig.legalTermsFile
          : FirebaseConfig.legalPrivacyFile;
      final path = '${FirebaseConfig.legalDocumentsPath}/$fileName';
      final ref = _storage.ref(path);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final url = await ref.getDownloadURL();
      final field = type == LegalDocumentType.terms
          ? 'termsPdfUrl'
          : 'privacyPdfUrl';
      await _legal.set(
        {
          field: url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return getLegalSettings();
    } on FirebaseException catch (error) {
      throw _mapFirebase(error, 'PDF nuk u ngarkua.');
    }
  }

  OwnerListedUser _userFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final email = (data['email'] as String?)?.trim() ?? '';
    final name = (data['name'] as String?)?.trim() ??
        (data['displayName'] as String?)?.trim() ??
        '';
    final role = (data['role'] as String?)?.trim() ?? 'client';
    return OwnerListedUser(
      id: doc.id,
      email: email.isEmpty ? '—' : email,
      displayName: name.isEmpty ? email : name,
      role: role,
      createdAt: _readDate(data['createdAt']),
    );
  }

  HomepageSettings _homepageFromData(Map<String, dynamic>? data) {
    if (data == null) return HomepageSettings.empty;
    final contact = data['contact'];
    String? email;
    String? phone;
    if (contact is Map) {
      email = (contact['email'] as String?)?.trim();
      phone = (contact['phone'] as String?)?.trim();
    }
    return HomepageSettings(
      storeBannerImageUrl:
          (data['storeBannerImageUrl'] as String?)?.trim().isEmpty == true
              ? null
              : (data['storeBannerImageUrl'] as String?)?.trim(),
      storeAddress: (data['storeAddress'] as String?)?.trim(),
      mapsUrl: (data['mapsUrl'] as String?)?.trim(),
      contactEmail: email?.isEmpty == true ? null : email,
      contactPhone: phone?.isEmpty == true ? null : phone,
    );
  }

  LegalSettings _legalFromData(Map<String, dynamic>? data) {
    if (data == null) return LegalSettings.empty;
    return LegalSettings(
      termsPdfUrl: (data['termsPdfUrl'] as String?)?.trim(),
      privacyPdfUrl: (data['privacyPdfUrl'] as String?)?.trim(),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Never _mapFirebase(FirebaseException error, String fallback) {
    if (error.code == 'permission-denied') {
      throw const AuthFailure(
        message: 'Nuk ke të drejta për këtë veprim.',
        code: 'PERMISSION_DENIED',
      );
    }
    throw ServerFailure(
      message: error.message?.isNotEmpty == true ? error.message! : fallback,
      code: error.code,
    );
  }
}
