import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistCountUseCase extends SyncUseCaseNoParams<int> {
  GetWishlistCountUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Result<int> call() {
    return guardSync(_repository.getCount);
  }
}
