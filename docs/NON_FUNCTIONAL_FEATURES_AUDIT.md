# Cava Premium — Audit i funksionaliteteve jo-funksionale

**Data:** 8 korrik 2026  
**Metodë:** Analizë statike e kodit Flutter (`lib/`, `test/`, `pubspec.yaml`) — pa ndryshime kodi.  
**Verifikim:** `flutter test` → **243 teste kaluan**; `flutter analyze` → pa issue.

---

## Legjenda e statusit

| Status | Kuptimi |
|--------|---------|
| ✅ Functional | Funksionon end-to-end me burim të vërtetë të të dhënave |
| 🟡 Partial | Pjesë e implementuar; ka boshllëqe kritike ose jo-kritike |
| 🔴 Not functional | Nuk funksionon / mungon plotësisht |
| ⚪ Placeholder | Vetëm UI ose tekst statik; pa logjikë reale |
| 🟣 Local only | Vetëm lokalisht / in-memory; pa sync cloud |
| 🟠 Needs backend | UI ose klienti ekziston; mungon backend / Cloud Function / integrim |
| 🔵 Needs polish | Funksionon bazikisht por jo production-grade |

---

## 1. Home

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Home screen | 🟡 Partial | Shfaq seksione produktesh, chip-e kategorish, banner dyqani | `HomeMockDataSource` + `ProductRepository` (Firestore) | Ngarkim seksionesh (`home_controller.dart`), produkte reale nga Firestore, `VisitStoreBanner`, chip-e kategorish | Search bar dekorativ (`CavaSearchBar()` pa `onTap`/`controller` në `home_screen.dart:79`); seksionet e home janë statike mock, jo Firestore `banners`/`promotions` | UX i rremë për kërkim; home layout i fiksuar | Medium | Lidhe search me ekran kërkimi; implemento `HomeFirestoreDataSource` |

**Skedarë:** `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/home/data/datasources/home_mock_datasource.dart`, `lib/features/home/data/datasources/home_firestore_datasource.dart` (stub `UnimplementedError`).

---

## 2. Products

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Product catalog | ✅ Functional | Lista produktesh nga Firestore | `ProductFirestoreDataSource` → `products` | `getAllProducts`, by category, featured, offers, best sellers; TTL cache 5 min; `ProductImageView` + Storage URL | Fallback mock i çaktivizuar (`fallbackToMockProductsOnError: false`) — error Firestore shfaqet te përdoruesi | Varësi e plotë nga Firestore rules + indekse | Low | Monitoro error states në UI |

**Skedarë:** `lib/features/products/data/datasources/product_firestore_datasource.dart`, `lib/core/firebase/firebase_config.dart`.

---

## 3. Categories

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Categories | ✅ Functional | Kategori nga Firestore; navigim `/category/:id` | `CategoryFirestoreDataSource` → `categories` | Chip bar në home, `CategoryProductsScreen`, grid produktesh | `CategoriesScreen` (grid i të gjitha kategorive) **nuk është në router** — kod i vdekur | Ekran i panevojshëm / i pa-arritshëm | Low | Hiq ose lidhe rrugën |

**Skedarë:** `lib/features/categories/presentation/screens/categories_screen.dart`, `lib/core/router/app_router.dart`.

---

## 4. Product Details

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Product detail | 🟡 Partial | Detaje produkti + selector sasi | Firestore via `GetProductByIdUseCase` | Shfaqim çmimi, përshkrimi, imazhi, quantity UI | **"Bli tani" dhe ikona shporte vetëm navigojnë te `/cart`** — nuk thërrasin `AddToCartUseCase` (`product_detail_screen.dart:475–490`); nuk ka wishlist toggle në detail | Përdoruesi mendon se shtoi në shportë por shporta mbetet bosh | **Critical** | Thirr `AddToCartUseCase` me quantity para navigimit |

**Skedarë:** `lib/features/products/presentation/screens/product_detail_screen.dart`, `lib/features/cart/domain/usecases/add_to_cart.dart`.

---

## 5. Search

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Search | 🟡 Partial | Kërkim tekstual vetëm në faqe kategorie | Client-side filter mbi produktet e ngarkuara | `CavaSearchBar` me `controller` + `onChanged` në `CategoryProductsScreen` | Home search pa funksion; **nuk ka ekran global search**; nuk kërkon Firestore/Algolia | Kërkim i kufizuar | Medium | Ekran search global + query Firestore ose client filter |

