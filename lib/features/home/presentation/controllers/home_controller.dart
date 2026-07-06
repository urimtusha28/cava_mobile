import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/get_categories.dart';
import '../../domain/entities/home_section_entity.dart';
import '../../domain/usecases/get_home_sections.dart';

class HomeController extends BaseController {
  HomeController(this._getCategories, this._getHomeSections);

  final GetCategoriesUseCase _getCategories;
  final GetHomeSectionsUseCase _getHomeSections;

  List<CategoryEntity> categories = const [];
  List<HomeSectionEntity> sections = const [];

  HomeSectionEntity? sectionByType(HomeSectionType type) {
    for (final section in sections) {
      if (section.type == type) {
        return section;
      }
    }
    return null;
  }

  Future<void> load() {
    return runLoad(() async {
      categories = await unwrapFutureResult(
        _getCategories(),
        fallback: const [],
      );
      sections = await unwrapFutureResult(
        _getHomeSections(),
        fallback: const [],
      );
    });
  }
}

HomeController createHomeController() {
  configureDependencies();
  return HomeController(sl(), sl());
}
