import '../mock/mock_categories.dart';
import '../mock/mock_subcategories.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import 'category_data_source.dart';

/// Reads from existing mock data without modifying it.
class CategoryMockDataSource implements CategoryDataSource {
  const CategoryMockDataSource();

  static final List<CategoryModel> _categories = MockCategories.categories
      .map(CategoryModel.fromEntity)
      .toList(growable: false);

  @override
  Future<List<CategoryModel>> getAllCategories() async =>
      List<CategoryModel>.from(_categories);

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    for (final model in _categories) {
      if (model.id == id || model.slug == id) {
        return model;
      }
    }
    return null;
  }

  @override
  Future<List<SubcategoryModel>> getSubcategories(String categoryId) async {
    return MockSubcategories.forCategory(categoryId)
        .map(SubcategoryModel.fromEntity)
        .toList(growable: false);
  }
}
