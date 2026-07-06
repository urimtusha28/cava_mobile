# Phase 6B — Mobile Product Sales Schema Alignment Report

**Projekti:** Cava Premium (`cava_ecommerce`)  
**Data:** 7 korrik 2026  
**Scope:** Products data layer — web Firebase sales schema alignment  
**Kufizime:** Pa UI/routing/Home CMS, pa mock data changes, pa Cart/Wishlist/Checkout

---

## Përmbledhje

Mobile app tani lexon **vetëm sales schema** nga web Firebase `products` — jo CMS/homepage/about/contact/hero. `ProductModel`, `ProductMapper`, dhe `ProductFirestoreDataSource` u përshtatën me fushat reale të web backend. UI mbeti **identik** (placeholder icons — `imageUrl`/`detailImageUrl` janë gati për network images pa ndryshuar layout).

```bash
flutter analyze
# → No issues found!

flutter test
# → All tests passed! (117 tests)
```

---

## 1. Web Firebase `products` schema — fusha të mbështetura

| Fushë web | Përdorimi mobile |
|-----------|------------------|
| `id` | Product id |
| `name` | Emri |
| `description` | Përshkrimi |
| `price` | Çmimi |
| `originalPrice` | → `oldPrice` (entity) |
| `stock` | → `inStock` (stock > 0) |
| `status` | Ruhet në model (metadata) |
| `productStatus` | Filtrim active/draft/hidden |
| `category` | → `categoryName` + slug për `categoryId` |
| `subCategory` | → `type` |
| `imageUrl` | Fallback image |
| `images.thumb` | → `imageUrl` (card) |
| `images.medium` | → `detailImageUrl` |
| `images.original` | Fallback detail image |
| `brandProducer` | → `brand` |
| `origin` | → `country` |
| `originCode` | Ruhet në model |
| `details.abv` | → `alcoholPercentage` |
| `details.volume` | → `volume` |
| `details.region` | Ruhet në model |
| `details.vintageYear` | Ruhet në model |
| `topPick` | → `isFeatured` |

---

## 2. Fusha që NUK kërkohen (web CMS / marketing)

Nuk lexohen dhe nuk kërkohen:

- `variants`, `tags`, `categoryId`, `subcategoryId`, `discount`
- `banners`, `promotions`, `about`, `contact`, `hero` texts
- `settings/homepage` — **Home UI nuk u prek**

---

## 3. ProductMapper — field mapping

| Web | Mobile Entity |
|-----|---------------|
| `originalPrice` | `oldPrice` |
| `category` | `categoryName` (+ slug → `categoryId`) |
| `subCategory` | `type` |
| `brandProducer` | `brand` |
| `origin` | `country` |
| `details.abv` | `alcoholPercentage` |
| `details.volume` | `volume` |
| `topPick` | `isFeatured` |
| `images.thumb ?? imageUrl` | `imageUrl` |
| `images.medium ?? original ?? imageUrl` | `detailImageUrl` |
| `stock > 0` | `inStock` |

---

## 4. ProductFirestoreDataSource

| Metodë | Sjellja |
|--------|---------|
| `getAllProducts()` | Lexon `products`, filtron **active only** |
| `getProductById()` | Null për draft/hidden/missing |
| `getFeaturedProducts()` | `topPick == true` + active filter |
| `getProductsByCategory()` | Match `category` string ose slug (`wines` ↔ `Wines`) |

### Filtrim `productStatus`

| Status | Shfaqet? |
|--------|----------|
| `active` | ✅ |
| `null` / mungon | ✅ |
| `draft` | ❌ |
| `hidden` | ❌ |

---

## 5. Images (data layer — UI pa ndryshim)

| Kontekst | URL e zgjedhur | Entity field |
|----------|----------------|--------------|
| Product cards (lists) | `images.thumb ?? imageUrl` | `imageUrl` |
| Product detail | `images.medium ?? images.original ?? imageUrl` | `detailImageUrl` |
| Pa foto | `placeholderColor` ekzistues | UI icon placeholder (i njëjti) |

UI aktual ende përdor placeholder icons — **layout identik**. URL-të janë të disponueshme në entity për integrim të ardhshëm pa ndryshuar schema.

---

## 6. Home

- **Nuk** u lidh me `settings/homepage`
- **Nuk** merren about/contact/hero nga web
- Home sections ekzistuese (`HomeRepository` → `ProductRepository`) vazhdojnë të marrin produkte nga `products` kur Firestore aktivizohet
- **Home UI — zero ndryshime**

---

## 7. Mock fallback — i paprekur

- `MockProducts` — pa ndryshim
- `ProductMockDataSource` — async, legacy schema
- `ProductModel.fromJson` — detekton web vs legacy (`categoryId` = legacy marker)
- DI default: `ProductMockDataSource`

---

## 8. Skedarët e ndryshuar

| Skedar | Ndryshimi |
|--------|-----------|
| `lib/features/products/data/models/product_model.dart` | Web schema + `ProductImagesModel` + `ProductDetailsModel` |
| `lib/features/products/data/mappers/product_mapper.dart` | Web → entity mapping |
| `lib/features/products/data/datasources/product_firestore_datasource.dart` | Active filter, topPick, category string |
| `lib/features/products/domain/entities/product_entity.dart` | Shtuar `detailImageUrl` (optional, UI pa ndryshim) |
| `test/helpers/fixtures.dart` | `testWebProductJson`, draft/hidden samples |
| `test/features/products/data/models/product_model_test.dart` | Web + legacy tests |
| `test/features/products/data/mappers/product_mapper_test.dart` | Web mapping test |
| `test/features/products/data/datasources/product_firestore_datasource_test.dart` | Web schema + filter tests |

---

## 9. Teste të reja / përditësuara

| Test | Verifikon |
|------|-----------|
| Web `fromJson` | Të gjitha fushat + nested images/details |
| `cardImageUrl` / `detailImageUrl` | Thumb/medium priority |
| `isActiveProductStatus` | active/null vs draft/hidden |
| Mapper web → entity | originalPrice, category, topPick, images |
| Firestore getAll | Excludes draft/hidden |
| Firestore getById | Null për draft |
| Firestore getFeatured | `topPick == true` |
| Firestore getByCategory | `category` string + slug match |
| Legacy mock JSON | Backward compat |

**Total:** 117 tests — all passed

---

## 10. Rezultatet

```bash
$ flutter analyze
No issues found! (ran in 2.7s)

$ flutter test
All tests passed! (117 tests)
```

---

## 11. Çfarë NUK u prek

| Zona | Status |
|------|--------|
| UI / layout / routing | ✅ Identik |
| Home UI / CMS | ✅ Pa lidhje |
| Cart / Wishlist / Auth / Checkout | ✅ Pa ndryshim |
| Mock data content | ✅ Pa ndryshim |
| Categories Firestore | ⏳ Phase 6C+ |
| Firebase activation | ⏳ Flags ende `false` |

---

## 12. Hapat e ardhshëm

1. Seed Firestore `products` me web schema (active + topPick)
2. Aktivizo `FirebaseConfig.enabled` + `useFirestoreProducts`
3. Phase 6C: Categories schema alignment
4. Optional: wire `CachedNetworkImage` në cards/detail kur lejohet ndryshim UI

---

*Phase 6B complete. Mobile përdor vetëm sales backend — jo web CMS. UI identik.*
