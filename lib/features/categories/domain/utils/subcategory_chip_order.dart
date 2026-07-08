import '../entities/subcategory_entity.dart';

bool _isAllChip(SubcategoryEntity sub) {
  final id = sub.id.trim().toLowerCase();
  return id == 'all' || id.startsWith('all');
}

bool _isRedWine(SubcategoryEntity sub) {
  final id = sub.id.trim().toLowerCase();
  final label = sub.label.trim().toLowerCase();
  if (id == 'red' || id == 'red-wine' || id.startsWith('red-')) {
    return true;
  }
  return label == 'red wine' ||
      label == 'red' ||
      label.startsWith('red wine');
}

bool _isGin(SubcategoryEntity sub) {
  final id = sub.id.trim().toLowerCase();
  final label = sub.label.trim().toLowerCase();
  return id == 'gin' || label == 'gin';
}

bool _isWhiskey(SubcategoryEntity sub) {
  final id = sub.id.trim().toLowerCase();
  final label = sub.label.trim().toLowerCase();
  if (id == 'whiskey' || id == 'whisky' || id.startsWith('whiskey')) {
    return true;
  }
  return label == 'whiskey' ||
      label == 'whisky' ||
      label.startsWith('whiskey');
}

List<SubcategoryEntity> _moveAfterAnchor({
  required List<SubcategoryEntity> subcategories,
  required bool Function(SubcategoryEntity) isTarget,
  required bool Function(SubcategoryEntity) isAnchor,
  int fallbackIndex = 0,
}) {
  if (subcategories.length < 2) {
    return subcategories;
  }

  final targetIndex = subcategories.indexWhere(isTarget);
  if (targetIndex < 0) {
    return subcategories;
  }

  final anchorIndex = subcategories.indexWhere(isAnchor);
  final desiredIndex = anchorIndex >= 0 ? anchorIndex + 1 : fallbackIndex;
  if (targetIndex == desiredIndex) {
    return subcategories;
  }

  final ordered = List<SubcategoryEntity>.from(subcategories);
  final target = ordered.removeAt(targetIndex);
  final insertAt =
      targetIndex < desiredIndex ? desiredIndex - 1 : desiredIndex;
  ordered.insert(insertAt.clamp(0, ordered.length), target);
  return List<SubcategoryEntity>.unmodifiable(ordered);
}

/// Ensures **Red Wine** is immediately after the **All** chip.
List<SubcategoryEntity> prioritizeRedWineAfterAll(
  List<SubcategoryEntity> subcategories,
) {
  return _moveAfterAnchor(
    subcategories: subcategories,
    isTarget: _isRedWine,
    isAnchor: _isAllChip,
  );
}

/// Ensures **Whiskey** is immediately after the **Gin** chip.
List<SubcategoryEntity> prioritizeWhiskeyAfterGin(
  List<SubcategoryEntity> subcategories,
) {
  return _moveAfterAnchor(
    subcategories: subcategories,
    isTarget: _isWhiskey,
    isAnchor: _isGin,
  );
}

/// Presentation chip order used by category product screens.
List<SubcategoryEntity> applySubcategoryChipOrder(
  List<SubcategoryEntity> subcategories,
) {
  return prioritizeWhiskeyAfterGin(
    prioritizeRedWineAfterAll(subcategories),
  );
}
