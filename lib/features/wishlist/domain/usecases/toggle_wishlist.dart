import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../repositories/wishlist_repository.dart';

class ToggleWishlistUseCase extends BaseUseCase<void, ProductEntity> {
  ToggleWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<void>> call(ProductEntity product) {
    return guard(() => _repository.toggle(product));
  }
}
