import 'dart:typed_data';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../domain/entities/owner_settings_entities.dart';
import '../../domain/repositories/owner_settings_repository.dart';

enum OwnerSettingsViewStatus { initial, loading, success, error }

class OwnerSettingsController extends BaseController {
  OwnerSettingsController(this._repository);

  final OwnerSettingsRepository _repository;

  OwnerSettingsViewStatus status = OwnerSettingsViewStatus.initial;
  String? sectionError;

  List<OwnerListedUser> users = const [];
  HomepageSettings homepage = HomepageSettings.empty;
  LegalSettings legal = LegalSettings.empty;
  bool isSaving = false;

  Future<void> loadUsers() {
    return runLoad(() async {
      status = OwnerSettingsViewStatus.loading;
      sectionError = null;
      notifyListeners();

      final result = await _repository.listUsers();
      if (result.isFailure) {
        users = const [];
        sectionError = result.failureOrNull?.message;
        status = OwnerSettingsViewStatus.error;
        return;
      }
      users = result.dataOrNull ?? const [];
      status = OwnerSettingsViewStatus.success;
    });
  }

  Future<void> loadHomepage() {
    return runLoad(() async {
      status = OwnerSettingsViewStatus.loading;
      sectionError = null;
      notifyListeners();

      final result = await _repository.getHomepageSettings();
      if (result.isFailure) {
        homepage = HomepageSettings.empty;
        sectionError = result.failureOrNull?.message;
        status = OwnerSettingsViewStatus.error;
        return;
      }
      homepage = result.dataOrNull ?? HomepageSettings.empty;
      status = OwnerSettingsViewStatus.success;
    });
  }

  Future<void> loadLegal() {
    return runLoad(() async {
      status = OwnerSettingsViewStatus.loading;
      sectionError = null;
      notifyListeners();

      final result = await _repository.getLegalSettings();
      if (result.isFailure) {
        legal = LegalSettings.empty;
        sectionError = result.failureOrNull?.message;
        status = OwnerSettingsViewStatus.error;
        return;
      }
      legal = result.dataOrNull ?? LegalSettings.empty;
      status = OwnerSettingsViewStatus.success;
    });
  }

  Future<bool> uploadBanner({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  }) async {
    isSaving = true;
    sectionError = null;
    notifyListeners();
    final result = await _repository.updateStoreBanner(
      bytes: bytes,
      contentType: contentType,
      fileExtension: fileExtension,
    );
    isSaving = false;
    if (result.isFailure) {
      sectionError = result.failureOrNull?.message;
      notifyListeners();
      return false;
    }
    homepage = result.dataOrNull ?? homepage;
    notifyListeners();
    return true;
  }

  Future<bool> saveStoreContact({
    String? email,
    String? phone,
    String? storeAddress,
    String? mapsUrl,
  }) async {
    isSaving = true;
    sectionError = null;
    notifyListeners();
    final result = await _repository.updateStoreContact(
      email: email,
      phone: phone,
      storeAddress: storeAddress,
      mapsUrl: mapsUrl,
    );
    isSaving = false;
    if (result.isFailure) {
      sectionError = result.failureOrNull?.message;
      notifyListeners();
      return false;
    }
    homepage = result.dataOrNull ?? homepage;
    notifyListeners();
    return true;
  }

  Future<bool> uploadLegalPdf({
    required LegalDocumentType type,
    required Uint8List bytes,
  }) async {
    isSaving = true;
    sectionError = null;
    notifyListeners();
    final result = await _repository.uploadLegalPdf(type: type, bytes: bytes);
    isSaving = false;
    if (result.isFailure) {
      sectionError = result.failureOrNull?.message;
      notifyListeners();
      return false;
    }
    legal = result.dataOrNull ?? legal;
    notifyListeners();
    return true;
  }
}

OwnerSettingsController createOwnerSettingsController() {
  configureDependencies();
  return sl<OwnerSettingsController>();
}
