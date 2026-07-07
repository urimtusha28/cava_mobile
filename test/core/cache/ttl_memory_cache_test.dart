import 'package:cava_ecommerce/core/cache/ttl_memory_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TtlMemoryCache', () {
    test('returns value while within TTL', () {
      final cache = TtlMemoryCache<String>(ttl: const Duration(minutes: 5));
      cache.put('cached');
      expect(cache.valueIfValid, 'cached');
    });

    test('returns null after TTL expires', () {
      final cache = TtlMemoryCache<String>(
        ttl: const Duration(milliseconds: 1),
      );
      cache.put('cached');
      expect(cache.valueIfValid, 'cached');
      expect(
        Future<void>.delayed(const Duration(milliseconds: 5)),
        completes,
      );
    });

    test('clear removes cached value', () {
      final cache = TtlMemoryCache<int>();
      cache.put(42);
      cache.clear();
      expect(cache.valueIfValid, isNull);
    });
  });

  group('TtlMemoryMapCache', () {
    test('stores and retrieves keyed values', () {
      final cache = TtlMemoryMapCache<List<int>>();
      cache.put('a', [1, 2]);
      expect(cache.get('a'), [1, 2]);
      expect(cache.get('missing'), isNull);
    });

    test('clear removes all entries', () {
      final cache = TtlMemoryMapCache<String>();
      cache.put('x', 'value');
      cache.clear();
      expect(cache.get('x'), isNull);
    });
  });
}
