import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../domain/entities/owner_dashboard_entities.dart';
import '../../domain/usecases/get_owner_dashboard_snapshot.dart';

enum OwnerDashboardViewStatus {
  initial,
  loading,
  success,
  empty,
  error,
  refreshing,
}

class OwnerDashboardController extends BaseController {
  OwnerDashboardController(this._getSnapshot);

  final GetOwnerDashboardSnapshotUseCase _getSnapshot;

  OwnerDashboardViewStatus status = OwnerDashboardViewStatus.initial;
  OwnerDashboardSnapshot? snapshot;
  String? sectionError;

  Future<void> load() {
    return runLoad(() async {
      status = OwnerDashboardViewStatus.loading;
      sectionError = null;
      notifyListeners();

      final result = await _getSnapshot();
      if (result.isFailure) {
        snapshot = null;
        sectionError = result.failureOrNull?.message ??
            'Dashboard nuk u ngarkua. Provo përsëri.';
        status = OwnerDashboardViewStatus.error;
        return;
      }

      snapshot = result.dataOrNull;
      final hasAnyData = snapshot != null &&
          (snapshot!.summary.totalOrders > 0 ||
              snapshot!.summary.salesLast30Days > 0 ||
              snapshot!.recentOrders.isNotEmpty);
      status = hasAnyData
          ? OwnerDashboardViewStatus.success
          : OwnerDashboardViewStatus.empty;
    });
  }

  Future<void> refresh() async {
    if (status == OwnerDashboardViewStatus.loading ||
        status == OwnerDashboardViewStatus.refreshing) {
      return;
    }
    status = OwnerDashboardViewStatus.refreshing;
    notifyListeners();

    final result = await _getSnapshot();
    if (result.isFailure) {
      sectionError = result.failureOrNull?.message ??
          'Rifreskimi dështoi. Provo përsëri.';
      status = snapshot == null
          ? OwnerDashboardViewStatus.error
          : OwnerDashboardViewStatus.success;
      notifyListeners();
      return;
    }

    snapshot = result.dataOrNull;
    sectionError = null;
    final hasAnyData = snapshot != null &&
        (snapshot!.summary.totalOrders > 0 ||
            snapshot!.summary.salesLast30Days > 0 ||
            snapshot!.recentOrders.isNotEmpty);
    status = hasAnyData
        ? OwnerDashboardViewStatus.success
        : OwnerDashboardViewStatus.empty;
    notifyListeners();
  }
}

OwnerDashboardController createOwnerDashboardController() {
  configureDependencies();
  return sl<OwnerDashboardController>();
}
