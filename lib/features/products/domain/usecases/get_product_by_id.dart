import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductById extends BaseUseCase<ProductEntity?, String> {
  GetProductById(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<ProductEntity?>> call(String productId) {
    return guard(() => _repository.getById(productId));
  }
}
