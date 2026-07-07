class SubcategoryEntity {
  const SubcategoryEntity({
    required this.id,
    required this.label,
    this.matchTypes = const [],
    this.matchKeywords = const [],
    this.badgeColor,
  });

  final String id;
  final String label;
  final List<String> matchTypes;
  final List<String> matchKeywords;
  final String? badgeColor;
}
