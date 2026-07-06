import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase extends SyncUseCaseNoParams<List<CategoryEntity>> {
  GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Result<List<CategoryEntity>> call() {
    return guardSync(_repository.getAll);
  }
}