**Skedarë:** `lib/core/widgets/search_bar.dart`, `lib/features/categories/presentation/screens/categories_screen.dart` (`CategoryProductsScreen`).

---

## 6. Filters

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Filters | 🟡 Partial | Filter nën-kategorie + tekst | Client-side `SubcategoryFilter` | Chip bar, filter by subcategory name, search text match | Pa çmim, markë, sortim, availability; vetëm në category page | Filtrim i kufizuar për katalog të madh | Low | Shto filter chips / sort në `CategoryProductsController` |

**Skedarë:** `lib/features/categories/domain/subcategory_filter.dart`.

---

## 7. Wishlist

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Wishlist | 🟣 Local only | In-memory list | `LocalWishlistStore` / `WishlistLocalDataSource` | Add/remove/toggle nga `ProductWishlistToggle` në grid; listë + badge; add-to-cart nga wishlist | **Humbet pas restart app**; `WishlistFirestoreDataSource` stub; pa sync `users/{uid}/wishlist` | Të dhëna të humbura; UX i dobët për përdorues të kthyer | High | Persist SharedPreferences + sync Firestore pas login |

**Skedarë:** `lib/features/wishlist/data/local/local_wishlist_store.dart`, `lib/features/wishlist/data/datasources/wishlist_firestore_datasource.dart`.

---

## 8. Cart

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Cart | 🟡 Partial | Shportë lokale me persistencë guest | `CartLocalDataSource` + `SharedPreferences` (`guest_cart_items_v1`) | Load/save, quantity update, remove, summary, badge sync, navigim checkout | **`AddToCartUseCase` thirret vetëm nga wishlist** — jo nga product detail/grid; zbritje **hardcoded €5** (`cart_local_datasource.dart:21`); `CartFirestoreDataSource` stub; nuk pastrohet pas checkout fake | Shportë e vështirë për t'u mbushur; total i rremë | **Critical** | Lidhe add-to-cart kudo; zbritje reale; clear pas porosie |

**Skedarë:** `lib/features/cart/data/datasources/cart_local_datasource.dart`, `lib/core/di/injection.dart` (`_registerCart`).

---

## 9. Checkout

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Checkout | 🟠 Needs backend | UI checkout + totale nga shporta | `CheckoutController` → `CartController` | Shfaq total/subtotal/VAT/shipping; zgjedhje metode pagese UI; checkbox terms | **`onBuy` vetëm `context.go(orderSuccess)`** — pa `placeOrder`, pa pagesë, pa pastrim shporte, pa order ID real (`checkout_screen.dart:116`) | **Nuk mund të bëhet porosi reale** | **Critical** | Integrim Cloud Function `placeOrder` + pastrim cart |

**Skedarë:** `lib/features/checkout/presentation/screens/checkout_screen.dart`, `lib/features/checkout/data/mock/mock_payment_methods.dart`.

---

## 10. Orders

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Orders list | 🟡 Partial | Lexim porosish për user të kyçur | `OrdersFirebaseDataSource` → `orders` where `userId` | Listë, sort `createdAt desc`, auth gate, empty/login states | **Vetëm read** — klienti nuk krijon porosi; varet nga backend/web për write | Porositë e reja nga app nuk shfaqen kurrë | **Critical** | `placeOrder` që shkruan `orders` |

**Skedarë:** `lib/features/account/data/datasources/orders_firebase_datasource.dart`, `lib/features/account/presentation/screens/orders_screen.dart`.

---

## 11. Order Details

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Order detail sheet | 🟡 Partial | Bottom sheet me artikuj, status, total | Firestore order doc + `ProductRepository` fallback për imazhe | `OrderMapper.resolveTotal()`, labels shqip (`order_formatters.dart`), thumbnails 52px | Vetëm për porosi ekzistuese në Firestore; success screen pas checkout ka të dhëna fake | Pas checkout fake, përdoruesi sheh `#CP-2024-01568` statik | Medium | Lidhe success screen me order ID real |

**Skedarë:** `lib/features/account/presentation/widgets/order_detail_bottom_sheet.dart`, `lib/features/checkout/presentation/screens/order_success_screen.dart`.

---

## 12. Addresses

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Addresses CRUD | ✅ Functional | Adresa për user të kyçur | `users/{uid}/addresses` Firestore | List, add (bottom sheet), edit, delete, auth gate | **Nuk lidhet me checkout** — `_UserInfoCard` hardcoded | Porosi me adresë të gabuar / bosh | High | Zgjedh adresë në checkout nga Firestore |

