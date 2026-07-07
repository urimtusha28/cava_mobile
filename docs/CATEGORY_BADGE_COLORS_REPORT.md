# Phase 6E — Dynamic Category Badge Colors

## Qëllimi

Çdo kategori dhe nënkategori të përdorë `badgeColor` nga Firestore (`categories.badgeColor`), identike me web — pa ndryshuar layout, routing, schema, ose logjikë tjetër.

---

## Skedarët e ndryshuar

| Skedar | Ndryshim |
|--------|----------|
| `lib/features/categories/domain/entities/category_entity.dart` | Shtuar `badgeColor: String?` |
| `lib/features/categories/domain/entities/subcategory_entity.dart` | Shtuar `badgeColor: String?` |
| `lib/features/categories/data/models/category_model.dart` | `fromEntity` ruan `badgeColor` |
| `lib/features/categories/data/models/subcategory_model.dart` | Shtuar `badgeColor` në model/JSON |
| `lib/features/categories/data/mappers/category_mapper.dart` | Map `badgeColor` → entity |
| `lib/features/categories/data/mappers/subcategory_mapper.dart` | Map `badgeColor` → entity |
| `lib/features/categories/data/datasources/category_firestore_datasource.dart` | Subcategories marrin `badgeColor` nga dokumenti Firestore |
| `lib/features/categories/presentation/utils/category_badge_color_helper.dart` | **I ri** — `parseHex`, `textColor`, `resolveBackground` |
| `lib/core/widgets/category_chip_bar.dart` | Chip i zgjedhur përdor `badgeColor` dinamik |
| `lib/core/widgets/subcategory_chip_bar.dart` | Chip + trashëgim nga parent |
| `lib/features/categories/presentation/screens/categories_screen.dart` | Kalon `parentBadgeColor` te `SubcategoryChipBar` |
| `lib/features/products/presentation/controllers/product_detail_controller.dart` | Ngarkon kategorinë (cache) për badge në detaj |
| `lib/features/products/presentation/screens/product_detail_screen.dart` | Badge mbi foto përdor `badgeColor` |
| `lib/core/di/injection.dart` | `ProductDetailController` merr `GetCategoryByIdUseCase` |
| `test/helpers/fixtures.dart` | `badgeColor` në fixture-t e kategorive |
| `test/features/categories/presentation/utils/category_badge_color_helper_test.dart` | **I ri** |
| `test/features/categories/data/mappers/subcategory_mapper_test.dart` | **I ri** |
| `test/features/categories/data/mappers/category_mapper_test.dart` | Assert për `badgeColor` |
| `test/features/categories/data/models/category_model_test.dart` | Assert për `badgeColor` nga JSON |
| `test/features/products/presentation/controllers/product_detail_controller_test.dart` | Mock `GetCategoryByIdUseCase` |

**Pa ndryshuar:** Firestore schema, backend, web, checkout, auth, madhësi chip, padding, radius, font, spacing, animacione, selection logic.

---

## Leximi i `badgeColor` nga Firestore

1. `CategoryFirestoreDataSource._loadActiveCategories()` lexon `categories` me `isActive == true` (cache TTL 5 min).
2. `CategoryModel.fromJson` parse-on fushën `badgeColor` si `String?` (format `#RRGGBB`).
3. `CategoryMapper.toEntity` e kalon në `CategoryEntity.badgeColor`.
4. Për nënkategoritë, `getSubcategories()` map-on çdo sub-dokument në `SubcategoryModel` me `badgeColor: category.badgeColor`.
5. Nuk ka query shtesë — ngjyrat vijnë nga cache ekzistues i kategorive.

Shembull dokument:

```json
{
  "name": "Wines",
  "slug": "wines",
  "badgeColor": "#7A1F32",
  "type": "main",
  "isActive": true
}
```

---

## Fallback behavior

| Situata | Sjellja |
|---------|---------|
| `badgeColor` mungon ose është bosh | `Theme.of(context).colorScheme.primary` në UI; `AppColors.burgundy` në helper pa fallback eksplicit |
| Hex i pavlefshëm | E njëjta fallback si më sipër |
| Mock / legacy pa `badgeColor` | `null` — backward compatible; UI përdor primary/burgundy |

---

## Trashëgimi nga parent (subcategories)

`SubcategoryChipBar` merr `parentBadgeColor` nga kategoria kryesore (`category?.badgeColor`).

`CategoryBadgeColorHelper.resolveBackground()`:

1. Përdor `sub.badgeColor` nëse ekziston.
2. Përndryshe përdor `parentBadgeColor`.
3. Përndryshe fallback (primary / burgundy).

Chip-i "All" trashëgon ngjyrën e parent-it sepse nuk ka `badgeColor` të vet.

---

## `CategoryBadgeColorHelper`

**Vendndodhja:** `lib/features/categories/presentation/utils/category_badge_color_helper.dart`

| Metodë | Përshkrim |
|--------|-----------|
| `parseHex(String? hex, {Color? fallback})` | Parse `#RRGGBB` ose `RRGGBB`; shton alpha `FF` |
| `textColor(Color background)` | `computeLuminance() > 0.5` → tekst i zi; përndryshe i bardhë |
| `resolveBackground({badgeColor, parentBadgeColor, fallback})` | Zgjidh ngjyrën e background për chip/badge |

---

## Logjika e kontrastit të tekstit

- Background i errët (luminance ≤ 0.5) → **tekst i bardhë**
- Background i çelët (luminance > 0.5) → **tekst i zi**

Aplikohet në:
- `CategoryChipBar` (chip i zgjedhur)
- `SubcategoryChipBar` (chip i zgjedhur)
- Badge kategorie në `ProductDetailScreen` mbi foto

---

## UI — ku përdoret

| Widget | Burimi i ngjyrës |
|--------|------------------|
| `CategoryChipBar` (Home) | `CategoryEntity.badgeColor` |
| `SubcategoryChipBar` (Category products) | `SubcategoryEntity.badgeColor` + `parentBadgeColor` |
| Badge në `ProductDetailScreen` | `GetCategoryByIdUseCase` → `category.badgeColor` (nga cache) |

Asnjë hardcoded switch/case për ngjyra kategorie.

---

## Teste

| Test | Skedar |
|------|--------|
| `parseHex()` — `#RRGGBB`, pa `#`, invalid, null | `category_badge_color_helper_test.dart` |
| `textColor()` — background i errët / i çelët | `category_badge_color_helper_test.dart` |
| `resolveBackground()` — sub, parent fallback, fallback i përgjithshëm | `category_badge_color_helper_test.dart` |
| `badgeColor` në mapper/model | `category_mapper_test.dart`, `subcategory_mapper_test.dart`, `category_model_test.dart` |
| Product detail ngarkon kategori për badge | `product_detail_controller_test.dart` |

---

## Rezultatet

```
flutter analyze
No issues found!

flutter test
154 tests passed
```

---

## Përmbledhje

Kategoritë dhe nënkategoritë marrin automatikisht ngjyrën e badge nga Firebase, njësoj si web. Cache ekzistues i kategorive mbulon ngjyrat pa lexime shtesë Firestore. Mock data mbetet kompatibile kur `badgeColor` mungon.
