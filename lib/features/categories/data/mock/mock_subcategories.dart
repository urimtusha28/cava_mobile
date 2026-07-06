import '../../domain/entities/subcategory_entity.dart';

abstract final class MockSubcategories {
  static const List<SubcategoryEntity> wines = [
    SubcategoryEntity(id: 'all', label: 'All Wines'),
    SubcategoryEntity(
      id: 'red',
      label: 'Red Wine',
      matchTypes: ['Merlot', 'Baco Noir', 'Cabernet', 'Pinot Noir'],
    ),
    SubcategoryEntity(
      id: 'white',
      label: 'White Wine',
      matchTypes: ['Chardonnay', 'Sauvignon Blanc', 'Pinot Grigio', 'Riesling'],
    ),
    SubcategoryEntity(id: 'sparkling', label: 'Sparkling', matchTypes: ['Sparkling']),
    SubcategoryEntity(
      id: 'champagne',
      label: 'Champagne',
      matchTypes: ['Sparkling', 'Brut'],
      matchKeywords: ['champagne', 'brut'],
    ),
    SubcategoryEntity(
      id: 'prosecco',
      label: 'Prosecco',
      matchTypes: ['Prosecco'],
      matchKeywords: ['prosecco'],
    ),
  ];

  static const List<SubcategoryEntity> spirits = [
    SubcategoryEntity(id: 'all', label: 'All Spirits'),
    SubcategoryEntity(
      id: 'whiskey',
      label: 'Whiskey',
      matchTypes: ['Whiskey'],
      matchKeywords: ['whiskey', 'whisky', 'scotch', 'bourbon'],
    ),
    SubcategoryEntity(
      id: 'vodka',
      label: 'Vodka',
      matchTypes: ['Vodka'],
      matchKeywords: ['vodka'],
    ),
    SubcategoryEntity(
      id: 'gin',
      label: 'Gin',
      matchTypes: ['Gin'],
      matchKeywords: ['gin'],
    ),
    SubcategoryEntity(
      id: 'rum',
      label: 'Rum',
      matchTypes: ['Rum'],
      matchKeywords: ['rum'],
    ),
    SubcategoryEntity(
      id: 'tequila',
      label: 'Tequila',
      matchTypes: ['Tequila'],
      matchKeywords: ['tequila', 'mezcal'],
    ),
    SubcategoryEntity(
      id: 'brandy',
      label: 'Brandy',
      matchTypes: ['Brandy'],
      matchKeywords: ['brandy'],
    ),
    SubcategoryEntity(
      id: 'cognac',
      label: 'Cognac',
      matchTypes: ['Cognac'],
      matchKeywords: ['cognac'],
    ),
    SubcategoryEntity(
      id: 'grappa',
      label: 'Grappa',
      matchTypes: ['Grappa'],
      matchKeywords: ['grappa'],
    ),
    SubcategoryEntity(
      id: 'rakia',
      label: 'Rakia',
      matchTypes: ['Rakia'],
      matchKeywords: ['rakia', 'rakija'],
    ),
  ];

  static const List<SubcategoryEntity> liqueurs = [
    SubcategoryEntity(id: 'all', label: 'All Liqueurs'),
    SubcategoryEntity(
      id: 'aperitivo',
      label: 'Aperitivo',
      matchTypes: ['Aperitivo'],
      matchKeywords: ['aperol', 'aperitivo', 'campari'],
    ),
    SubcategoryEntity(
      id: 'herbal_amaro',
      label: 'Herbal/Amaro',
      matchTypes: ['Herbal', 'Amaro'],
      matchKeywords: ['amaro', 'herbal', 'jägermeister'],
    ),
    SubcategoryEntity(
      id: 'anise',
      label: 'Anise',
      matchTypes: ['Anise'],
      matchKeywords: ['anise', 'ouzo', 'sambuca', 'pastis'],
    ),
    SubcategoryEntity(
      id: 'nut_almond',
      label: 'Nut/Almond',
      matchTypes: ['Nut', 'Almond'],
      matchKeywords: ['almond', 'amaretto', 'frangelico', 'nut'],
    ),
    SubcategoryEntity(
      id: 'citrus_fruit',
      label: 'Citrus / Fruit',
      matchTypes: ['Citrus', 'Fruit'],
      matchKeywords: ['citrus', 'fruit', 'limoncello', 'orange'],
    ),
    SubcategoryEntity(
      id: 'cream',
      label: 'Cream',
      matchTypes: ['Cream'],
      matchKeywords: ['cream', 'baileys', 'irish cream'],
    ),
    SubcategoryEntity(
      id: 'coconut_tropical',
      label: 'Coconut / Tropical',
      matchTypes: ['Coconut', 'Tropical'],
      matchKeywords: ['coconut', 'tropical', 'malibu', 'piña'],
    ),
    SubcategoryEntity(
      id: 'coffee',
      label: 'Coffee',
      matchTypes: ['Coffee'],
      matchKeywords: ['coffee', 'kahlua', 'caffè'],
    ),
  ];

  static const List<SubcategoryEntity> tobacco = [
    SubcategoryEntity(id: 'all', label: 'All Tobacco'),
  ];

  static const List<SubcategoryEntity> accessories = [
    SubcategoryEntity(id: 'all', label: 'All Accessories'),
  ];

  static List<SubcategoryEntity> forCategory(String categoryId) {
    return switch (categoryId) {
      'wines' => wines,
      'spirits' => spirits,
      'liqueurs' => liqueurs,
      'tobacco' => tobacco,
      'accessories' => accessories,
      _ => const [SubcategoryEntity(id: 'all', label: 'All')],
    };
  }
}
