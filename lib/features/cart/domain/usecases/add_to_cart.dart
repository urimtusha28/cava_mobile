import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase extends BaseUseCase<void, ProductEntity> {
  AddToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<void>> call(ProductEntity product) {
    return guard(() => _repository.addProduct(product));
  }
}
