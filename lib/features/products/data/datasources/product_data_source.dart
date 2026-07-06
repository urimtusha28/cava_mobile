import '../models/product_model.dart';

/// Contract for product data sources (mock or Firestore).
abstract class ProductDataSource {
  Future<List<ProductModel>> getAllProducts();

  Future<ProductModel?> getProductById(String id);

  Future<List<ProductModel>> getFeaturedProducts();

  Future<List<ProductModel>> getProductsByCategory(String categoryId);
}
