# Wishlist Real Products — Report

## Qëllimi

Wishlist të mos shfaqë më produkte mock të paracaktuara (Stone Castle, Wayne Gretzky, Trius), por të punojë me **ProductEntity reale** nga katalogu Firestore, me foto reale dhe wishlist lokale për guest derisa Auth/Firestore sync të jetë gati.

---

## Problemi

`MockWishlist` mbushje automatikisht me 3 produkte nga `MockProducts` (`wine-001`, `wine-002`, `wine-003`) — pa imazhe reale dhe pa lidhje me katalogun Firestore.

---

## Zgjidhja

### 1. Local guest wishlist (in-memory)

| Skedar | Rol |
|--------|-----|
| `lib/features/wishlist/data/local/local_wishlist_store.dart` | **I ri** — listë bosh në memorie |
| `lib/features/wishlist/data/datasources/wishlist_local_datasource.dart` | **I ri** — zëvendëson `WishlistMockDataSource` |

- **Pa seed mock** — wishlist fillon bosh.
- Produktet shtohen si `ProductEntity` reale (nga Firestore kur përdoret `ToggleWishlistUseCase` / `add`).
- **Firestore wishlist** — ende jo aktiv (`WishlistFirestoreDataSource` unimplemented).

### 2. Hequr

- `lib/features/wishlist/data/mock/mock_wishlist.dart`
- `lib/features/wishlist/data/datasources/wishlist_mock_datasource.dart`

### 3. DI

`injection.dart` regjistron `WishlistLocalDataSource`.  
`resetDependencies()` thërret `LocalWishlistStore.clear()` për teste.

### 4. UI — `WishlistScreen`

| Ndryshim | Detaj |
|----------|--------|
| Foto | `ProductImageView` + `CachedNetworkImage` (`product.imageUrl`) |
| Placeholder | Ikona wine glass (si më parë) kur nuk ka URL |
| Empty state | `Wishlist është bosh.` |
| Layout | **I pandryshuar** — 56×72 thumb, card, butona |

Funksionaliteti ekzistues:
- **X** → `removeFromWishlist` + refresh + badge
- **Shto në shportë** → `AddToCartUseCase` me produkt real
- **Badge** → `WishlistStateNotifier` përditësohet nga repository

---

## Skedarët e ndryshuar

| Skedar |
|--------|
| `lib/features/wishlist/data/local/local_wishlist_store.dart` (new) |
| `lib/features/wishlist/data/datasources/wishlist_local_datasource.dart` (new) |
| `lib/core/di/injection.dart` |
| `lib/features/wishlist/presentation/screens/wishlist_screen.dart` |
| `test/features/wishlist/data/datasources/wishlist_local_datasource_test.dart` (new) |
| `test/features/wishlist/presentation/screens/wishlist_screen_test.dart` (new) |

**Pa prekur:** Home, Products, Categories, Checkout, Auth, routing, layout bazë.

---

## Teste

| Test | Verifikon |
|------|-----------|
| `wishlist_local_datasource_test` | Bosh fillim, add/remove ProductEntity |
| `wishlist_screen_test` | Empty state, pa mock Stone Castle |
| Testet ekzistuese wishlist controller/repository | Pa regresion |

---

## Rezultatet

```
flutter analyze
flutter test
```

---

## Sjellja e re

1. Hap Wishlist → **bosh** (nëse nuk është shtuar asgjë).
2. Kur produkti shtohet në wishlist (via `ToggleWishlistUseCase` kur të lidhet UI), ruhet `ProductEntity` real me `imageUrl` nga Firestore.
3. Wishlist shfaq foto reale dhe çmime nga katalogu aktual.
4. Badge në bottom nav = numri real i artikujve në wishlist lokale.

---

## Hapi i ardhshëm (jashtë scope)

- Lidh `ToggleWishlistUseCase` në product card/detail për të shtuar nga UI.
- Kur Auth është gati → `WishlistFirestoreDataSource` për sync cloud.
