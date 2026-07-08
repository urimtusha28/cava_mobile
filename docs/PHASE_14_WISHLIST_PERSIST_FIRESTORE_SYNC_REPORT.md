# Phase 14 — Wishlist Persist + Firestore Sync

**Data:** 8 korrik 2026  
**Qëllimi:** Wishlist të mos jetë më vetëm in-memory. Guest ruhet lokalisht; user i kyçur sinkronizohet në Firestore `users/{uid}/wishlist`.

---

## Si funksionon guest wishlist

**Storage:** `WishlistGuestStorage`  
**Key:** `guest_wishlist_items_v1` (SharedPreferences)

Ruhet vetëm:
```json
[
  { "productId": "wine-001", "addedAt": "2026-07-08T10:00:00.000Z" }
]
```

**Rrjedha:**
```
Toggle/Add (guest)
  → WishlistRepositoryImpl → WishlistLocalDataSource
    → LocalWishlistStore (productId + addedAt)
    → WishlistGuestStorage.writeEntries()
```

**Hydration:**
- `getItems()` lexon entries nga prefs
- Për çdo `productId` thërret `ProductRepository.getById(productId)`
- Nëse produkti mungon → hiqet nga wishlist lokale (pa crash)

**Skedarë:**
- `lib/features/wishlist/data/local/wishlist_guest_storage.dart`
- `lib/features/wishlist/data/local/local_wishlist_store.dart`
- `lib/features/wishlist/data/models/stored_wishlist_entry_model.dart`
- `lib/features/wishlist/data/datasources/wishlist_local_datasource.dart`

---

## Si funksionon Firestore wishlist

**Path:** `users/{uid}/wishlist/{entryId}`  
**entryId:** `productId` (deterministik — pa dublikata)

**Fields:**
```json
{
  "productId": "wine-001",
  "createdAt": "<Timestamp>"
}
```

**Rrjedha (logged in):**
```
Toggle/Add/Remove
  → WishlistRepositoryImpl → WishlistFirestoreDataSource
    → Firestore users/{uid}/wishlist/{productId}
    → ProductRepository.getById për hydration
```

**Metodat:** `getItems`, `add`, `remove`, `toggle`, `isInWishlist`, `getCount`

**Cleanup:** produktet që `getById` kthen `null` fshihen nga Firestore automatikisht.

**Skedar:** `lib/features/wishlist/data/datasources/wishlist_firestore_datasource.dart`

---

## Si bëhet merge pas login

`WishlistRepositoryImpl` dëgjon `AuthRepository.watchAuthState()`:

1. Lexon guest entries nga `WishlistLocalDataSource.readStoredEntries()`
2. Për çdo entry shkruan në Firestore me `addEntry(productId, createdAt)`
3. `SetOptions(merge: true)` + `entryId = productId` → pa dublikata
4. Pastron guest local (`clearAll`)
5. Shënon `_mergedForUserId` që merge të mos përsëritet

Merge ekzekutohet edhe në operacionin e parë të wishlist pas login (`_activeDataSource()`).

---

## Si trajtohet logout

- **Nuk fshihet** Firestore wishlist
- `_mergedForUserId` resetohet
- Repository kalon në `WishlistLocalDataSource` (zakonisht bosh pas merge)
- Badge rifreskohet me count lokal

---

## Si hidratohet ProductEntity

Të dy datasource-et përdorin `ProductRepository.getById(productId)`:

| Situata | Veprim |
|---------|--------|
| Produkt aktiv | shfaqet në listë me çmim/foto aktual |
| Produkt missing/draft/hidden | hiqet nga wishlist (local ose Firestore) |
| Crash | **Jo** — cleanup silent |

---

## Si përditësohet badge

`WishlistStateNotifier.update(count)` thirret nga:
- `add` / `remove` / `toggle`
- `getItems` / `getCount`
- ndryshim auth (login/logout) përmes listener në repository
- `NavigationBadgeController.syncBadges()` në app start

| Auth | Burimi i count |
|------|----------------|
| Guest | local entries |
| Logged in | Firestore docs |

UI **nuk u ndryshua** — `BottomNavigation` dhe `ProductWishlistToggle` përdorin të njëjtin notifier.

---

## Skedarë të ndryshuar / të shtuar

| Skedar | Roli |
|--------|------|
| `stored_wishlist_entry_model.dart` | Model `{productId, addedAt}` |
| `wishlist_guest_storage.dart` | SharedPreferences persistence |
| `local_wishlist_store.dart` | In-memory entries (jo ProductEntity) |
| `wishlist_data_source.dart` | Interface async + toggle |
| `wishlist_local_datasource.dart` | Guest datasource + hydration |
| `wishlist_firestore_datasource.dart` | Firestore CRUD + hydration |
| `wishlist_repository_impl.dart` | Auth-aware routing + merge |
| `firebase_config.dart` | `wishlistSubcollection = 'wishlist'` |
| `injection.dart` | DI për local + firestore + repository |

**UI e paprekur:** `wishlist_screen.dart`, `product_wishlist_toggle.dart`, routing, layout.

---

## Testet e shtuara / përditësuara

| Test | Skedar |
|------|--------|
| Guest persistence + cleanup | `wishlist_local_datasource_test.dart` |
| Firestore add/get/toggle/cleanup | `wishlist_firestore_datasource_test.dart` |
| Auth-aware merge, logout, badge | `wishlist_repository_impl_test.dart` |
| Badge sync guest | `navigation_badge_controller_test.dart` |
| Toggle widget (ekzistues) | `product_wishlist_toggle_test.dart` |

---

## Rezultatet

### flutter analyze
```
No issues found!
```

### flutter test
```
All tests passed! (289 tests)
```

---

## Rezultati final

Wishlist ruhet lokalisht për guest (`guest_wishlist_items_v1`), ruhet në Firestore për user të kyçur (`users/{uid}/wishlist/{productId}`), merge bëhet automatikisht pas login pa dublikata, dhe UI mbeti identik.
