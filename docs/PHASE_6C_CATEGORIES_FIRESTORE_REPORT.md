# Phase 6C — Categories Firestore DataSource Report

**Projekti:** Cava Premium (`cava_ecommerce`)  
**Data:** 7 korrik 2026  
**Scope:** Categories data layer — Firestore `categories` collection (web sales schema)  
**Kufizime:** Pa UI/routing/layout, pa Cart/Wishlist/Auth/Checkout, pa web app, pa ndryshime në Firebase production data

---

## Përmbledhje

Mobile app tani lexon kategoritë nga Firestore collection `categories`, duke përdorur të njëjtën schema si web backend. Produktet dhe kategoritë vijnë nga i njëjti Firebase project (`cavapremium-31036`). UI mbeti **identik** — ndryshimet janë vetëm në data layer, DI, dhe product-category matching.

```bash
flutter analyze  → No issues found!
flutter test     → All tests passed! (128 tests)
flutter run      → ✅ iPhone 16 Pro simulator — app launched (pa crash)
```

---

## 1. Çfarë u implementua

| Komponent | Përshkrim |
|-----------|-----------|
| `CategoryDataSource` | Interface **async** — të gjitha metodat kthejnë `Future` |
| `CategoryFirestoreDataSource` | Lexon `categories`, filtron `isActive`, ndan main/sub, rendit sipas `order`, skip malformed docs |
| `CategoryModel` | Përshtatur me web schema + backward-compatible me legacy mock JSON |
| `CategoryMapper` | Mapon në `CategoryEntity` ekzistuese — `id` = slug për routing, `label` = name |
| `CategoryProductsController` | Produktet filtrohen me `category.name` (web: `product.category == category.name`) |
| `ProductFirestoreDataSource` | Përmirësim i matching: emër i saktë, case-insensitive, slug fallback |
| `FirebaseConfig` | `useFirestoreCategories = true`, `fallbackToMockCategoriesOnError = false` |
| DI | `_createCategoryDataSource()` — Firestore kur flags aktiv, mock përndryshe |
| Tests | Model, mapper, Firestore datasource, repository, controller, DI flags |

---

## 2. Skedarët e ndryshuar / shtuar

### Lib (production)

| Skedar | Ndryshim |
|--------|----------|
| `lib/core/firebase/firebase_config.dart` | `useFirestoreCategories`, `fallbackToMockCategoriesOnError` |
| `lib/core/di/injection.dart` | `_createCategoryDataSource()` |
| `lib/features/categories/data/datasources/category_data_source.dart` | Async interface |
| `lib/features/categories/data/datasources/category_mock_datasource.dart` | Async wrappers |
| `lib/features/categories/data/datasources/category_firestore_datasource.dart` | Implementim i plotë Firestore |
| `lib/features/categories/data/models/category_model.dart` | Web schema fields + legacy detection |
| `lib/features/categories/data/mappers/category_mapper.dart` | Slug → entity id, name → label |
| `lib/features/categories/data/repositories/category_repository_impl.dart` | Async datasource calls |
| `lib/features/categories/data/utils/category_collection_utils.dart` | **I ri** — sort + resolve parent doc id |
| `lib/features/categories/presentation/controllers/category_products_controller.dart` | Product query me `category.name` |
| `lib/features/products/data/datasources/product_firestore_datasource.dart` | Category name/slug matching i përmirësuar |

### Test

| Skedar | Ndryshim |
|--------|----------|
| `test/helpers/fixtures.dart` | `testWebCategoryJson`, subcategory, inactive samples |
| `test/helpers/test_di.dart` | `CategoryMockDataSource` override |
| `test/core/di/injection_test.dart` | Flags + mock override assertions |
| `test/features/categories/data/models/category_model_test.dart` | Web schema tests |
| `test/features/categories/data/mappers/category_mapper_test.dart` | Web slug routing test |
| `test/features/categories/data/datasources/category_firestore_datasource_test.dart` | **I ri** — fake_cloud_firestore |
| `test/features/categories/data/repositories/category_repository_impl_test.dart` | Async mock datasource |
| `test/features/categories/presentation/controllers/category_products_controller_test.dart` | `getProductsByCategory('Wines')` |

---

## 3. Web Firebase `categories` schema

**Collection:** `categories`

