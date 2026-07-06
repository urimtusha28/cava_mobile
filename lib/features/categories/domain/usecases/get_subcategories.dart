import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/subcategory_entity.dart';
import '../repositories/category_repository.dart';

class GetSubcategoriesUseCase extends BaseUseCase<List<SubcategoryEntity>, String> {
  GetSubcategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<List<SubcategoryEntity>>> call(String categoryId) {
    return guard(() => _repository.getSubcategories(categoryId));
  }
}
