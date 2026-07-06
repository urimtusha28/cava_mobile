import '../datasources/product_data_source.dart';
import '../models/product_model.dart';

/// Firestore placeholder — not wired in Phase 5.
///
/// TODO(Phase 6): Implement with `cloud_firestore` when Firebase is enabled.
class ProductFirestoreDataSource implements ProductDataSource {
  const ProductFirestoreDataSource();

  Never _todo() => throw UnimplementedError(
        'ProductFirestoreDataSource is not implemented yet. '
        'Run flutterfire configure and enable FirebaseConfig.',
      );

  @override
  List<ProductModel> getAllProducts() => _todo();

  @override
  ProductModel? getProductById(String id) => _todo();

  @override
  List<ProductModel> getFeaturedProducts() => _todo();

  @override
  List<ProductModel> getProductsByCategory(String categoryId) => _todo();
}
