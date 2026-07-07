# Phase 8 — Guest Cart Persistence Report

## Qëllimi

Cart për guest user të ruhet lokalisht në pajisje dhe të mos humbet pas restart / app reopen.

---

## Storage

| Përshkrim | Vlerë |
|-----------|--------|
| **Teknologji** | `SharedPreferences` (ekzistonte në projekt) |
| **Key** | `guest_cart_items_v1` |
| **Format** | JSON array |

### Çfarë ruhet (jo `ProductEntity` i plotë)

```json
{
  "productId": "p1",
  "quantity": 2,
  "selectedVariant": null,
  "addedAt": "2026-01-01T00:00:00.000Z"
}
```

---

## Skedarët e shtuar / ndryshuar

| Skedar | Rol |
|--------|-----|
| `lib/features/cart/data/models/stored_cart_item_model.dart` | **I ri** — DTO për JSON |
| `lib/features/cart/data/local/cart_local_storage.dart` | **I ri** — read/write SharedPreferences |
| `lib/features/cart/data/datasources/cart_local_datasource.dart` | **I ri** — zëvendëson `CartMockDataSource` në DI |
| `lib/features/cart/data/datasources/cart_data_source.dart` | `loadPersistedCart()` |
| `lib/features/cart/domain/repositories/cart_repository.dart` | `hydrateFromStorage()` |
| `lib/features/cart/data/repositories/cart_repository_impl.dart` | hydrate + async getters |
| `lib/core/di/injection.dart` | regjistron `CartLocalDataSource` |
| `lib/core/presentation/navigation_badge_controller.dart` | hydrate para badge sync |
| `test/features/cart/data/datasources/cart_local_datasource_test.dart` | **I ri** |

**Pa ndryshuar:** UI, routing, checkout flow, Firebase products/categories, web/backend, Firestore cart.

---

## Si rindërtohet cart

1. `CartRepository.hydrateFromStorage()` → `CartLocalDataSource.loadPersistedCart()`
2. Lexon `StoredCartItemModel[]` nga SharedPreferences
3. Për çdo rresht: `ProductRepository.getById(productId)`
4. Nëse produkti ekziston → `CartItemEntity(product, quantity)` me **çmim aktual** nga Firestore
5. Nëse mungon / draft / hidden (`getById` → `null`) → **skip**, pa crash
6. Storage pastrohet nga rreshtat e pavlefshëm

---

## Kur ruhet

| Veprim | Persist |
|--------|---------|
| `addProduct` | ✅ menjëherë |
| `updateQuantity` | ✅ |
| `removeAt` | ✅ |
| `clear` | ✅ (fshin key) |

---

## Badge & screens

| Moment | Sjellja |
|--------|---------|
| App open | `BottomNavigation` post-frame → `syncBadges()` → `hydrateFromStorage()` |
| Cart screen | `CartController.load()` → `getSummary()` → hydrate |
| Checkout | `CheckoutController.load()` → `CartController.load()` → cart i ruajtur |
| Mutations | `CartRepositoryImpl._notifyChange()` → badge përditësohet |

---

## UI

**Identik** — vetëm data layer dhe persistence; asnjë ndryshim layout/widget.

---

## Teste

| Test | Verifikon |
|------|-----------|
| `persists cart after add` | Storage pas add |
| `restores cart after hydrate` | Quantity pas reload |
| `remove updates storage` | Remove |
| `clear empties storage` | Clear |
| `missing product does not crash hydrate` | Produkt i fshirë |
| `hydrate uses current product price` | Çmim aktual nga repo |
| `syncBadges hydrates persisted cart count` | Badge pas load |

---

## Rezultatet

```
flutter analyze
→ No issues found!

flutter test
→ 182 tests passed
```

---

## Përmbledhje

Guest cart ruhet lokalisht me `productId` + `quantity` + metadata. Pas hapjes së app-it, cart rindërtohet nga katalogu real i produkteve; badge dhe checkout lexojnë të njëjtin cart të persistuar.