**Skedarë:** `lib/features/account/data/datasources/addresses_firebase_datasource.dart`, `lib/features/account/presentation/screens/addresses_screen.dart`.

---

## 13. Profile

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Profile | 🟡 Partial | Tile navigimi + header auth | `AuthController` + Firebase Auth | Login sheet, logout, navigim orders/addresses/help/about/language/terms/privacy | Nuk shfaq/edit profile fields nga `users/{uid}`; tile Valuta hequr por route `/currency` mbetet | Profil i paplotë | Low | Lexo/shkruaj `users/{uid}` name/phone |

**Skedarë:** `lib/features/account/presentation/screens/profile_screen.dart`, `lib/core/router/app_router.dart`.

---

## 14. Auth

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Login | ✅ Functional | Email/password Firebase Auth | `AuthFirebaseDataSource` | Login, error mapping shqip, `AuthStateNotifier` | Pa social login, pa email verification flow | Bazë OK për MVP | Low | — |

**Skedarë:** `lib/features/account/data/datasources/auth_firebase_datasource.dart`, `lib/features/account/presentation/widgets/auth_bottom_sheet.dart`.

---

## 15. Forgot Password

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Forgot password | ✅ Functional | `sendPasswordResetEmail` | Firebase Auth | Tab në auth bottom sheet, validim formë | — | Low | Low | — |

**Skedarë:** `lib/features/account/domain/usecases/forgot_password.dart`.

---

## 16. Register

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Register | ✅ Functional | Krijon user + doc Firestore | Firebase Auth + `users/{uid}` | `createUserWithEmailAndPassword`, `_writeUserDoc` me `role: client` | Pa verifikim email të detyruar | Llogari pa verify | Medium | Opsional: email verification |

**Skedarë:** `lib/features/account/data/datasources/auth_firebase_datasource.dart:109–127`.

---

## 17. Logout

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Logout | ✅ Functional | `signOut` | Firebase Auth | Tile "Dil" në profile kur logged in | Cart/wishlist lokale mbeten (pa merge) | Data e çfarëdo lloji pa sync | Medium | Merge guest cart/wishlist pas login |

**Skedarë:** `lib/features/account/presentation/screens/profile_screen.dart:101–106`.

---

## 18. Notifications

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| In-app notifications | ⚪ Placeholder | Bottom sheet me listë statike | Hardcoded `_notifications` | Hapet nga app bar | Pa Firestore, pa read state, pa FCM | Informacion i rremë | Medium | Koleksion `notifications` ose FCM inbox |

**Skedarë:** `lib/core/widgets/notifications_bottom_sheet.dart`.

---

## 19. Messages / Chat

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Messages | ⚪ Placeholder | Ekran me biseda statike | Hardcoded `_conversations` | Route `/messages` ekziston | **Pa link navigimi** nga UI; pa backend chat; support sheet jep vetëm snackbar | Feature i fshehur / jo funksional | Low | Hiq ose implemento chat backend |

**Skedarë:** `lib/features/messages/presentation/screens/messages_screen.dart`, `lib/core/widgets/support_bottom_sheet.dart:101–118`.

---

## 20. Store Location / Maps

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Store location | ✅ Functional | Banner me adresë + Google Maps | Statik në `VisitStoreBanner` + `url_launcher` | Dialog, hap maps URL, preview vizual | Koordinata/adresë hardcoded; pa Maps SDK embedded | OK për MVP | Low | Opsional: dinamik nga Firestore `storeSettings` |

**Skedarë:** `lib/core/widgets/visit_store_banner.dart`.

---

## 21. Language

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Language | ⚪ Placeholder | Zgjedhje UI Shqip/English | Local state `_selected` | Radio-style selection | **Pa `flutter_localizations`, pa persistencë, pa efekt në app** | Gjuha e rremë | Low | `intl` + ARB files + SharedPreferences |

**Skedarë:** `lib/features/account/presentation/screens/language_screen.dart`.

---

## 22. Currency

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Currency | ⚪ Placeholder | Ekran valute ekziston | Local UI | Route `/currency` | **Hequr nga profile**; çmimet gjithmonë € (`Formatters.currency`) | Route orphan | Low | Hiq route ose implemento multi-currency |

**Skedarë:** `lib/features/account/presentation/screens/currency_screen.dart`, `lib/core/router/app_router.dart`.

---

