import '../mock/mock_products.dart';
import '../models/product_model.dart';
import 'product_data_source.dart';

/// Reads from existing [MockProducts] without modifying mock data.
class ProductMockDataSource implements ProductDataSource {
  const ProductMockDataSource();

  static final List<ProductModel> _models = MockProducts.products
      .map(ProductModel.fromEntity)
      .toList(growable: false);

  @override
  List<ProductModel> getAllProducts() =>
      List<ProductModel>.from(_models);

  @override
  ProductModel? getProductById(String id) {
    for (final model in _models) {
      if (model.id == id) {
        return model;
      }
    }
    return null;
  }

  @override
  List<ProductModel> getFeaturedProducts() =>
      _models.where((model) => model.isFeatured).toList(growable: false);

  @override
  List<ProductModel> getProductsByCategory(String categoryId) => _models
      .where((model) => model.categoryId == categoryId)
      .toList(growable: false);
}
