import 'dart:typed_data';

import '../../domain/entities/owner_settings_entities.dart';

abstract class OwnerSettingsDataSource {
  Future<List<OwnerListedUser>> listUsers({int limit = 100});

  Future<HomepageSettings> getHomepageSettings();

  Future<HomepageSettings> updateStoreBanner({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  });

  Future<HomepageSettings> updateStoreContact({
    String? email,
    String? phone,
    String? storeAddress,
    String? mapsUrl,
  });

  Future<LegalSettings> getLegalSettings();

  Future<LegalSettings> uploadLegalPdf({
    required LegalDocumentType type,
    required Uint8List bytes,
  });
}
