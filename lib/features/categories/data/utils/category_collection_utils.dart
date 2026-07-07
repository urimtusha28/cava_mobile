import '../models/category_model.dart';

/// Sorts categories by [CategoryModel.order]; missing/zero order goes last.
List<CategoryModel> sortCategoriesByOrder(List<CategoryModel> categories) {
  final sorted = List<CategoryModel>.from(categories);
  sorted.sort((a, b) {
    final aOrder = a.order;
    final bOrder = b.order;
    if (aOrder == 0 && bOrder == 0) {
      return a.name.compareTo(b.name);
    }
    if (aOrder == 0) {
      return 1;
    }
    if (bOrder == 0) {
      return -1;
    }
    return aOrder.compareTo(bOrder);
  });
  return sorted;
}

/// Resolves a route slug or document id to a category document id.
String? resolveCategoryDocumentId(
  List<CategoryModel> categories,
  String categoryKey,
) {
  for (final category in categories) {
    if (category.id == categoryKey || category.slug == categoryKey) {
      return category.id;
    }
  }
  return null;
}
