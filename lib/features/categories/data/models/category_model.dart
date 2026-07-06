import '../../domain/entities/category_entity.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.label,
    required this.emoji,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      label: entity.label,
      emoji: entity.emoji,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String label;
  final String emoji;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'emoji': emoji,
    };
  }
}
