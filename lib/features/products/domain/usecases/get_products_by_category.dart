import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryUseCase
    extends SyncUseCase<List<ProductEntity>, String> {
  GetProductsByCategoryUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Result<List<ProductEntity>> call(String categoryId) {
    return guardSync(() => _repository.getProductsByCategory(categoryId));
  }
}
