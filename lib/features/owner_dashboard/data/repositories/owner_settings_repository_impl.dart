import 'dart:typed_data';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/owner_settings_entities.dart';
import '../../domain/repositories/owner_settings_repository.dart';
import '../datasources/owner_settings_data_source.dart';

class OwnerSettingsRepositoryImpl implements OwnerSettingsRepository {
  OwnerSettingsRepositoryImpl(this._dataSource);

  final OwnerSettingsDataSource _dataSource;

  @override
  Future<Result<List<OwnerListedUser>>> listUsers({int limit = 100}) {
    return _guard(() => _dataSource.listUsers(limit: limit));
  }

  @override
  Future<Result<HomepageSettings>> getHomepageSettings() {
    return _guard(_dataSource.getHomepageSettings);
  }

  @override
  Future<Result<HomepageSettings>> updateStoreBanner({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  }) {
    return _guard(
      () => _dataSource.updateStoreBanner(
        bytes: bytes,
        contentType: contentType,
        fileExtension: fileExtension,
      ),
    );
  }

  @override
  Future<Result<HomepageSettings>> updateStoreContact({
    String? email,
    String? phone,
    String? storeAddress,
    String? mapsUrl,
  }) {
    return _guard(
      () => _dataSource.updateStoreContact(
        email: email,
        phone: phone,
        storeAddress: storeAddress,
        mapsUrl: mapsUrl,
      ),
    );
  }

  @override
  Future<Result<LegalSettings>> getLegalSettings() {
    return _guard(_dataSource.getLegalSettings);
  }

  @override
  Future<Result<LegalSettings>> uploadLegalPdf({
    required LegalDocumentType type,
    required Uint8List bytes,
  }) {
    return _guard(
      () => _dataSource.uploadLegalPdf(type: type, bytes: bytes),
    );
  }

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on Failure catch (failure) {
      return Error(failure);
    } catch (error) {
      return Error(ServerFailure(message: error.toString()));
    }
  }
}
