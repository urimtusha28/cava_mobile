import 'package:cava_ecommerce/features/categories/domain/entities/subcategory_entity.dart';
import 'package:cava_ecommerce/features/categories/domain/utils/subcategory_chip_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const all = SubcategoryEntity(id: 'all', label: 'All');
  const white = SubcategoryEntity(id: 'white', label: 'White Wine');
  const rose = SubcategoryEntity(id: 'rose', label: 'Rosé Wine');
  const red = SubcategoryEntity(id: 'red', label: 'Red Wine');
  const sparkling = SubcategoryEntity(id: 'sparkling', label: 'Sparkling');

  const vodka = SubcategoryEntity(id: 'vodka', label: 'Vodka');
  const gin = SubcategoryEntity(id: 'gin', label: 'Gin');
  const rum = SubcategoryEntity(id: 'rum', label: 'Rum');
  const tequila = SubcategoryEntity(id: 'tequila', label: 'Tequila');
  const whiskey = SubcategoryEntity(id: 'whiskey', label: 'Whiskey');

  test('moves Red Wine to second position after All', () {
    final ordered = prioritizeRedWineAfterAll([
      all,
      white,
      rose,
      red,
      sparkling,
    ]);
    expect(
      ordered.map((s) => s.label).toList(),
      ['All', 'Red Wine', 'White Wine', 'Rosé Wine', 'Sparkling'],
    );
  });

  test('keeps order when Red Wine is already second', () {
    final input = [all, red, white, rose];
    expect(
      prioritizeRedWineAfterAll(input).map((s) => s.id).toList(),
      ['all', 'red', 'white', 'rose'],
    );
  });

  test('returns input when Red Wine is missing', () {
    final input = [all, white, rose];
    expect(prioritizeRedWineAfterAll(input), input);
  });

  test('moves Whiskey immediately after Gin', () {
    final ordered = prioritizeWhiskeyAfterGin([
      all,
      vodka,
      gin,
      rum,
      tequila,
      whiskey,
    ]);
    expect(
      ordered.map((s) => s.label).toList(),
      ['All', 'Vodka', 'Gin', 'Whiskey', 'Rum', 'Tequila'],
    );
  });

  test('keeps order when Whiskey is already after Gin', () {
    final input = [all, vodka, gin, whiskey, rum];
    expect(
      prioritizeWhiskeyAfterGin(input).map((s) => s.id).toList(),
      ['all', 'vodka', 'gin', 'whiskey', 'rum'],
    );
  });

  test('returns input when Whiskey is missing', () {
    final input = [all, vodka, gin, rum];
    expect(prioritizeWhiskeyAfterGin(input), input);
  });

  test('applySubcategoryChipOrder applies both wine and spirits rules', () {
    final ordered = applySubcategoryChipOrder([
      all,
      white,
      red,
      vodka,
      gin,
      rum,
      whiskey,
    ]);
    expect(
      ordered.map((s) => s.id).toList(),
      ['all', 'red', 'white', 'vodka', 'gin', 'whiskey', 'rum'],
    );
  });
}
