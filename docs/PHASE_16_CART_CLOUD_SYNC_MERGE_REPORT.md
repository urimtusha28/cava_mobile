# Phase 16 — Cart Cloud Sync + Merge After Login

**Data:** 8 korrik 2026  
**Qëllimi:** Guest cart ruhet lokalisht; user i kyçur sinkronizohet në Firestore `users/{uid}/cart/{productId}`. Merge pas login (shuma e quantity për të njëjtin productId, pa dublikata). Logout kthehet te guest cart pa fshirë Firestore.

---

## Si funksionon guest cart

**Storage:** `CartLocalStorage`  
**Key:** `guest_cart_items_v1` (SharedPreferences)

Ruhet vetëm:
```json
[
  {
    "productId": "wine-001",
    "quantity": 2,
    "selectedVariant": null,
    "addedAt": "2026-07-08T10:00:00.000Z"
  }
]
```

**Rrjedha:**
```
Add/Update/Remove (guest)
  → CartRepositoryImpl → CartLocalDataSource
    → in-memory _items + _metadataByProductId
    → CartLocalStorage.writeItems()
```

**Hydration:**
- `loadPersistedCart()` lexon entries nga prefs
- Për çdo `productId` thërret `ProductRepository.getById(productId)`
- Nëse produkti mungon → hiqet nga cart lokale (pa crash)
- Çmimi/subtotal përdor `ProductEntity.price` aktual nga repository

**Skedarë:**
- `lib/features/cart/data/local/cart_local_storage.dart`
- `lib/features/cart/data/models/stored_cart_item_model.dart`
- `lib/features/cart/data/datasources/cart_local_datasource.dart`

---

## Si funksionon Firestore cart

**Path:** `users/{uid}/cart/{productId}`  
**Document ID:** `productId` (deterministik — pa dublikata)

**Fields:**
```json
{
  "productId": "wine-001",
  "quantity": 2,
  "selectedVariant": null,
  "addedAt": "<Timestamp>",
  "updatedAt": "<Timestamp>"
}
```

**Rrjedha (logged in):**
```
Add/Update/Remove
  → CartRepositoryImpl → CartFirestoreDataSource
    → in-memory cache pas hydrate
    → Firestore set/delete në users/{uid}/cart/{productId}
```

**Hydration:**
- `loadPersistedCart()` lexon të gjitha dokumentet nga subcollection
- Hidraton me `ProductRepository.getById(productId)`
- Produktet që mungojnë fshihen nga Firestore dhe nga cache

**Skedarë:**
- `lib/features/cart/data/mappers/cart_firestore_mapper.dart`
- `lib/features/cart/data/datasources/cart_firestore_datasource.dart`
- `lib/core/firebase/firebase_config.dart` → `cartSubcollection = 'cart'`

---

## Merge pas login

**Kur:** `CartRepositoryImpl` dëgjon `AuthRepository.watchAuthState()`; merge ekzekutohet edhe në `_activeDataSource()` kur user është logged in.

**Algoritëm** (`CartMergeResolver`):
1. Lexo guest entries nga `CartLocalDataSource.readStoredEntries()`
2. Lexo cloud entries nga `CartFirestoreDataSource.readStoredEntries()`
3. Për çdo `productId` që ekziston në të dyja: `quantity = guest + cloud`
4. Bashko linjat unike (guest-only + cloud-only)
5. `replaceAllEntries(merged)` në Firestore (upsert + fshirje dokumentesh orphan)
6. `CartLocalDataSource.clearAll()` — pastron guest cart
7. `_mergedForUserId` parandalon merge të përsëritur për të njëjtin uid

```
Login
  → watchAuthState(true)
    → _mergeGuestCartIfNeeded()
      → guest + cloud → merged
      → shkruaj Firestore
      → pastro SharedPreferences
      → invalidateCache + refresh badge
```

---

## Logout

