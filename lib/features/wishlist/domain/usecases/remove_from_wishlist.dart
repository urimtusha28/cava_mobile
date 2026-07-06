import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase extends SyncUseCase<void, String> {
  RemoveFromWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Result<void> call(String productId) {
    return guardSync(() {
      _repository.remove(productId);
    });
  }
}
