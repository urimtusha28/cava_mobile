import '../entities/product_entity.dart';

/// Domain contract for product data access.
///
/// Synchronous reads in Phase 2 (mock). Will move to [Future] in Firestore phase.
abstract class ProductRepository {
  List<ProductEntity> getRecommended();

  List<ProductEntity> getBestSellers();

  List<ProductEntity> getOffers();

  List<ProductEntity> getAll();

  List<ProductEntity> getProductsByCategory(String categoryId);

  ProductEntity? getById(String id);
}
