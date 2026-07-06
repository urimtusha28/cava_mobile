import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase extends BaseUseCase<void, String> {
  RemoveFromWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<void>> call(String productId) {
    return guard(() => _repository.remove(productId));
  }
}
