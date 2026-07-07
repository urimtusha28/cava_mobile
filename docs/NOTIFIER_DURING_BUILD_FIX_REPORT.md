# Notifier During Build — Fix Report

## Problemi

Kur hapeshin Wishlist/Cart, terminali shfaqte:

```
setState() or markNeedsBuild() called during build.
```

**Stack:**
```
CartStateNotifier.update
→ CartRepositoryImpl constructor
→ get_it DI resolve
→ createWishlistController
→ WishlistScreen.initState
```

**Shkaku:** `CartRepositoryImpl`, `WishlistRepositoryImpl`, dhe `AuthRepositoryImpl` thërrisnin `*StateNotifier.update()` në **constructor**, gjatë zgjidhjes së DI në `initState` / `build`.

---

## Zgjidhja

### 1. Hequr notifier updates nga constructors

| Repository | Hequr |
|------------|--------|
| `CartRepositoryImpl` | `CartStateNotifier.update` në constructor |
| `WishlistRepositoryImpl` | `WishlistStateNotifier.update` në constructor |
| `AuthRepositoryImpl` | `AuthStateNotifier.update` në constructor |

### 2. Notifier përditësohet vetëm pas operacioneve

| Veprim | Ku përditësohet |
|--------|-----------------|
| `getSummary()` | `CartRepositoryImpl._notifyChange()` |
| `addProduct` / `updateQuantity` / `removeAt` / `clear` | `CartRepositoryImpl._notifyChange()` |
| `getItems()` | `WishlistRepositoryImpl._notifyChange()` |
| `add` / `remove` / `toggle` | `WishlistRepositoryImpl._notifyChange()` |
| `login` / `logout` | `AuthRepositoryImpl` |
| `CartController._refreshSummary()` | `CartStateNotifier.update` |
| `WishlistController._refreshItems()` | `WishlistStateNotifier.update` |
| `AuthController.load()` / `login()` | `AuthStateNotifier.update` |

### 3. Initial badge count — pas frame-it të parë

`BottomNavigation.initState` → `addPostFrameCallback` → `NavigationBadgeController.syncBadges()`.

`syncBadges()` lexon count nga repository (pa notifier në constructor).

### 4. Hequr DI nga `build`

`NavigationBadgeController.ensureInitialized()` u hoq nga `BottomNavigation.build()` (shkaktonte DI resolve gjatë build).

---

## Skedarët e ndryshuar

| Skedar |
|--------|
| `lib/features/cart/data/repositories/cart_repository_impl.dart` |
| `lib/features/wishlist/data/repositories/wishlist_repository_impl.dart` |
| `lib/features/account/data/repositories/auth_repository_impl.dart` |
| `lib/core/presentation/navigation_badge_controller.dart` |
| `lib/core/widgets/bottom_navigation.dart` |

**Pa ndryshuar:** UI, routing, Firebase, products, categories.

---

## Rezultati i pritur

- Nuk shfaqet më `setState/markNeedsBuild during build` kur hapet Wishlist/Cart.
- Badge cart/wishlist funksionon pas sync, add/remove, dhe load në screen.
- Add to cart / wishlist toggle përditësojnë badge normalisht.

---

## Teste

```
flutter analyze
flutter test
```
