import 'package:cava_ecommerce/features/categories/domain/entities/category_entity.dart';
import 'package:cava_ecommerce/features/home/presentation/utils/home_category_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const spirits = CategoryEntity(
    id: 'spirits',
    name: 'Spirits',
    label: 'Spirits',
    emoji: '🥃',
  );
  const wines = CategoryEntity(
    id: 'wines',
    name: 'Wines',
    label: 'Wines',
    emoji: '🍷',
  );
  const liqueurs = CategoryEntity(
    id: 'liqueurs',
    name: 'Liqueurs',
    label: 'Liqueurs',
    emoji: '🍸',
  );

  test('moves wines to first position', () {
    final ordered = prioritizeWinesForHome([spirits, wines, liqueurs]);
    expect(ordered.map((c) => c.id).toList(), ['wines', 'spirits', 'liqueurs']);
  });

  test('keeps order when wines is already first', () {
    final input = [wines, spirits, liqueurs];
    expect(
      prioritizeWinesForHome(input).map((c) => c.id).toList(),
      ['wines', 'spirits', 'liqueurs'],
    );
  });

  test('returns input when wines is missing', () {
    final input = [spirits, liqueurs];
    expect(prioritizeWinesForHome(input), [spirits, liqueurs]);
  });
}
