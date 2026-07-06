import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase extends BaseUseCaseNoParams<List<CategoryEntity>> {
  GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<List<CategoryEntity>>> call() {
    return guard(_repository.getAll);
  }
}