## 23. Terms

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Terms of use | ⚪ Placeholder | Tekst statik scroll | Hardcoded në `terms_screen.dart` | Shfaqet nga profile | Pa CMS/Firestore sync me web | Legal content drift | Low | Lexo nga Firestore/CMS |

**Skedarë:** `lib/features/account/presentation/screens/terms_screen.dart`.

---

## 24. Privacy Policy

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Privacy policy | ⚪ Placeholder | Tekst statik | Hardcoded | Navigim nga profile | Pa sync backend | Legal drift | Low | CMS/Firestore |

**Skedarë:** `lib/features/account/presentation/screens/privacy_screen.dart`.

---

## 25. About

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| About | ⚪ Placeholder | Info statike për Cava Premium | Hardcoded | Shfaqet | Pa version app dinamik nga `package_info` | Informacion i vjetër | Low | `package_info_plus` + CMS |

**Skedarë:** `lib/features/account/presentation/screens/about_screen.dart`.

---

## 26. Help & Contact

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Help & Contact | ⚪ Placeholder | FAQ / kontakt statik | Hardcoded `help_screen.dart` | Ekran i lexueshëm | Pa ticket system, pa email launcher të lidhur | Support i kufizuar | Low | `url_launcher` mailto/tel + backend tickets |

**Skedarë:** `lib/features/account/presentation/screens/help_screen.dart`.

---

## 27. Payments

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Payment methods | 🔴 Not functional | Radio UI cash/card/bank | `MockPaymentMethods` | Zgjedhje vizuale, detaje UI për cash/card/bank | **Asnjë gateway, asnjë API call, asnjë webhook** | Nuk merret pagesë | **Critical** | Integrim provider + server confirmation |

**Skedarë:** `lib/features/checkout/presentation/screens/checkout_screen.dart`, `lib/features/checkout/data/mock/mock_payment_methods.dart`.

---

## 28. Quipu

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Quipu (card) | 🔴 Not functional | Label "Paguaj me Kartë (Quipu)" | Mock entity `pay-card` | Shfaqet si opsion | **Zero kod Quipu** në repo; pa SDK, pa redirect, pa Cloud Function | Pagesë online e pamundur | **Critical** | Quipu SDK/API + server-side verify |

**Skedarë:** `lib/features/checkout/data/mock/mock_payment_methods.dart:5–11`.

---

## 29. Coupons / Discounts

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Discounts | 🟣 Local only | €5 zbritje fikse në shportë | `CartLocalDataSource._discount = 5.0` | Shfaqet në summary cart/checkout | Pa coupon code; `promotions` collection e papërdorur; zbritje jo nga Firestore | Total i gabuar vs web/admin | High | Lexo promocione nga Firestore + validate në `placeOrder` |

**Skedarë:** `lib/features/cart/data/datasources/cart_local_datasource.dart`, `lib/core/firebase/firebase_config.dart` (`promotionsCollection`).

---

## 30. Push Notifications

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Push (FCM) | 🔴 Not functional | — | — | — | **`firebase_messaging` mungon në `pubspec.yaml`**; pa token registration | Pa retention / order updates push | High | Shto FCM + background handlers |

**Skedarë:** `pubspec.yaml` (vetëm `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`).

---

## 31. Analytics

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Analytics | 🔴 Not functional | — | — | — | **`firebase_analytics` mungon**; pa event tracking | Pa visibility në funnel/conversion | Medium | Shto Analytics events (view_item, add_to_cart, purchase) |

**Skedarë:** `pubspec.yaml`.

---

## 32. Crashlytics

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Crashlytics | 🔴 Not functional | — | — | — | **`firebase_crashlytics` mungon**; vetëm `debugPrint` sporadik | Crashes në prod pa raport | High | Integro Crashlytics + FlutterError.onError |

**Skedarë:** `pubspec.yaml`.

---

## 33. App Check

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| App Check | 🔴 Not functional | — | — | — | **`firebase_app_check` mungon** | API/Firestore të ekspozuara ndaj abuse | High | Aktivizo App Check në Firebase Console + klient |

**Skedarë:** `pubspec.yaml`, `lib/core/firebase/firebase_config.dart`.

---

## 34. Deep Links

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Deep links | 🔵 Needs polish | Routing internal me `go_router` | In-app paths `/product/:id`, `/category/:id` | Navigim programmatic `context.push` | **Pa `app_links` / universal links**; pa Android intent filters për marketing | Linket email/social nuk hapin app | Medium | Konfiguro App Links + `go_router` redirect |

