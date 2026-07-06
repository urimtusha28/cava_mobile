import '../../../core/di/injection.dart';
import '../domain/entities/home_section_entity.dart';
import '../domain/usecases/get_home_sections.dart';
import 'home_module.dart';

abstract final class HomeSectionsQuery {
  static List<HomeSectionEntity> getSections() {
    HomeModule.ensureInitialized();
    return sl<GetHomeSectionsUseCase>().call().fold(
          onSuccess: (sections) => sections,
          onFailure: (_) => const [],
        );
  }

  static HomeSectionEntity? sectionByType(HomeSectionType type) {
    for (final section in getSections()) {
      if (section.type == type) {
        return section;
      }
    }
    return null;
  }
}
