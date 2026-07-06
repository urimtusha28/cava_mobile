import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductById extends SyncUseCase<ProductEntity?, String> {
  GetProductById(this._repository);

  final ProductRepository _repository;

  @override
  Result<ProductEntity?> call(String productId) {
    return guardSync(() => _repository.getById(productId));
  }
}
