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
  Future<List<CategoryEntity>> getAll() => Future.sync(() {
        return CategoryMapper.toEntityList(_dataSource.getAllCategories());
      });

  @override
  Future<CategoryEntity?> getById(String id) => Future.sync(() {
        final model = _dataSource.getCategoryById(id);
        return model == null ? null : CategoryMapper.toEntity(model);
      });

  @override
  Future<List<SubcategoryEntity>> getSubcategories(String categoryId) =>
      Future.sync(() {
        return SubcategoryMapper.toEntityList(
          _dataSource.getSubcategories(categoryId),
        );
      });
}
