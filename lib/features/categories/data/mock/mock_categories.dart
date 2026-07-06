import '../../domain/entities/category_entity.dart';

abstract final class MockCategories {
  static const List<CategoryEntity> categories = [
    CategoryEntity(id: 'wines', name: 'Verëra', label: 'Wines', emoji: '🍷'),
    CategoryEntity(id: 'spirits', name: 'Spirits', label: 'Spirits', emoji: '🥃'),
    CategoryEntity(id: 'liqueurs', name: 'Liqueurs', label: 'Liqueurs', emoji: '🍸'),
    CategoryEntity(id: 'tobacco', name: 'Tobacco', label: 'Tobacco', emoji: '🚬'),
    CategoryEntity(
      id: 'accessories',
      name: 'Aksesorë',
      label: 'Accessories',
      emoji: '🎁',
    ),
  ];
}
