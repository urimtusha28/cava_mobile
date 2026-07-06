import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/wishlist_repository.dart';

class IsInWishlistUseCase extends SyncUseCase<bool, String> {
  IsInWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Result<bool> call(String productId) {
    return guardSync(() => _repository.isInWishlist(productId));
  }
}
