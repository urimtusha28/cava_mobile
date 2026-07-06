import '../entities/home_section_entity.dart';

abstract class HomeRepository {
  Future<List<HomeSectionEntity>> getSections();
}
