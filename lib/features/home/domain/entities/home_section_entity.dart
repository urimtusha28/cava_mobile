import '../../../products/domain/entities/product_entity.dart';

enum HomeSectionType {
  recommended,
  bestSellers,
  offers,
}

class HomeSectionEntity {
  const HomeSectionEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.seeAllRoute,
    required this.products,
  });

  final String id;
  final String title;
  final HomeSectionType type;
  final String seeAllRoute;
  final List<ProductEntity> products;
}
