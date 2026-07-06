import '../../domain/entities/subcategory_entity.dart';

class SubcategoryModel {
  const SubcategoryModel({
    required this.id,
    required this.label,
    this.matchTypes = const [],
    this.matchKeywords = const [],
  });

  factory SubcategoryModel.fromEntity(SubcategoryEntity entity) {
    return SubcategoryModel(
      id: entity.id,
      label: entity.label,
      matchTypes: entity.matchTypes,
      matchKeywords: entity.matchKeywords,
    );
  }

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as String,
      label: json['label'] as String,
      matchTypes: (json['matchTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      matchKeywords: (json['matchKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  final String id;
  final String label;
  final List<String> matchTypes;
  final List<String> matchKeywords;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'matchTypes': matchTypes,
      'matchKeywords': matchKeywords,
    };
  }
}
