import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetOfferProducts extends SyncUseCaseNoParams<List<ProductEntity>> {
  GetOfferProducts(this._repository);

  final ProductRepository _repository;

  @override
  Result<List<ProductEntity>> call() {
    return guardSync(_repository.getOffers);
  }
}
