import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/home_section_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_data_source.dart';
import '../mappers/home_section_mapper.dart';
import '../models/home_section_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._dataSource, this._productRepository);

  final HomeDataSource _dataSource;
  final ProductRepository _productRepository;

  @override
  Future<List<HomeSectionEntity>> getSections() async {
    final configs = _dataSource.getSectionConfigs();
    final sections = <HomeSectionEntity>[];
    for (final model in configs) {
      sections.add(await _resolveSection(model));
    }
    return sections;
  }

  Future<HomeSectionEntity> _resolveSection(HomeSectionModel model) async {
    final products = await _productsForType(model.type);
    return HomeSectionMapper.toEntity(model, products: products);
  }

  Future<List<ProductEntity>> _productsForType(HomeSectionTypeModel type) {
    return switch (type) {
      HomeSectionTypeModel.recommended => _productRepository.getRecommended(),
      HomeSectionTypeModel.bestSellers => _productRepository.getBestSellers(),
      HomeSectionTypeModel.offers => _productRepository.getOffers(),
    };
  }
}
