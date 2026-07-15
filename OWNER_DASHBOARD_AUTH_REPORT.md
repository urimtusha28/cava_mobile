# OWNER_DASHBOARD_AUTH_REPORT

**Data:** 13 Korrik 2026  
**Scope:** Role-based navigation + Owner Dashboard skeleton (placeholder data)

---

## Çfarë u ndryshua

U implementua navigim i bazuar në rol pa prekur UI/logjikën e ecommerce të customer:

1. **Role detection** nga backend (custom claim `admin` + `users/{uid}.role`)
2. **go_router** me shell të veçantë Owner + redirect guard për `/owner*`
3. **Post-login navigation** — owner shkon menjëherë te Dashboard (pa flash të Home)
4. **Owner Dashboard UI** me të dhëna hardcoded (pa Firestore queries)
5. **Bottom navigation e ndarë** për Owner (jo e njëjta me customer)

Customer shell (Home / Wishlist / Cart / Profile), checkout, cart, orders customer dhe profile customer mbeten të paprekura në UI.

---

## Si funksionon role detection

Burimi i së vërtetës është i njëjti me Firestore Rules `isAdmin()` në repo-n `cava`:

1. **Firebase Custom Claim** `admin == true` (preferuar)
2. **Firestore** `users/{uid}.role == "admin"` (kompatibilitet)
3. Alias opsional: `role == "owner"` → trajtohet si owner
4. Mungesa e rolit / `client` / çdo vlerë tjetër → **customer**

**Nuk** përdoret kontroll email (`info@cava-premium.com`).

### Flow teknik

```
Login / Splash load
  → AuthController._refreshUser()
  → ResolveAppRoleUseCase
  → AppRoleRepositoryImpl.resolveCurrentRole()
       1) FirebaseAuthGateway.getAdminClaim(forceRefresh: true)
       2) UserProfileRepository.getCurrentProfile().role
  → AppSessionNotifier.update(isLoggedIn, role)
  → go_router refreshListenable + PostAuthNavigator (nëse owner)
```

| Layer | File | Përgjegjësia |
|-------|------|--------------|
| Enum / mapper | `lib/core/auth/app_role.dart` | `AppRole.customer` / `owner` |
| Session | `lib/core/auth/app_session_notifier.dart` | State për router |
| Domain | `lib/features/account/domain/repositories/app_role_repository.dart` | Contract |
| Use case | `lib/features/account/domain/usecases/resolve_app_role.dart` | `ResolveAppRoleUseCase` |
| Data | `lib/features/account/data/repositories/app_role_repository_impl.dart` | Claims + Firestore |
| Gateway | `lib/features/account/data/firebase/firebase_auth_gateway.dart` | `getAdminClaim()` |
| Controller | `lib/features/account/presentation/controllers/auth_controller.dart` | Përditëson session pas auth |

UI **nuk** di si merret roli — lexon vetëm `AppSessionNotifier` / rezultat navigimi.

---

## Si funksionon routing

`GoRouter` ka `refreshListenable: AppSessionNotifier.instance`.

Redirect (`_roleRedirect` në `app_router.dart`):

- `/` → `/splash`
- Nëse path është owner (`/owner` ose `/owner/...`) **dhe** `!isOwner` → **`/home`**
- Përndryshe `null` (lejo)

Pas login/register të suksesshëm:

- `PostAuthNavigator.navigateIfOwner(context)` — vetëm owner bën `context.go('/owner')`
- Customer mbetet në ekranin aktual (profile/checkout/orders/addresses)

Splash (pas onboarding):

- `AuthController.load()` → resolve role → `PostAuthNavigator.homeLocationForCurrentSession()`
  - Owner → `/owner`
  - Customer / guest → `/home`

Logout nga Owner Profile → clear session → `/home`.

---

## Routes të shtuara

| Route | Screen | Shell |
|-------|--------|-------|
| `/owner` | `OwnerDashboardScreen` | Owner shell |
| `/owner/orders` | `OwnerOrdersScreen` | Owner shell |
| `/owner/analytics` | `OwnerAnalyticsScreen` | Owner shell |
| `/owner/products` | `OwnerProductsScreen` | Owner shell |
| `/owner/profile` | `OwnerProfileScreen` | Owner shell |

Customer routes ekzistuese (`/home`, `/wishlist`, `/cart`, `/profile`, …) të paprekura.

---

## Si mbrohet `/owner`