- **Nuk** fshihet Firestore cart
- `CartFirestoreDataSource.invalidateCache()` — cache in-memory pastrohet
- `_mergedForUserId = null` — merge do të rifillohet në login të ardhshëm
- `_activeDataSource()` kthen `CartLocalDataSource` (guest, bosh ose me artikuj të rinj)
- Badge rifreskohet nga guest cart

---

## Product hydration nga productId

Cart në storage/Firestore ruan vetëm `productId` + `quantity` (+ metadata opsionale).

Kur lexohet cart:
```dart
final product = await _productRepository.getById(entry.productId);
if (product == null) {
  // hiq nga cart + fshi nga storage/Firestore
  continue;
}
CartItemEntity(product: product, quantity: entry.quantity);
```

Subtotal/total përdorin çmimin aktual të `ProductEntity`, jo çmim të ruajtur në cart.

---

## Badge

- **Guest:** `CartStateNotifier` përditësohet nga `CartLocalDataSource.getItemCount()` pas hydrate
- **Logged in:** nga `CartFirestoreDataSource.getItemCount()`
- **Refresh:** pas login/logout (auth listener), pas add/update/remove/clear, dhe nga `hydrateFromStorage()` / `NavigationBadgeController.syncBadges()`

---

## Auth-aware repository

`CartRepositoryImpl` injekton:
- `CartLocalDataSource`
- `CartFirestoreDataSource`
- `AuthRepository`

UI/Controller/Checkout përdorin vetëm `CartRepository` — nuk ka logjikë auth në UI.

Checkout (`CheckoutController` → `CartController` → `CartRepository`) lexon automatikisht cart-in aktiv sipas auth state.

---

## DI

`injection.dart`:
- `_registerCart()` regjistrohet **pas** `_registerAuth()` (Firestore datasource kërkon `AuthRepository`)
- `configureTestDependencies(cartFirestore: FakeFirebaseFirestore())` për teste

---

## Skedarët e ndryshuar / shtuar

| Skedar | Ndryshim |
|--------|----------|
| `cart_firestore_datasource.dart` | Implementim i plotë Firestore CRUD + hydrate |
| `cart_firestore_mapper.dart` | Parse/serialize Firestore ↔ `StoredCartItemModel` |
| `cart_merge_resolver.dart` | Merge guest + cloud (shuma quantity) |
| `cart_local_datasource.dart` | `readStoredEntries()`, `clearAll()` |
| `cart_repository_impl.dart` | Auth-aware routing + merge + badge |
| `firebase_config.dart` | `cartSubcollection = 'cart'` |
| `injection.dart` | DI local + firestore + repository |

**UI e paprekur:** cart screen, product detail, routing, layout, checkout UI, wishlist, products, categories, orders, backend/web, Firestore rules.

---

## Testet e shtuara / përditësuara

| Test | Skedar |
|------|--------|
| Guest persistence, duplicate qty, cleanup | `cart_local_datasource_test.dart` (ekzistues) |
| Firestore add/hydrate/update/remove/clear | `cart_firestore_datasource_test.dart` |
| Guest persist, merge qty, no duplicates, logout, badge | `cart_repository_impl_test.dart` |
| Checkout lexon Firestore cart kur logged in | `checkout_controller_test.dart` |
| Badge sync guest | `navigation_badge_controller_test.dart` |
| DI + test helpers | `injection.dart`, `test_di.dart` |

---

## Rezultatet

### flutter analyze
```
2 info (avoid_types_as_parameter_names në cart_firestore_datasource.dart — i njëjti pattern si local)
0 errors, 0 warnings
```

### flutter test
```
All tests passed! (305 tests)
```

---

## Rezultati final

Cart ruhet lokalisht për guest (`guest_cart_items_v1`), ruhet në Firestore për user të kyçur (`users/{uid}/cart/{productId}`), merge bëhet automatikisht pas login me shumëzim të quantity për të njëjtin produkt pa dublikata, logout kthehet te guest cart pa fshirë cloud cart, checkout përdor cart-in aktiv sipas auth state, dhe UI mbeti identik.
