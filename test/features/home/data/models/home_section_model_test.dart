import 'package:cava_ecommerce/features/home/data/models/home_section_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('HomeSectionModel', () {
    test('fromJson and toJson round-trip', () {
      final model = HomeSectionModel.fromJson(testHomeSectionJson);
      expect(model.toJson(), testHomeSectionJson);
    });

    test('fromJson parses bestSellers type', () {
      final json = Map<String, dynamic>.from(testHomeSectionJson)
        ..['type'] = 'best_sellers';
      final model = HomeSectionModel.fromJson(json);
      expect(model.type, HomeSectionTypeModel.bestSellers);
    });
  });
}
