import '../models/product_model.dart';

/// Contract for product data sources (mock now, Firestore in Phase 3).
abstract class ProductDataSource {
  List<ProductModel> getAllProducts();

  ProductModel? getProductById(String id);

  List<ProductModel> getFeaturedProducts();

  List<ProductModel> getProductsByCategory(String categoryId);
}
