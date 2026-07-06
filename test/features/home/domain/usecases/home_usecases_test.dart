import 'package:cava_ecommerce/features/home/domain/usecases/get_home_sections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockHomeRepository repository;

  setUp(() {
    repository = MockHomeRepository();
  });

  test('GetHomeSectionsUseCase returns sections', () async {
    when(() => repository.getSections())
        .thenAnswer((_) async => [testHomeSectionEntity]);

    final result = await GetHomeSectionsUseCase(repository)();
    expect(result.dataOrNull, hasLength(1));
  });
}
