import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetOfferProducts extends BaseUseCaseNoParams<List<ProductEntity>> {
  GetOfferProducts(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<ProductEntity>>> call() {
    return guard(_repository.getOffers);
  }
}
