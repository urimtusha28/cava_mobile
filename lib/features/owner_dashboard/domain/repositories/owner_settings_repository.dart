import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../entities/owner_settings_entities.dart';

abstract class OwnerSettingsRepository {
  Future<Result<List<OwnerListedUser>>> listUsers({int limit = 100});

  Future<Result<HomepageSettings>> getHomepageSettings();

  Future<Result<HomepageSettings>> updateStoreBanner({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  });

  Future<Result<HomepageSettings>> updateStoreContact({
    String? email,
    String? phone,
    String? storeAddress,
    String? mapsUrl,
  });

  Future<Result<LegalSettings>> getLegalSettings();

  Future<Result<LegalSettings>> uploadLegalPdf({
    required LegalDocumentType type,
    required Uint8List bytes,
  });
}
