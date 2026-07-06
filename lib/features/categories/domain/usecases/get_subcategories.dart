import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/subcategory_entity.dart';
import '../repositories/category_repository.dart';

class GetSubcategoriesUseCase extends SyncUseCase<List<SubcategoryEntity>, String> {
  GetSubcategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Result<List<SubcategoryEntity>> call(String categoryId) {
    return guardSync(() => _repository.getSubcategories(categoryId));
  }
}
