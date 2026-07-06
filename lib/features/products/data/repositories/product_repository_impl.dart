import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_data_source.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dataSource);

  final ProductDataSource _dataSource;

  @override
  List<ProductEntity> getRecommended() {
    return ProductMapper.toEntityList(_dataSource.getFeaturedProducts());
  }

  @override
  List<ProductEntity> getBestSellers() {
    final models = List.of(_dataSource.getAllProducts());
    models.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return ProductMapper.toEntityList(models.take(8).toList(growable: false));
  }

  @override
  List<ProductEntity> getOffers() {
    final models = _dataSource
        .getAllProducts()
        .where((model) => model.oldPrice != null)
        .toList(growable: false);
    return ProductMapper.toEntityList(models);
  }

  @override
  List<ProductEntity> getAll() {
    return ProductMapper.toEntityList(_dataSource.getAllProducts());
  }

  @override
  List<ProductEntity> getProductsByCategory(String categoryId) {
    return ProductMapper.toEntityList(
      _dataSource.getProductsByCategory(categoryId),
    );
  }

  @override
  ProductEntity? getById(String id) {
    final model = _dataSource.getProductById(id);
    return model == null ? null : ProductMapper.toEntity(model);
  }
}
