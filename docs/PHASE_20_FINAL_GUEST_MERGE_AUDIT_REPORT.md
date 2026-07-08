# Phase 20 — Final Guest State Merge After Login Audit & Fix

**Data:** 8 korrik 2026  
**Qëllimi:** Verifikim dhe rregullim i bashkimit të guest cart/wishlist me Firestore pas login, pa dublikata, race conditions, ose badge të gabuara.

---

## Edge cases që u gjetën

| # | Problemi | Impakti |
|---|----------|---------|
| 1 | `AuthStateNotifier.update` emitonte **çdo herë**, edhe kur vlera nuk ndryshonte | `AuthRepository` + `AuthController._refreshUser` shkaktonin dy eventi `true` → merge/badge dy herë |
| 2 | Merge flag `_mergedForUserId` vendosej **pas** `await`-eve | Race: listener + `_activeDataSource()` mund të nisin dy merge paralelë |
| 3 | Cart merge me guest bosh prapë thërriste `replaceAllEntries` | Rishkrim i panevojshëm i cloud cart në çdo auth event |
| 4 | Wishlist firestore cache nuk invalidohej qartë në logout (vetëm flag) | I pranueshëm (leximet janë live), por cart invalidonte cache — mbajtëm simetri në cart |
| 5 | `dispose()` i auth/cart/wishlist repo **nuk** ishte i lidhur me GetIt | Subscription mund të mbetet aktive pas `resetDependencies` në teste / hot restart |

**Jo-probleme (u verifikuan OK):**
- Cart quantity merge: `guest + cloud` për të njëjtin `productId`
- Wishlist: doc id = `productId` + `SetOptions(merge: true)` → pa dublikata
- Guest local keys pastrohen pas merge (`guest_cart_items_v1`, `guest_wishlist_items_v1`)
- Logout **nuk** fshin Firestore cart/wishlist
- BottomNavigation `syncBadges` në `addPostFrameCallback` (jo gjatë build)
- Singletons një listener secili (jo për çdo screen load)

---

## Çfarë u rregullua

### 1. `AuthStateNotifier.update` — idempotent
Emiton në stream **vetëm** kur `loggedIn` ndryshon.  
`reset()` vazhdon të emitojë `false` për të pastruar merge locks në teste.

### 2. Cart / Wishlist merge — in-flight lock
- `_mergeInFlight` bashkon thirrjet paralele
- Guest listë bosh → shënon `_mergedForUserId` pa rishkrim cloud
- Flag vendoset pasi merge përfundon; thirrjet konkurrente `await`-ojnë të njëjtin future

### 3. DI dispose hooks
`CartRepositoryImpl`, `WishlistRepositoryImpl`, `AuthRepositoryImpl` → `dispose:` në `registerLazySingleton`, që `sl.reset(dispose: true)` anulon subscription-et.

---

## Si punon merge cart

```
Login (AuthStateNotifier true)
  → CartRepositoryImpl listener
    → _mergeGuestCartIfNeeded()
      → nëse tashmë merge për uid / in-flight → skip/await
      → read guest (SharedPreferences guest_cart_items_v1)
      → read cloud users/{uid}/cart
      → CartMergeResolver: quantity = guest + cloud për productId
      → replaceAllEntries(merged)
      → clear guest local
      → _mergedForUserId = uid
  → _refreshBadge()
```

Logout: `_mergedForUserId = null`, invalidate Firestore cache, badge nga guest local (zakonisht 0). Cloud **ruhet**.

---

## Si punon merge wishlist

```
Login
  → WishlistRepositoryImpl listener
    → për çdo guest entry: addEntry(productId) (merge, pa dublikatë)
    → clear guest_wishlist_items_v1
    → refresh badge
```

Logout: kthehet te local guest; cloud wishlist mbetet.

---

## Auth listeners

| Komponent | Listener | Lifecycle |
|-----------|----------|-----------|
| `AuthRepositoryImpl` | `authStateChanges` → `AuthStateNotifier` | Singleton + dispose |
| `CartRepositoryImpl` | `watchAuthState` → merge + badge | Singleton + dispose |
| `WishlistRepositoryImpl` | `watchAuthState` → merge + badge | Singleton + dispose |
| Screens | `ValueListenableBuilder` mbi `isLoggedIn` | Jo stream subscription ekstra |

Nuk krijohet listener i ri për çdo hapje screen — vetëm repository singletons.

---

## Badge sync

Pas:
- app start → `BottomNavigation` post-frame `syncBadges`
- guest add → notifier update nga repo
- login → merge + `_refreshBadge`
- logout → guest count
- login përsëri → cloud count
- remove → notifier nga repo

`NavigationBadgeController.syncBadges` nuk thirret gjatë `build`.

---

## UI

**Identik** — asnjë ndryshim UI/layout/routing. Vetëm data-layer + auth notifier + DI dispose.

---

## Testet

`test/features/account/integration/guest_merge_lifecycle_test.dart`:
- guest cart+wishlist → login merge (quantity sum, no wishlist dup)
- guest local bosh pas merge
- auth true idempotent nuk dyfishon quantity
- logout nuk fshin cloud
- re-login lexon cloud + badge
- logged-in cart = Firestore (checkout path)
- `AuthStateNotifier.update` idempotent

---

## Rezultatet

### flutter analyze
```
2 info (cart_firestore_datasource — ekzistues)
0 errors, 0 warnings
```

### flutter test
```
All tests passed! (346 tests)
```

---

## Rezultati final

Pas login, guest cart dhe wishlist bashkohen saktë me Firestore pa dublikata dhe pa race; guest local pastrohet; cloud nuk fshihet në logout; auth emitet janë idempotente; listeners dispose-ohen në DI reset; badge mbeten të sakta në gjithë ciklin guest → login → logout → login.
