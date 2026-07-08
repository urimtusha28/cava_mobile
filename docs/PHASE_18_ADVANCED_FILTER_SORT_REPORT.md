# Phase 18 — Advanced Product Filter & Sort

**Data:** 8 korrik 2026  
**Qëllimi:** Filtrim dhe sortim client-side i produkteve reale në CategoryProductsScreen dhe SearchScreen, pa Firestore reads shtesë dhe pa ndryshuar UI bazë.

---

## Si funksionon filter state

`ProductFilterState` mban:

| Fusha | Tipi | Përshkrim |
|-------|------|-----------|
| `minPrice` / `maxPrice` | `double?` | Interval çmimi |
| `brands` | `Set<String>` | Markat e zgjedhura |
| `countries` | `Set<String>` | Origjina |
| `categories` | `Set<String>` | `categoryName` |
| `subcategories` | `Set<String>` | `type` (nënkategori) |
| `volumes` | `Set<String>` | Volumi |
| `inStockOnly` | `bool` | Vetëm në stok |
| `sortOption` | `ProductSortOption` | Renditja |

`isActive` / `activeCount` përdoren për badge në butonin e filtrit.  
`reset()` / `ProductFilterState.empty` pastrojnë gjithçka.

**Skedar:** `lib/features/products/domain/filtering/product_filter_state.dart`

---

## Si funksionon sort

`ProductSortOption`:

- `recommended` — featured + rating
- `nameAsc` / `nameDesc` — A–Z / Z–A
- `priceAsc` / `priceDesc` — çmim ulët / lartë
- `newest` — proxy me `id` (nuk ka `createdAt` në `ProductEntity`)
- `bestSellers` — `reviewCount` desc

`ProductFilterEngine.apply` filtrohet fillimisht, pastaj sortohet in-place.

---

## Fushat e ProductEntity që përdoren

| Filter | Fusha |
|--------|-------|
| Çmim | `price` |
| Markë | `brand` |
| Origjinë | `country` |
| Kategori | `categoryName` |
| Nënkategori | `type` |
| Volum | `volume` |
| Stok | `inStock` |
| Sort recommended | `isFeatured`, `rating` |
| Sort best sellers | `reviewCount` |

Opsionet e facet-ëve (`ProductFilterOptions.fromProducts`) nxirren **dinamikisht** nga lista e produkteve të ngarkuara — pa hardcoded values.

---

## Pse nuk rrit Firestore reads

1. Produktet lexohen një herë nga cache ekzistuese (`getAll` / category load).
2. `ProductFilterEngine` punon **vetëm** mbi `List<ProductEntity>` në memory.
3. Hapja e bottom sheet-it nuk bën network call — vetëm ndërtim UI nga produktet e ngarkuara.
4. Search: filter aplikohet mbi `_rawResults` (rezultatet e query-t), jo mbi gjithë katalogun dhe jo me Firestore query.

---

## Ku u shtua filter UI

### CategoryProductsScreen
- Ikona `tune` pranë search bar (`ProductFilterButton` + badge me `activeCount`)
- Bottom sheet: rounded 28, SafeArea, scrollable, seksione shqip, Pastro / Apliko
- Empty state: “Nuk u gjet asnjë produkt me këto filtra.” + “Pastro filtrat”

### SearchScreen
- I njëjti buton në AppBar `actions` kur query ≥ 2 karaktere
- Filter mbi `rawSearchResults` vetëm
- `SearchController.applyFilter` / `clearFilter`

### Widgets të rinj
- `lib/core/widgets/product_filter_bottom_sheet.dart`
- `lib/core/widgets/product_filter_button.dart`

### Domain
- `product_filter_state.dart`
- `product_sort_option.dart`
- `product_filter_options.dart`
- `product_filter_engine.dart`

**E paprekur:** layout bazë i grid-it, Home, Cart, Wishlist, Checkout, Auth, Orders, Firebase schema, backend/web.

---

## Testet

| Skedar | Mbulimi |
|--------|---------|
| `product_filter_engine_test.dart` | price/brand/country/category/subcategory/volume/inStock, sort name/price, reset, options from products, activeCount |
| `search_filter_test.dart` | filter vetëm mbi search results, clear filter |

---

## Rezultatet

### flutter analyze
```
2 info (cart_firestore_datasource avoid_types_as_parameter_names — ekzistues)
0 errors, 0 warnings
```

### flutter test
```
All tests passed! (328 tests)
```

---

## Rezultati final

Përdoruesi mund të filtrojë dhe sortojë produktet reale në katalog/kategori dhe në search, me bottom sheet premium, opsione të gjeneruara nga të dhënat aktuale, pa Firestore reads shtesë dhe pa ndryshuar dizajnin bazë të aplikacionit.
