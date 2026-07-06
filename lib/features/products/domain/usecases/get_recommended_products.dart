import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetRecommendedProducts extends SyncUseCaseNoParams<List<ProductEntity>> {
  GetRecommendedProducts(this._repository);

  final ProductRepository _repository;

  @override
  Result<List<ProductEntity>> call() {
    return guardSync(_repository.getRecommended);
  }
}
