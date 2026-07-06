import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getRecommended();

  Future<List<ProductEntity>> getBestSellers();

  Future<List<ProductEntity>> getOffers();

  Future<List<ProductEntity>> getAll();

  Future<List<ProductEntity>> getProductsByCategory(String categoryId);

  Future<ProductEntity?> getById(String id);
}