1. **Router redirect** — çdo navigim te `/owner*` nga non-owner ridrejtohet te `/home`
2. **refreshListenable** — kur session ndryshon (logout), redirect ri-vlerësohet
3. **Nuk** mbështetet vetëm te fshehja e butonave UI

Shënim: mbrojtja e të dhënave admin në Firestore mbetet te **Firestore Rules / Admin SDK** (ekzistuese). Ky ndryshim mbron navigimin e app-it, jo query-t e ardhshme të dashboard-it.

---

## Bottom navigation

| Audience | Tabs |
|----------|------|
| Customer (ekzistues) | Home · Wishlist · Shporta · Profili (`BottomNavigation`) |
| Owner (i ri) | Dashboard · Porositë · Analitika · Produktet · Profili (`OwnerBottomNavigation`) |

Dy widget-e të ndara — nuk ndajnë të njëjtin bottom nav.

---

## Owner Dashboard (placeholder)

Seksione me të dhëna nga `OwnerDashboardPlaceholderData` (hardcoded):

- Cards: Shitjet Sot / Javë / Muaj, Totali i të Ardhurave, Numri i Porosive, Porosi në Pritje / Proces / Përfunduara / Anuluara
- Grafik shitjesh (bar chart lokal)
- Porositë e fundit
- Produktet më të shitura
- Produkte me stok të ulët
- Klientët e rinj

**Asnjë** query Firestore / Cloud Function për këto metrika.

---

## Çfarë mbetet për backend

1. Lidhja e metrikave me të dhëna reale (orders aggregation, statsDaily, etj.)
2. Owner Orders / Analytics / Products me lista live + filtra
3. Siguria e query-ve (vetëm admin lexon stats) — tashmë e mbuluar pjesërisht nga rules
4. Opsionale: set custom claim `admin` për usera owner nëse ende përdoret vetëm `users.role`
5. Quipu / pagesa kartë në mobile (jashtë këtij scope)
6. Testet e integrimit për redirect owner/customer

---

## File-t e prekur

### Të rinj

- `lib/core/auth/app_role.dart`
- `lib/core/auth/app_session_notifier.dart`
- `lib/core/router/post_auth_navigator.dart`
- `lib/features/account/domain/repositories/app_role_repository.dart`
- `lib/features/account/domain/usecases/resolve_app_role.dart`
- `lib/features/account/data/repositories/app_role_repository_impl.dart`
- `lib/features/owner_dashboard/data/owner_dashboard_placeholder_data.dart`
- `lib/features/owner_dashboard/presentation/shell/owner_shell_scaffold.dart`
- `lib/features/owner_dashboard/presentation/shell/owner_bottom_navigation.dart`
- `lib/features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart`
- `lib/features/owner_dashboard/presentation/screens/owner_orders_screen.dart`
- `lib/features/owner_dashboard/presentation/screens/owner_analytics_screen.dart`
- `lib/features/owner_dashboard/presentation/screens/owner_products_screen.dart`
- `lib/features/owner_dashboard/presentation/screens/owner_profile_screen.dart`
- `OWNER_DASHBOARD_AUTH_REPORT.md`

### Të modifikuar

- `lib/core/router/app_routes.dart` — owner routes
- `lib/core/router/app_router.dart` — owner shell + role redirect
- `lib/core/di/injection.dart` — AppRole DI
- `lib/features/account/data/firebase/firebase_auth_gateway.dart` — `getAdminClaim`
- `lib/features/account/presentation/controllers/auth_controller.dart` — resolve role
- `lib/features/onboarding/presentation/screens/splash_screen.dart` — navigate by role
- `lib/features/account/presentation/screens/profile_screen.dart` — post-login owner nav
- `lib/features/account/presentation/screens/orders_screen.dart` — post-login owner nav
- `lib/features/account/presentation/screens/addresses_screen.dart` — post-login owner nav
- `lib/features/checkout/presentation/screens/checkout_screen.dart` — post-login owner nav
- `test/features/account/presentation/controllers/auth_controller_test.dart`
- `test/features/account/presentation/controllers/profile_controller_test.dart`

### Jo të prekur (me qëllim)

- Checkout business logic, cart, wishlist, product catalog UI
- Customer profile UI layout
- Firestore schema / Cloud Functions / rules

---

## Si të testosh manualisht

1. User me `users/{uid}.role = "client"` → login → mbetet në customer app.
2. User me `role = "admin"` (ose claim `admin: true`) → login → hapet `/owner` menjëherë.
3. Si customer, provo `context.go('/owner')` / deep link → ridrejtohet te `/home`.
4. Owner logout nga `/owner/profile` → `/home` + bottom nav customer.
