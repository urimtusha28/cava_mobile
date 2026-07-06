import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoryByIdUseCase extends BaseUseCase<CategoryEntity?, String> {
  GetCategoryByIdUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<CategoryEntity?>> call(String categoryId) {
    return guard(() => _repository.getById(categoryId));
  }
}
