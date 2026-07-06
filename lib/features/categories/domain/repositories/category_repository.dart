import '../entities/category_entity.dart';
import '../entities/subcategory_entity.dart';

/// Domain contract for category and subcategory data access.
abstract class CategoryRepository {
  List<CategoryEntity> getAll();

  CategoryEntity? getById(String id);

  List<SubcategoryEntity> getSubcategories(String categoryId);
}
