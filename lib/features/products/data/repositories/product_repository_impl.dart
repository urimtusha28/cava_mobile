import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_data_source.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dataSource);

  final ProductDataSource _dataSource;

  @override
  Future<List<ProductEntity>> getRecommended() => Future.sync(() {
        return ProductMapper.toEntityList(_dataSource.getFeaturedProducts());
      });

  @override
  Future<List<ProductEntity>> getBestSellers() => Future.sync(() {
        final models = List.of(_dataSource.getAllProducts());
        models.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        return ProductMapper.toEntityList(models.take(8).toList(growable: false));
      });

  @override
  Future<List<ProductEntity>> getOffers() => Future.sync(() {
        final models = _dataSource
            .getAllProducts()
            .where((model) => model.oldPrice != null)
            .toList(growable: false);
        return ProductMapper.toEntityList(models);
      });

  @override
  Future<List<ProductEntity>> getAll() => Future.sync(() {
        return ProductMapper.toEntityList(_dataSource.getAllProducts());
      });

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) =>
      Future.sync(() {
        return ProductMapper.toEntityList(
          _dataSource.getProductsByCategory(categoryId),
        );
      });

  @override
  Future<ProductEntity?> getById(String id) => Future.sync(() {
        final model = _dataSource.getProductById(id);
        return model == null ? null : ProductMapper.toEntity(model);
      });
}
