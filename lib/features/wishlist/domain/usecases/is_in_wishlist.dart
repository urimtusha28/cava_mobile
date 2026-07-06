import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/wishlist_repository.dart';

class IsInWishlistUseCase extends BaseUseCase<bool, String> {
  IsInWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<bool>> call(String productId) {
    return guard(() => _repository.isInWishlist(productId));
  }
}
