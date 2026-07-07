import '../models/category_model.dart';
import '../models/subcategory_model.dart';

/// Contract for category data sources (mock or Firestore).
abstract class CategoryDataSource {
  Future<List<CategoryModel>> getAllCategories();

  Future<CategoryModel?> getCategoryById(String id);

  Future<List<SubcategoryModel>> getSubcategories(String categoryId);
}
