# Firestore Read Cache Optimization Report

**Projekti:** Cava Premium (`cava_ecommerce`)  
**Data:** 7 korrik 2026  
**Scope:** In-memory TTL cache për leximet Firestore products + categories  
**Kufizime:** Pa UI, schema, backend, web

---

## Përmbledhje

U shtua cache në memorie me **TTL 5 minuta** në `ProductFirestoreDataSource` dhe `CategoryFirestoreDataSource`. Kthimi në Home brenda TTL-së nuk bën përsëri collection read të plotë (379 docs) nëse `allProducts` është ende valid.

```bash
flutter analyze  → No issues found!
flutter test     → All tests passed! (143 tests)
```

---

## 1. Problemi

Çdo hapje Home shkaktonte lexime të përsëritura:

```
ProductFirestoreDataSource: mapped 379 active products
ProductFirestoreDataSource: mapped 111 active products
ProductFirestoreDataSource: mapped 23 active products
...
```

`HomeRepositoryImpl` thërret veçmas: recommended (featured), bestSellers (all), offers (all) → shumë query të panevojshme.

---

## 2. Zgjidhja

### Utility

`lib/core/cache/ttl_memory_cache.dart`

| Klasë | Përdorimi |
|-------|-----------|
| `TtlMemoryCache<T>` | Një vlerë (all products, all categories raw, featured) |
| `TtlMemoryMapCache<T>` | Keyed (productsByCategory, subcategories) |

TTL: `FirebaseConfig.firestoreCacheTtl` = **5 minuta**

### Products — `ProductFirestoreDataSource`

| Cache | Përmbajtja |
|-------|------------|
| `_allProductsCache` | Të gjithë produktet active |
| `_featuredProductsCache` | Rezultati i query `topPick` (kur nuk ka all cache) |
| `_productsByCategoryCache` | Lista e filtruar për category key |

**Strategji:**

1. `getAllProducts()` → cache hit ose `_collection.get()` një herë
2. `getFeaturedProducts()` → nëse all cache valid → **filter client-side** `topPick` (0 reads)
3. `getProductsByCategory()` → nëse all cache valid → **filter client-side** (0 reads)
4. `getProductById()` → kërkon në all cache para doc read
5. `getBestSellers()` / `getOffers()` (repository) → përdorin `getAllProducts()` → **cache hit** pas load-it të parë

**API publike:**

```dart
void clearCache();
Future<void> refreshCache(); // clear + preload all
```

Debug log: `cache hit getAllProducts (379 items)`

### Categories — `CategoryFirestoreDataSource`

| Cache | Përmbajtja |
|-------|------------|
| `_allCategoriesCache` | Të gjitha kategoritë active (një query `isActive == true`) |
| `_subcategoriesCache` | Rezultati i llogaritur për categoryId |

`getAllCategories`, `getCategoryById`, `getSubcategories` → përdorin `_loadActiveCategories()` me cache.

**API:** `clearCache()`, `refreshCache()`

---

## 3. Skedarët e ndryshuar / shtuar

| Skedar | Ndryshim |
|--------|----------|
| `lib/core/cache/ttl_memory_cache.dart` | **I ri** |
| `lib/core/firebase/firebase_config.dart` | `firestoreCacheTtl` |
| `lib/features/products/data/datasources/product_firestore_datasource.dart` | Cache + derive |
| `lib/features/categories/data/datasources/category_firestore_datasource.dart` | Cache |
| `test/core/cache/ttl_memory_cache_test.dart` | **I ri** |
| `test/.../product_firestore_datasource_test.dart` | Cache tests |
| `test/.../category_firestore_datasource_test.dart` | Cache tests |

**Nuk u prek:** UI, `ProductModel`, `ProductMapper`, repository interfaces, web, backend.

---

## 4. Sjellja në Home (pas optimizimit)

### Vizita e parë (cache bosh)

| Thirrje | Firestore |
|---------|-----------|
| `getFeaturedProducts` | Query `topPick` **ose** fallback all |
| `getBestSellers` → `getAllProducts` | Collection `get` (379) |
| `getOffers` → `getAllProducts` | **Cache hit** (0 reads) |
| Categories | 1 query `isActive` |

### Kthim në Home brenda 5 min

| Thirrje | Firestore |
|---------|-----------|
| `getFeaturedProducts` | **Cache hit** (filter nga all) |
| `getAllProducts` | **Cache hit** |
| `getOffers` | **Cache hit** |
| Categories | **Cache hit** |

**Rezultat:** Pa 379 reads të përsëritura.

---

## 5. TTL dhe invalidim

- Pas **5 minuta** cache skadon automatikisht → lexim i ri nga Firestore
- `clearCache()` — manual (për pull-to-refresh të ardhshëm)
- `refreshCache()` — clear + preload

DI: `ProductFirestoreDataSource` dhe `CategoryFirestoreDataSource` janë **LazySingleton** → cache mbetet gjatë jetës së app-it.

---

## 6. Teste

| Test | Verifikon |
|------|-----------|
| `ttl_memory_cache_test` | TTL entry, clear |
| Product cache | Shtim doc pas load → count i njëjtë deri `clearCache()` |
| Product featured/category | Derivohen nga all cache |
| Category cache | Main categories cached deri `clearCache()` |

```bash
flutter test → 143 tests passed
```

---

## 7. Rreziqe / kufizime

| Risk | Mitigim |
|------|---------|
| Data stale deri 5 min | TTL + `refreshCache()` për të ardhmen |
| Vetëm in-memory | Cache humbet kur mbyllet app-i |
| Singleton ndër ekrane | E qëllimshme për reduktim reads |
| `getProductById` pa all cache | Ende 1 doc read (i pranueshëm) |

---

## 8. Konkluzion

Cache në datasource layer redukton ndjeshëm Firestore reads për Home dhe category flows, pa ndryshuar UI apo schema. Pas load-it të parë, kthimi në Home brenda 5 minutave përdor vetëm memorie.
