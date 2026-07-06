import '../models/home_section_model.dart';
import 'home_data_source.dart';

/// Static home section metadata — products resolved in [HomeRepositoryImpl].
class HomeMockDataSource implements HomeDataSource {
  const HomeMockDataSource();

  static const List<HomeSectionModel> _sections = [
    HomeSectionModel(
      id: 'recommended',
      title: 'Të rekomanduara',
      type: HomeSectionTypeModel.recommended,
      seeAllRoute: '/category/wines',
    ),
    HomeSectionModel(
      id: 'best_sellers',
      title: 'Më të shiturat',
      type: HomeSectionTypeModel.bestSellers,
      seeAllRoute: '/category/spirits',
    ),
    HomeSectionModel(
      id: 'offers',
      title: 'Oferta',
      type: HomeSectionTypeModel.offers,
      seeAllRoute: '/category/wines',
    ),
  ];

  @override
  List<HomeSectionModel> getSectionConfigs() =>
      List<HomeSectionModel>.from(_sections);
}