**Skedarë:** `lib/core/router/app_router.dart`.

---

## 35. Offline cache

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Offline / cache | 🟡 Partial | TTL memory + SharedPreferences | `TtlMemoryCache` (5 min), guest cart prefs | Produktet/kategoritë cached në RAM; cart persisted | **Pa Firestore offline persistence explicit**; wishlist pa persist; cache humbet pas kill app (produkte) | Browse offline i kufizuar | Medium | `enablePersistence` + cache wishlist |

**Skedarë:** `lib/core/cache/ttl_memory_cache.dart`, `lib/features/cart/data/local/cart_local_storage.dart`.

---

## 36. Error states

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Error handling | 🔵 Needs polish | `Result`/`Failure` në data layer | Controllers | Auth errors mapped; disa controllers kanë `errorMessage` | **Shumica e ekraneve nuk shfaqin error UI** — vetëm loading/empty; Firestore fail → ekran bosh ose crash potential | UX i keq, debug i vështirë | Medium | Widget error retry në Home, Products, Orders |

**Skedarë:** `lib/core/result/result.dart`, `lib/core/error/failures.dart`.

---

## 37. Loading states

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Loading UI | 🟡 Partial | `CavaLoadingOverlay`, `FutureBuilder` | Controllers | Home, categories, cart, orders kanë loading | Checkout/auth sheets pa skeleton konsistent | Perceived performance | Low | Standardizo loading widget |

**Skedarë:** `lib/core/widgets/cava_loading_overlay.dart`.

---

## 38. Empty states

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Empty states | 🟡 Partial | Tekst për shportë bosh, wishlist, orders | UI | Cart "Shporta është bosh"; orders login/empty gate | Empty states minimale pa CTA (p.sh. "Shiko produkte") | Conversion i ulët | Low | Empty state illustrations + CTA |

**Skedarë:** `lib/features/cart/presentation/screens/cart_screen.dart`, `lib/features/wishlist/presentation/screens/wishlist_screen.dart`.

---

## 39. Security rules compatibility

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Firestore rules | 🟠 Needs backend | Klienti lexon/shkruan sipas konventës `FirebaseConfig` | Firestore (rules **jashtë repo**) | Read products/categories; read orders by userId; CRUD addresses; write users doc on register | **`firestore.rules` nuk ekziston në repo**; client **nuk duhet** të shkruajë orders direkt — mungon Cloud Function; cart/wishlist write paths të paimplementuara | Security gap / order write blocked | **Critical** | Verifiko rules në Firebase Console; implemento `placeOrder` server-side |

**Skedarë:** `lib/core/firebase/firebase_config.dart`; docs: `docs/CATEGORIES_PERMISSION_ANALYSIS.md`.

---

## 40. Tests coverage

| Feature | Status | Current behavior | Data source | What works | What does not work | Risk | Priority | Next action |
|---------|--------|------------------|-------------|------------|-------------------|------|----------|-------------|
| Test suite | 🟡 Partial | 62 skedarë test, 243 teste | `test/` + mocks | Data layer, mappers, controllers, disa widget tests | **Pa test për `checkout_screen`, `product_detail_screen` add-to-cart, payment flow, integration/e2e** | Regresione në checkout | Medium | Widget tests për checkout + product detail cart |

**Skedarë:** `test/` (243 passed); mungon `test/features/checkout/presentation/screens/checkout_screen_test.dart`.

---

## Përmbledhje me numra

| Status | Numri | Module |
|--------|-------|--------|
| ✅ Functional | **8** | Products, Categories, Addresses, Auth, Forgot Password, Register, Logout, Store Location |
| 🟡 Partial | **12** | Home, Product Details, Search, Filters, Cart, Orders, Order Details, Profile, Offline cache, Loading states, Empty states, Tests |
| 🔴 Not functional | **6** | Payments, Quipu, Push Notifications, Analytics, Crashlytics, App Check |
| 🟣 Local only | **2** | Wishlist, Coupons/Discounts |
| ⚪ Placeholder | **8** | Notifications, Messages, Language, Currency, Terms, Privacy, About, Help & Contact |
| 🟠 Needs backend | **2** | Checkout, Security rules (order write path) |
| 🔵 Needs polish | **2** | Deep Links, Error states |
| **Total module** | **40** | |

**Përqindje e përafërt funksionale (✅):** 8/40 = **20%**  
**Gati për blerje reale (checkout + payment + order write):** **0%**

