import '../../../core/di/injection.dart';
import '../../../core/result/result.dart';
import '../domain/entities/category_entity.dart';
import '../domain/usecases/get_categories.dart';
import '../domain/usecases/get_category_by_id.dart';
import 'categories_module.dart';

abstract final class CategoriesQuery {
  static List<CategoryEntity> getAll() {
    CategoriesModule.ensureInitialized();
    return _unwrap(sl<GetCategoriesUseCase>().call());
  }

  static CategoryEntity? getById(String categoryId) {
    CategoriesModule.ensureInitialized();
    return sl<GetCategoryByIdUseCase>().call(categoryId).fold(
          onSuccess: (category) => category,
          onFailure: (_) => null,
        );
  }

  static List<CategoryEntity> _unwrap(Result<List<CategoryEntity>> result) {
    return result.fold(
      onSuccess: (data) => data,
      onFailure: (_) => const [],
    );
  }
}
