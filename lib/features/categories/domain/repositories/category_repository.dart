import '../entities/category_entity.dart';
import '../entities/subcategory_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAll();

  Future<CategoryEntity?> getById(String id);

  Future<List<SubcategoryEntity>> getSubcategories(String categoryId);
}
