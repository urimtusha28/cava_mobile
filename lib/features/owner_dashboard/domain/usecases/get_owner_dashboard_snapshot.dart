import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/owner_dashboard_entities.dart';
import '../repositories/owner_dashboard_repository.dart';

class GetOwnerDashboardSnapshotUseCase
    extends BaseUseCaseNoParams<OwnerDashboardSnapshot> {
  GetOwnerDashboardSnapshotUseCase(this._repository);

  final OwnerDashboardRepository _repository;

  @override
  Future<Result<OwnerDashboardSnapshot>> call() {
    return guard(_repository.getDashboardSnapshot);
  }
}
