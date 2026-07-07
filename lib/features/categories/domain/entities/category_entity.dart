class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.label,
    required this.emoji,
    this.badgeColor,
  });

  final String id;
  final String name;
  final String label;
  final String emoji;
  final String? badgeColor;
}
