import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistItemsUseCase extends BaseUseCaseNoParams<List<ProductEntity>> {
  GetWishlistItemsUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<List<ProductEntity>>> call() {
    return guard(_repository.getItems);
  }
}
