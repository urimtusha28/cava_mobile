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
  List<CategoryModel> getAllCategories() =>
      List<CategoryModel>.from(_categories);

  @override
  CategoryModel? getCategoryById(String id) {
    for (final model in _categories) {
      if (model.id == id) {
        return model;
      }
    }
    return null;
  }

  @override
  List<SubcategoryModel> getSubcategories(String categoryId) {
    return MockSubcategories.forCategory(categoryId)
        .map(SubcategoryModel.fromEntity)
        .toList(growable: false);
  }
}
