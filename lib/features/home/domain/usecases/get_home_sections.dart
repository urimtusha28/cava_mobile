import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/home_section_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeSectionsUseCase extends SyncUseCaseNoParams<List<HomeSectionEntity>> {
  GetHomeSectionsUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Result<List<HomeSectionEntity>> call() {
    return guardSync(_repository.getSections);
  }
}
