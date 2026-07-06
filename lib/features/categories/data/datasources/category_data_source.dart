import '../models/category_model.dart';
import '../models/subcategory_model.dart';

abstract class CategoryDataSource {
  List<CategoryModel> getAllCategories();

  CategoryModel? getCategoryById(String id);

  List<SubcategoryModel> getSubcategories(String categoryId);
}
