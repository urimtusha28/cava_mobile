import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_data_source.dart';
import '../mappers/category_mapper.dart';
import '../mappers/subcategory_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);

  final CategoryDataSource _dataSource;

  @override
  Future<List<CategoryEntity>> getAll() async {
    final models = await _dataSource.getAllCategories();
    return CategoryMapper.toEntityList(models);
  }

  @override
  Future<CategoryEntity?> getById(String id) async {
    final model = await _dataSource.getCategoryById(id);
    return model == null ? null : CategoryMapper.toEntity(model);
  }

  @override
  Future<List<SubcategoryEntity>> getSubcategories(String categoryId) async {
    return SubcategoryMapper.toEntityList(
      await _dataSource.getSubcategories(categoryId),
    );
  }
}
