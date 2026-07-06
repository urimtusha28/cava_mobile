import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_data_source.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dataSource);

  final ProductDataSource _dataSource;

  @override
  Future<List<ProductEntity>> getRecommended() async {
    final models = await _dataSource.getFeaturedProducts();
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<ProductEntity>> getBestSellers() async {
    final models = List.of(await _dataSource.getAllProducts());
    models.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return ProductMapper.toEntityList(models.take(8).toList(growable: false));
  }

  @override
  Future<List<ProductEntity>> getOffers() async {
    final models = (await _dataSource.getAllProducts())
        .where((model) => model.oldPrice != null)
        .toList(growable: false);
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<ProductEntity>> getAll() async {
    return ProductMapper.toEntityList(await _dataSource.getAllProducts());
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    return ProductMapper.toEntityList(
      await _dataSource.getProductsByCategory(categoryId),
    );
  }

  @override
  Future<ProductEntity?> getById(String id) async {
    final model = await _dataSource.getProductById(id);
    return model == null ? null : ProductMapper.toEntity(model);
  }
}
