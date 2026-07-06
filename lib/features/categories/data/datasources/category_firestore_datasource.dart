import '../datasources/category_data_source.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';

/// Firestore placeholder — not wired in Phase 5.
class CategoryFirestoreDataSource implements CategoryDataSource {
  const CategoryFirestoreDataSource();

  Never _todo() => throw UnimplementedError(
        'CategoryFirestoreDataSource is not implemented yet.',
      );

  @override
  List<CategoryModel> getAllCategories() => _todo();

  @override
  CategoryModel? getCategoryById(String id) => _todo();

  @override
  List<SubcategoryModel> getSubcategories(String categoryId) => _todo();
}
