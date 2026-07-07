import '../../domain/entities/category_entity.dart';

/// Data model aligned with web Firebase `categories` collection.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.parentId,
    this.type,
    this.order = 0,
    this.isActive = true,
    this.badgeColor,
    this.label = '',
    this.emoji = '',
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      slug: entity.id,
      name: entity.name,
      label: entity.label,
      emoji: entity.emoji,
      badgeColor: entity.badgeColor,
      type: 'main',
      isActive: true,
    );
  }

  /// Parses web Firebase schema or legacy mock JSON.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final type = json['type'] as String?;
    final isWebSchema = type == 'main' || type == 'sub';

    if (isWebSchema) {
      return CategoryModel(
        id: id,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        parentId: json['parentId'] as String?,
        type: json['type'] as String?,
        order: _readInt(json['order']),
        isActive: json['isActive'] as bool? ?? true,
        badgeColor: json['badgeColor'] as String?,
      );
    }

    return CategoryModel(
      id: id,
      name: json['name'] as String? ?? '',
      slug: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      type: 'main',
      isActive: true,
    );
  }

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final String? type;
  final int order;
  final bool isActive;
  final String? badgeColor;

  /// Legacy mock display fields — unused by web schema.
  final String label;
  final String emoji;

  bool get isMainCategory =>
      type == 'main' && (parentId == null || parentId!.isEmpty);

  bool get isSubCategory =>
      type == 'sub' && parentId != null && parentId!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (slug.isNotEmpty) 'slug': slug,
      if (parentId != null) 'parentId': parentId,
      if (type != null) 'type': type,
      'order': order,
      'isActive': isActive,
      if (badgeColor != null) 'badgeColor': badgeColor,
      if (label.isNotEmpty) 'label': label,
      if (emoji.isNotEmpty) 'emoji': emoji,
    };
  }

  static int _readInt(Object? value, [int fallback = 0]) {
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }
}
