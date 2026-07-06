import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistCountUseCase extends BaseUseCaseNoParams<int> {
  GetWishlistCountUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<int>> call() {
    return guard(_repository.getCount);
  }
}
