import '../../../categories/domain/entities/category_entity.dart';

/// Puts [wines] first among home category chips (second after "All Products").
List<CategoryEntity> prioritizeWinesForHome(List<CategoryEntity> categories) {
  if (categories.length < 2) {
    return categories;
  }

  final winesIndex = categories.indexWhere(
    (category) => category.id.toLowerCase() == 'wines',
  );
  if (winesIndex <= 0) {
    return categories;
  }

  final ordered = List<CategoryEntity>.from(categories);
  final wines = ordered.removeAt(winesIndex);
  ordered.insert(0, wines);
  return List<CategoryEntity>.unmodifiable(ordered);
}
