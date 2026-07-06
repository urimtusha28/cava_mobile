import '../models/home_section_model.dart';

abstract class HomeDataSource {
  List<HomeSectionModel> getSectionConfigs();
}
