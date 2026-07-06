import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/home_section_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeSectionsUseCase extends BaseUseCaseNoParams<List<HomeSectionEntity>> {
  GetHomeSectionsUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Result<List<HomeSectionEntity>>> call() {
    return guard(_repository.getSections);
  }
}
