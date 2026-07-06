import '../datasources/home_data_source.dart';
import '../models/home_section_model.dart';

/// Firestore placeholder — not wired in Phase 5.
class HomeFirestoreDataSource implements HomeDataSource {
  const HomeFirestoreDataSource();

  Never _todo() => throw UnimplementedError(
        'HomeFirestoreDataSource is not implemented yet.',
      );

  @override
  List<HomeSectionModel> getSectionConfigs() => _todo();
}