| Fushë | Tipi | Përshkrim |
|-------|------|-----------|
| `name` | string | Emri i shfaqur + lidhja me produkte (`product.category`) |
| `slug` | string | Route key mobile (`/category/:slug`) |
| `parentId` | string \| null | Document id i kategorisë prind |
| `type` | `"main"` \| `"sub"` | Lloji i kategorisë |
| `order` | number | Renditja në UI |
| `isActive` | boolean | Vetëm active shfaqen |
| `badgeColor` | string | Ngjyra badge (ruhet në model, UI nuk u prek) |
| `createdAt` | timestamp | Metadata |
| `updatedAt` | timestamp | Metadata |

### Rregullat e filtrimit

| Lloj | Kusht |
|------|-------|
| **Main** | `type == "main"` && `parentId == null` |
| **Sub** | `type == "sub"` && `parentId == categoryDocumentId` |
| **Active** | `isActive != false` |
| **Sort** | Sipas `order` — mungesë/0 shkon në fund |

---

## 4. Mapping — Model → Entity

```
Firestore doc id  →  CategoryModel.id
slug              →  CategoryEntity.id   (routing: /category/wines)
name              →  CategoryEntity.name + CategoryEntity.label (kur nuk ka legacy label)
label (mock)      →  CategoryEntity.label (legacy mock only)
emoji (mock)      →  CategoryEntity.emoji
```

**Subcategory mapping:**

```
slug (ose doc id) →  SubcategoryEntity.id
name              →  SubcategoryEntity.label
[name]            →  SubcategoryEntity.matchTypes  (filtron product.type / subCategory)
```

Chip **"All"** shtohet automatikisht si në mock (`id: 'all'`).

---

## 5. Parent / subcategory flow

```
getAllCategories()
  └─ load active docs
  └─ filter type=main && parentId=null
  └─ sort by order

getSubcategories(categoryId)   // categoryId = route slug (p.sh. "wines")
  └─ resolve slug → document id (resolveCategoryDocumentId)
  └─ filter type=sub && parentId == parentDocId
  └─ sort by order
  └─ prepend SubcategoryModel(id: 'all', label: 'All')
```

Route `/category/wines` funksionon me slug; lookup provon edhe document id.

---

## 6. Si lidhen produktet me kategoritë

**Web convention (burim kryesor):**

```
product.category == category.name
```

**Mobile flow (`CategoryProductsController`):**

1. `getCategoryById('wines')` → gjen kategori me slug
2. `getProductsByCategory(category.name)` → p.sh. `"Wines"` (jo slug, jo legacy `categoryId`)
3. `getSubcategories('wines')` → chips për filtrim lokal me `product.type`

**`ProductFirestoreDataSource.getProductsByCategory`** matchon:

- Emër i saktë: `docCategory == category`
- Case-insensitive: `docCategory.toLowerCase() == category.toLowerCase()`
- Slug fallback: `ProductModel.categorySlug(docCategory) == ProductModel.categorySlug(category)`

> Legacy `categoryId` në produkt **nuk** përdoret si burim kryesor.

---

## 7. DI & flags

```dart
// lib/core/firebase/firebase_config.dart
static const bool enabled = true;
static const bool useFirestoreCategories = true;
static const bool fallbackToMockCategoriesOnError = false;

// lib/core/di/injection.dart
CategoryDataSource _createCategoryDataSource() {
  if (FirebaseConfig.enabled && FirebaseConfig.useFirestoreCategories) {
    return CategoryFirestoreDataSource(FirebaseFirestore.instance);
  }
  return const CategoryMockDataSource();
}
```

| Kusht | DataSource |
|-------|------------|
| `enabled && useFirestoreCategories` | `CategoryFirestoreDataSource` |
| ndryshe | `CategoryMockDataSource` |
| Firestore error + `fallbackToMockCategoriesOnError == false` | Listë bosh / null (pa crash) |
| Firestore error + `fallbackToMockCategoriesOnError == true` | Mock fallback |

Testet përdorin `configureTestDependencies(categoryDataSource: CategoryMockDataSource())`.

---

## 8. Fallback & stabilitet

- Dokument malformed → skip + debug log, pa crash
- Firestore error / collection bosh → `[]` ose `null`
- **Nuk** kthehet mock automatikisht (`fallbackToMockCategoriesOnError = false`)
- UI mbetet stabile me listë bosh

