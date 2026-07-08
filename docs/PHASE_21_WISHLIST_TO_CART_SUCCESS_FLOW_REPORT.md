# Phase 21 — Wishlist → Cart Success Flow

**Data:** 8 korrik 2026  
**Qëllimi:** Rregullo “Shto në shportë” nga Wishlist: add në Cart, pastaj (vetëm në sukses) remove nga Wishlist, refresh badges, snackbar suksesi.

---

## Root cause

Për user të kyçur, `CartRepositoryImpl.addProduct` thërriste `loadPersistedCart()` para shkrimit.  
`CartFirestoreDataSource.loadPersistedCart()` bënte **`users/{uid}/cart`.get()** (collection list).

Në runtime (si te logu i `flutter run`):

```
[cloud_firestore/permission-denied] ...
CartFirestoreDataSource.readStoredEntries / loadPersistedCart
→ CartRepositoryImpl._runMerge / _activeDataSource
```

`AddToCartUseCase` e mbështjell exception-in me `guard` → `Result.failure` → snackbar  
**"Nuk u shtua në shportë. Provo përsëri."** dhe Cart mbetet bosh.

Dokument-level `doc(productId).get()` / `set()` nuk kërkojnë listë të plotë; problem ishte **list query para write**, jo mungesa e use case-it.

---

## Çfarë u rregullua

### Cart Firestore add (shkakui real)
- `addProduct` / update / remove / clear janë **`Future`** dhe **await**-ojnë persistencën.
- Add hydrate-on **dokumentin e produktit** (`doc(productId).get()`), jo collection list.
- `CartRepositoryImpl.addProduct` **nuk** forcon `loadPersistedCart()` për Firestore path.
- Merge: nëse collection list jep `permission-denied`, lexon cloud entries me **document reads** për guest `productId`-t.

### Wishlist success flow
```
AddToCartUseCase
  → SUCCESS?
    → RemoveFromWishlist
    → refresh wishlist items + WishlistStateNotifier
    → Cart badge (nga CartRepository add)
    → snackbar "Produkti u shtua në shportë."
  → FAILURE / OOS → wishlist i paprekur
```

UI (layout/snackbar strings) **i paprekur**.

---

## Guest / Logged in

| | Cart | Wishlist |
|--|------|----------|
| Guest | SharedPreferences | SharedPreferences |
| Logged in | `users/{uid}/cart/{productId}` | `users/{uid}/wishlist/{productId}` |

Auth routing mbetet në repository — pa logjikë auth në UI.

---

## Skedarët

| Skedar | Ndryshim |
|--------|----------|
| `cart_data_source.dart` | Mutate methods → `Future` |
| `cart_local_datasource.dart` | Await persist |
| `cart_firestore_datasource.dart` | Document-scoped add + list-denied hydrate |
| `cart_mock_datasource.dart` | Async mutate |
| `cart_repository_impl.dart` | Merge fallback + skip full hydrate on Firestore add |
| `wishlist_controller.dart` | Remove + refresh vetëm pas SUCCESS |
| `wishlist_to_cart_flow_test.dart` | Teste të reja të flow-it |
| `wishlist_controller_test.dart` | Verifikon remove-on-success |
| `cart_firestore_datasource_test.dart` | Document-scoped add |

---

## Rezultatet

### flutter analyze
```
No issues found!
```

### flutter test
```
All tests passed!
```

---

## Rezultati final

Wishlist → Cart tani shton produktin në Cart (guest lokal / Firestore me document write), e heq nga Wishlist vetëm pas suksesi, rifreskon badges, dhe shfaq snackbar-et e duhura për success / failure / out-of-stock.