---

## Top 10 blockers për production

| # | Blocker | Evidencë | Impact |
|---|---------|----------|--------|
| 1 | **Checkout nuk krijon porosi** | `checkout_screen.dart:116` → `orderSuccess` pa API | Nuk ka ecommerce real |
| 2 | **Product detail nuk shton në shportë** | `product_detail_screen.dart:475–490` → vetëm `push(cart)` | Flow kryesor i blerjes thyhet |
| 3 | **Add to cart vetëm nga wishlist** | Grep: `AddToCartUseCase` vetëm në `wishlist_controller.dart` | Shporta mbetet bosh për =99% raste |
| 4 | **Pagesa / Quipu jo implementuar** | `MockPaymentMethods`; zero Quipu SDK | Nuk merret pagesë online |
| 5 | **Mungon Cloud Function `placeOrder`** | Zero references në repo | Orders write + payment verify |
| 6 | **Order success fake** | `order_success_screen.dart:53–55` hardcoded `#CP-2024-01568`, `€61,90` | Besim i ulët përdoruesi |
| 7 | **Checkout user info placeholder** | `checkout_screen.dart:138–144` email fiks, adresa bosh | Porosi me të dhëna të gabuara |
| 8 | **Adresat nuk lidhen me checkout** | Addresses CRUD veçmas | Dërgesë e pamundur e saktë |
| 9 | **Zbritje hardcoded €5** | `cart_local_datasource.dart:21` | Total i gabuar vs admin/web |
| 10 | **Pa FCM, Crashlytics, App Check, Analytics** | `pubspec.yaml` | Jo production-ready operacional |

---

## Roadmap me faza

### Phase 1 — Critical production blockers
- Lidhe **AddToCart** në product detail + grid (me quantity).
- Implemento **Cloud Function `placeOrder`** (validate cart, stock, totals, shkruaj `orders`, payment status).
- Rregullo **checkout flow**: adresë nga Firestore, user email real, pastrim cart, order ID real në success.
- Hiq ose zëvendëso **zbritjen hardcoded** me totals nga server.

### Phase 2 — Account & user data
- **Wishlist persist** (SharedPreferences + `users/{uid}/wishlist` sync).
- **Cart sync** për logged-in users (`CartFirestoreDataSource`).
- Profile read/write nga `users/{uid}`.
- Merge guest cart pas login.

### Phase 3 — Checkout & payments
- Integrim **Quipu** (ose provider tjetër) me server-side verification.
- Cash on delivery + bank transfer workflow në backend.
- Lidhe **coupons/promotions** nga Firestore.

### Phase 4 — Notifications & tracking
- **FCM** push (order status, promos).
- **Firebase Analytics** funnel events.
- **Crashlytics** + **App Check**.
- In-app notifications nga Firestore (opsionale).

### Phase 5 — Polish & release
- Global search, filter/sort i avancuar.
- i18n (Language screen real).
- Deep links / App Links.
- Error/empty states premium.
- Hiq placeholder screens ose lidhi me CMS.
- E2E tests për purchase flow.
- Verifikim final **Firestore security rules**.

---

## A është app-i production-ready tani?

### **PARTIAL**

**PO** për:
- Shfletim katalogu (produkte + kategori nga Firestore).
- Autentifikim Firebase (login, register, forgot password, logout).
- Lexim porosish historike (nëse ekzistojnë në Firestore).
- Menaxhim adresash (CRUD) për përdorues të kyçur.
- Guest cart persistence lokale (SharedPreferences).
- Wishlist in-session + UI premium.

**JO** për:
- **Blerje end-to-end** — checkout navigon te success pa krijuar porosi (`checkout_screen.dart:116`).
- **Shtim produkti në shportë nga product detail** — vetëm navigim (`product_detail_screen.dart:475–490`).
- **Pagesa** (Quipu, kartë, transfer) — mock UI pa integrim.
- **Sync cloud** për wishlist; cart discount real; notifications/messages reale.
- **Observability** (Analytics, Crashlytics, App Check, FCM).

**Përfundim:** App-i është **demo/storefront i avancuar** me auth dhe account features, por **nuk është gati për production ecommerce** derisa Phase 1–3 të përfundojnë. Mund të publikohet vetëm si **katalog + llogari** (read-only shopping), jo si dyqan që pranon porosi dhe pagesa.

---

*Audit i gjeneruar nga analiza e kodit — pa modifikime në projekt.*
