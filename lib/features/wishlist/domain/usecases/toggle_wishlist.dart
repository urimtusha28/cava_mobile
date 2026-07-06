import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../repositories/wishlist_repository.dart';

class ToggleWishlistUseCase extends SyncUseCase<void, ProductEntity> {
  ToggleWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Result<void> call(ProductEntity product) {
    return guardSync(() {
      _repository.toggle(product);
    });
  }
}