---

## 9. Runtime — Firestore categories

**Simulator:** iPhone 16 Pro  
**Project:** `cavapremium-31036`

```
flutter: CategoryFirestoreDataSource: getAllCategories failed —
  [cloud_firestore/permission-denied] The caller does not have permission
  to execute the specified operation.
```

| Metrikë | Vlerë |
|---------|-------|
| Main categories të mapuara | **0** (permission-denied) |
| App crash | **Jo** |
| Produktet (Phase 6A/6B) | Ende funksionale — 379 active (nga raporti i mëparshëm) |

> **Shënim:** Mobile client ka qasje në `products` por jo në `categories` sipas Firestore Security Rules aktuale. Kjo kërkon përditësim rules në backend (jashtë scope të Phase 6C — nuk u prek production data/rules). Pas hapjes së rules, logu pritet:
> `CategoryFirestoreDataSource: mapped N main categories`

---

## 10. UI identik?

**Po.**

- Asnjë ndryshim në widget, layout, routing, bottom navigation
- `CategoryEntity` fields të pandryshuara për UI (`id`, `name`, `label`, `emoji`)
- Home category chips, Categories screen, CategoryProducts screen — i njëjti kod presentation
- Me Firestore bosh (permission-denied), chips/lista shfaqen bosh — pa crash, pa ndryshim vizual të strukturës

---

## 11. Çfarë mbetet mock

| Modul | Burimi |
|-------|--------|
| Home sections / CMS | `HomeMockDataSource` |
| Banners, hero, about, contact | Nuk janë integruar |
| Cart | Mock/local |
| Wishlist | Mock/local |
| Auth | Mock |
| Checkout | Mock |
| Categories (kur flag false ose test override) | `CategoryMockDataSource` |

---

## 12. Teste të shtuara / përditësuara

| Test | Coverage |
|------|----------|
| `category_model_test.dart` | Legacy + web `fromJson` |
| `category_mapper_test.dart` | Slug routing, label fallback |
| `category_firestore_datasource_test.dart` | Active filter, main only, sub by parentId, order sort, malformed skip |
| `category_repository_impl_test.dart` | Async datasource |
| `category_products_controller_test.dart` | `getProductsByCategory('Wines')` |
| `injection_test.dart` | Flags + `CategoryMockDataSource` në test DI |

```bash
flutter test
# 00:14 +128: All tests passed!
```

---

## 13. Rezultatet e verifikimit

| Komanda | Rezultati |
|---------|-----------|
| `flutter analyze` | ✅ No issues found! |
| `flutter test` | ✅ 128 tests passed |
| `flutter run` (iOS simulator) | ✅ App launched, pa crash |

---

## 14. Rreziqe të mbetura

| Risk | Ndikimi | Veprim i rekomanduar |
|------|---------|---------------------|
| **Firestore rules — `categories` permission-denied** | Kategori bosh në app live | Hap read access për `categories` (si `products`) në Security Rules |
| **Mismatch emër kategorie** | Produktet nuk shfaqen për kategori | Sigurohu `product.category` == `category.name` në web admin |
| **Subcategory filtering** | `matchTypes` = `[name]` — varet nga `product.subCategory` | Verifiko emrat sub në web |
| **Emoji/badgeColor** | Web nuk i ka — chips shfaqin name, jo emoji | OK për UI aktual; emoji vetëm në mock legacy |
| **Collection fetch client-side** | Pa composite index — OK për madhësi të vogël | Optimizim me query Firestore në fazë të ardhshme |

---

## 15. Qëllimi final — status

| Qëllim | Status |
|--------|--------|
| Products nga Firebase backend i web-it | ✅ (Phase 6A/6B) |
| Categories nga i njëjti backend | ✅ Implementuar — ⚠️ blocked by Firestore rules në runtime |
| UI identik | ✅ |
| Vetëm sales data, jo web CMS | ✅ |
| Pa prekje Cart/Wishlist/Auth/Checkout/Home CMS | ✅ |

**Phase 6C u përfundua në data layer.** Hapi tjetër operacional (jashtë kodit mobile): përditësimi i Firestore Security Rules për të lejuar leximin e collection `categories` nga klienti anonim/authenticated — pa ndryshuar të dhënat.
