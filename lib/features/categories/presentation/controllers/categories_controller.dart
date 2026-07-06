import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories.dart';

class CategoriesController extends BaseController {
  CategoriesController(this._getCategories);

  final GetCategoriesUseCase _getCategories;

  List<CategoryEntity> categories = const [];

  Future<void> load() {
    return runLoad(() async {
      categories = await unwrapFutureResult(
        _getCategories(),
        fallback: const [],
      );
    });
  }
}

CategoriesController createCategoriesController() {
  configureDependencies();
  return sl<CategoriesController>();
}
