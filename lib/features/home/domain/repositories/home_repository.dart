import '../entities/home_section_entity.dart';

abstract class HomeRepository {
  List<HomeSectionEntity> getSections();
}
