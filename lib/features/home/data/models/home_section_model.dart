enum HomeSectionTypeModel {
  recommended,
  bestSellers,
  offers,
}

class HomeSectionModel {
  const HomeSectionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.seeAllRoute,
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: _typeFromString(json['type'] as String),
      seeAllRoute: json['seeAllRoute'] as String,
    );
  }

  final String id;
  final String title;
  final HomeSectionTypeModel type;
  final String seeAllRoute;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'seeAllRoute': seeAllRoute,
    };
  }

  static HomeSectionTypeModel _typeFromString(String value) {
    return switch (value) {
      'best_sellers' || 'bestSellers' => HomeSectionTypeModel.bestSellers,
      'offers' => HomeSectionTypeModel.offers,
      _ => HomeSectionTypeModel.recommended,
    };
  }
}
