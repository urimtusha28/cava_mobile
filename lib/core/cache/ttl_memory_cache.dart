/// TTL-backed in-memory cache for Firestore datasource reads.
class TtlCacheEntry<T> {
  TtlCacheEntry(this.value) : cachedAt = DateTime.now();

  final T value;
  final DateTime cachedAt;

  bool isValid(Duration ttl) => DateTime.now().difference(cachedAt) < ttl;
}

/// Single-value in-memory cache with expiry.
class TtlMemoryCache<T> {
  TtlMemoryCache({this.ttl = const Duration(minutes: 5)});

  final Duration ttl;
  TtlCacheEntry<T>? _entry;

  T? get valueIfValid {
    final entry = _entry;
    if (entry != null && entry.isValid(ttl)) {
      return entry.value;
    }
    return null;
  }

  void put(T value) {
    _entry = TtlCacheEntry(value);
  }

  void clear() {
    _entry = null;
  }
}

/// Keyed in-memory cache with expiry per entry.
class TtlMemoryMapCache<T> {
  TtlMemoryMapCache({this.ttl = const Duration(minutes: 5)});

  final Duration ttl;
  final Map<String, TtlCacheEntry<T>> _entries = {};

  T? get(String key) {
    final entry = _entries[key];
    if (entry != null && entry.isValid(ttl)) {
      return entry.value;
    }
    _entries.remove(key);
    return null;
  }

  void put(String key, T value) {
    _entries[key] = TtlCacheEntry(value);
  }

  void clear() {
    _entries.clear();
  }
}
