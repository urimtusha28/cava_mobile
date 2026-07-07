# Navigator Duplicate Page Key — Fix Report

**Data:** 8 korrik 2026  
**Error:** `'!keyReservation.contains(key)': is not true` — `NavigatorState._debugCheckDuplicatedPageKeys`

---

## Shkaku

Dy probleme të kombinuara:

### 1. `NoTransitionPage` pa `state.pageKey` (ShellRoute)

Në `app_router.dart`, të gjitha faqet e `ShellRoute` përdorin:

```dart
pageBuilder: (_, _) => const NoTransitionPage(child: HomeScreen()),
```

Pa `key: state.pageKey`, go_router nuk gjeneron çelësa unikë për Navigator. Kur ndërrohen tab-et (home / wishlist / **cart** / profile) ose hapet product detail mbi shell, Flutter regjistron **page keys të dyfishta** në stack.

**Routes të prekura:**
- `/splash`, `/onboarding`
- Shell: `/home`, `/wishlist`, `/cart`, `/profile`, `/category/:categoryId`

### 2. `context.push('/cart')` nga Product Detail (root navigator)

`/cart` është **ShellRoute tab** (shell navigator), jo root overlay.

Product detail (`/product/:productId`) është në **root navigator** (`parentNavigatorKey: _rootNavigatorKey`).

"Bli tani" bënte:

```dart
context.push(AppRoutes.cart);  // gabim
```

Kjo shtonte `/cart` si faqe të re në root stack **ndërkohë që `/cart` ekziston tashmë** si tab në shell → duplicate page key kur HeroControllerScope/go_router rindërton stack-un.

**Ikona e shportës** në product detail ishte OK (vetëm add-to-cart + snackbar, pa navigation) — nuk u ndryshua.

---

## Çfarë u ndryshua

### `lib/core/router/app_router.dart`

Çdo `NoTransitionPage` tani përdor:

```dart
pageBuilder: (context, state) => NoTransitionPage(
  key: state.pageKey,
  child: const HomeScreen(),
),
```

Root routes (`/product/:id`, `/checkout`, etj.) mbeten me `builder` — go_router u jep automatikisht `pageKey` unik; nuk ka key manual/hardcoded.

### `lib/features/products/presentation/screens/product_detail_screen.dart`

"Bli tani" pas add-to-cart:

```dart
// para
context.push(AppRoutes.cart);

// pas
context.go(AppRoutes.cart);
```

`go` zëvendëson stack-un dhe shfaq tab-in e cart në shell (si bottom nav), pa dyfishuar faqen.

### `lib/core/widgets/hero_banner.dart` (e njëjta anti-pattern)

Ikona e shportës në hero banner: `push` → `go` për `/cart` (vetëm navigation, pa ndryshim UI).

---

## Pse zgjidhja nuk prish navigation

| Skenar | Sjellja |
|--------|---------|
| Tab bottom nav → Cart | `context.go('/cart')` — i njëjti me më parë |
| Product detail → Bli tani | `go('/cart')` mbyll product detail, shfaq cart tab — **pa dy stack entries** |
| Cart icon product detail | Vetëm snackbar — pa navigation |
| Category / Home / Profile | `state.pageKey` unik për çdo tab switch |
| Checkout / Orders (root) | Pa ndryshim — ende `push`/`go` nga root routes |

---

## Verifikim

| Komandë | Rezultat |
|---------|----------|
| `flutter analyze` | No issues found |
| `flutter test` | **265 teste kaluan** |

---

## Përmbledhje

| Pyetje | Përgjigje |
|--------|-----------|
| Cili route/key ishte problem? | Shell `NoTransitionPage` pa key + `/cart` i dyfishuar |
| Shkaku kryesor? | **`push` në tab route** + **missing `state.pageKey`** |
| UI u ndryshua? | **Jo** — vetëm navigation internals |
| Firebase/backend? | **Pa prekje** |
