# Cava Premium Mobile — Full Project Status Audit

**Data:** 8 korrik 2026  
**Metoda:** Analizë statike e `lib/`, `test/`, `pubspec.yaml`, `lib/firebase_options.dart`, `docs/`, plus `firestore.rules` në backend repo (`/Users/urim/VscProjects/cava/firestore.rules` — **Not found** në këtë repo Flutter).  
**Rregulla:** Pa ndryshime kodi, pa refactor, pa deploy.

**Verifikim automatik:**
| Check | Rezultat |
|-------|----------|
| `flutter analyze` | **No issues found** (ran in ~11s) |
| `flutter test` | **371 tests passed** (85 test files) |

> **Shënim:** `docs/NON_FUNCTIONAL_FEATURES_AUDIT.md` është **i vjetëruar** (thotë p.sh. Search/Wishlist Firestore/Add-to-cart jo funksionale). Ky audit zëvendëson atë si burim të vërtetë të statusit.

---

## 1. Executive Summary

| Module | Status | Përfundim |
|--------|--------|-----------|
| Auth | ✅ Complete | Login/Register/Forgot/Logout me Firebase Auth |
| Profile | ✅ Complete | `users/{uid}` real; edit name/phone; email readonly; role/status jo në payload update |
| Products | ✅ Complete | Firestore + cache TTL + imazhe |
| Categories | ✅ Complete | Firestore + subcategory chips + filter |
| Search | ✅ Complete | Screen global, debounce, recent, filter/sort client-side |
| Filters & Sort | ✅ Complete | `ProductFilterEngine` (çmim, markë, origjinë, kategori, volum, stok, sort) |
| Wishlist | ✅ Complete | Guest prefs + Firestore + merge + remove pas add-to-cart |
| Cart | ✅ Complete | Guest prefs + Firestore + merge + quantity/remove/clear + images + badge |
| Checkout (cash path) | 🟡 Partial | `placeOrder` CF + adresë + guest block; card/bank vetëm string |
| Orders | ✅ Complete | Lista + detail sheet nga Firestore |
| Payments (Quipu/card/verify) | 🔴 Missing | Zero SDK/redirect/verification në kod |
| Bank transfer UX | 🔴 Missing | Vetëm radio opsion; pa instruksione/referencë |
| Notifications (in-app) | 🔴 Missing | Hardcoded mock UI |
| Push (FCM) | 🔴 Missing | Not found in `pubspec.yaml` / `lib/` |
| Analytics / Crashlytics / App Check | 🔴 Missing | Not found in dependencies |
| Deep linking | 🔴 Missing | Not found (`app_links` / `uni_links` / payment return) |
| Home CMS | 🟡 Partial | Produkte reale; seksionet layout nga mock |
| Messages | 🔴 Missing | Lista e hardcoded |
| Language / Currency | 🟡 Partial | UI lokale; pa persist / i18n / FX |
| Legal (Terms/Privacy/Help/About) | 🟡 Partial | Ekrane statike; pa CMS |
| Store / Maps | ✅ Complete | `VisitStoreBanner` + `url_launcher` Maps |
| Routing | ✅ Complete | `go_router` + ShellRoute + routes kryesore |
| Tests (unit/widget) | 🧪 Needs testing | 371 unit/widget; **pa e2e payment/device** |
| Production readiness | ❌ Not production ready | Catalog/cash-COD mund të demo-het; ecommerce i plotë jo |
| Firestore rules (backend) | ⚠️ Risk | Cart/wishlist/addresses exist; `transactions` server-only; status update rule soft |

---

## 2. Completed Features

### 1. Firebase Auth (login / register / forgot / logout)
- **Bën:** Auth reale me Firebase Auth; session stream; logout.
- **Skedarë:** `lib/features/account/data/datasources/auth_firebase_datasource.dart`, `auth_controller.dart`, usecases `login.dart` / `register.dart` / `forgot_password.dart` / `logout.dart`
- **Verifikuar:** `FirebaseConfig.useFirebaseAuth = true`; teste `auth_*_test.dart`

### 2. Real user profile (`users/{uid}`)
- **Bën:** Lexon/përditëson profil; create `ensureUserDocExists` me `role: client` vetëm në create; update payload **nuk** përmban `role`/`status`.
- **Skedarë:** `user_profile_firebase_datasource.dart`, `user_profile_model.dart` (`updatePayload`), `profile_controller.dart`
- **Verifikuar:** Phase 19 docs + teste profile datasource/controller

### 3. Products nga Firestore + cache
- **Bën:** Katalog, by category, offers/best sellers, detail by id; TTL memory cache 5 min.
- **Skedarë:** `product_firestore_datasource.dart`, `firebase_config.dart` (`useFirestoreProducts = true`, `firestoreCacheTtl`), `ttl_memory_cache`
- **Verifikuar:** tests product firestore + repository

### 4. Product images
- **Bën:** `ProductImageView` / Storage URL; placeholder kur mungon.
- **Skedarë:** `lib/core/widgets/product_image_view.dart`; përdorim në grid, detail, cart, wishlist, orders

### 5. Categories + subcategories
- **Bën:** Kategori Firestore; product grid; chip subcategory; renditje Red Wine pas All / Whiskey pas Gin.
- **Skedarë:** `category_firestore_datasource.dart`, `subcategory_chip_order.dart`, `category_products_controller.dart`

### 6. Product detail + Add to Cart
- **Bën:** Detaje + quantity; cart icon / “Bli” thërrasin `AddToCartUseCase` (sukses / OOS / failure).
- **Skedarë:** `product_detail_screen.dart` (`_handleAddToCart`), `product_detail_controller.dart`
- **Verifikuar:** `product_detail_controller_test.dart`, `product_detail_screen_test.dart`

### 7. Global Search + recent searches
- **Bën:** `/search`, debounce 300ms, client-side scoring mbi `getAllProducts`, recent në SharedPreferences, filtra mbi rezultate.
- **Skedarë:** `search_screen.dart`, `search_controller.dart`, `recent_search_storage.dart`
- **Home:** `CavaSearchBar(onTap: () => context.push(AppRoutes.search))` në `home_screen.dart`

### 8. Advanced Filter & Sort
- **Bën:** çmim, markë, origjinë, kategori/nënkategori, volum, vetëm në stok; sort A–Z / Z–A / price / recommended / best sellers.
- **Skedarë:** `product_filter_engine.dart`, `product_filter_state.dart`, search filter tests

### 9. Wishlist guest + cloud + merge
- **Bën:** Guest SharedPreferences; user `users/{uid}/wishlist/{productId}`; merge pas login pa dublikata; hydrate + cleanup produktesh që mungojnë; badge.
- **Skedarë:** `wishlist_local_datasource.dart`, `wishlist_firestore_datasource.dart`, `wishlist_repository_impl.dart`
- **Rules:** `match /wishlist/{entryId}` owner R/W

### 10. Wishlist → Cart success flow
- **Bën:** Pas add-to-cart SUCCESS heq nga wishlist + refresh badge; failure/OOS nuk heq.
- **Skedarë:** `wishlist_controller.dart`, `wishlist_to_cart_flow_test.dart`

### 11. Cart guest + cloud + merge
- **Bën:** Guest prefs; Firestore `users/{uid}/cart/{productId}`; merge quantity; update/remove/clear; badge; discount = 0 (jo hardcoded €5).
- **Skedarë:** `cart_local_datasource.dart`, `cart_firestore_datasource.dart`, `cart_repository_impl.dart`, `cart_merge_resolver.dart`
- **Rules:** `match /cart/{productId}` owner R/W

### 12. Cart product images
- **Bën:** `ProductImageView` në kartën e shportës.
- **Skedarë:** `cart_screen.dart`

### 13. Checkout cash path (real placeOrder)
- **Bën:** Guest block; terms; address selection + persist; callable `placeOrder`; clear cart **vetëm pas suksesit**; OrderSuccess me të dhëna reale / fallback getOrderById.
- **Skedarë:** `checkout_controller.dart`, `checkout_firebase_datasource.dart`, `firebase_functions_gateway_impl.dart`, `order_success_controller.dart`, `checkout_selected_address_storage.dart`

### 14. Addresses
- **Bën:** CRUD adresash Firestore `users/{uid}/addresses`; BottomSheet; selector në checkout.
- **Skedarë:** `addresses_firebase_datasource.dart`, `addresses_controller.dart`

### 15. Orders list + detail
- **Bën:** Query `orders` ku `userId == uid`; status + paymentStatus formatters; bottom sheet me items + images.
- **Skedarë:** `orders_firebase_datasource.dart`, `orders_screen.dart`, `order_detail_bottom_sheet.dart`

### 16. Discount cleanup
- **Bën:** `getDiscount() => 0` local + firestore; UI e fsheh kur 0.
- **Skedarë:** `cart_local_datasource.dart:74`, `cart_firestore_datasource.dart:231`

### 17. Store location / Maps
- **Bën:** Banner me foto + hap Google Maps via `url_launcher`.
- **Skedarë:** `visit_store_banner.dart`

### 18. Routing / shell navigation
- **Bën:** Splash/onboarding; ShellRoute (home/wishlist/messages/profile); cart/checkout/product/category/search/orders/addresses/legal.
- **Skedarë:** `app_router.dart`, `app_routes.dart`, `shell_scaffold.dart`

### 19. Guest merge lifecycle
- **Bën:** Auth/cart/wishlist merge + badge + listener cleanup.
- **Skedarë:** `guest_merge_lifecycle_test.dart`, cart/wishlist repositories

---

## 3. Partially Completed Features

### 1. Checkout payment methods (card / bank)
- **Funksionon:** UI radio `cash` / `card` / `bank`; string dërgohet në `placeOrder`.
- **Mungon:** Quipu redirect, 3DS, verification, bank instructions, pending payment UX.
- **Pse jo production:** Përdoruesi mund të zgjedhë “kartë” dhe të mendojë se pagesa kaloi pa gateway.
- **Prioritet:** **P0**
- **Skedarë:** `checkout_screen.dart` (`_PaymentMethodsCard`), `mock_payment_methods.dart` (label Quipu; jo i lidhur në flow-in aktiv të screen)

### 2. Home layout / CMS
- **Funksionon:** Produkte nga `ProductRepository` (Firestore); search navigon te `/search`; VisitStoreBanner.
- **Mungon:** `HomeFirestoreDataSource` → `UnimplementedError`; DI përdor `HomeMockDataSource`.
- **Prioritet:** P2
- **Skedarë:** `home_firestore_datasource.dart`, `injection.dart` `_registerHome`

### 3. Search scale
- **Funksionon:** Client-side mbi listën e produkteve (cache).
- **Mungon:** Server query / Algolia; paginim për katalog të madh.
- **Prioritet:** P2 (OK për katalog të vogël)

### 4. Language / Currency screens
- **Funksionon:** UI përzgjedhjeje lokale në state widget.
- **Mungon:** i18n (ARB/l10n), persist, ndryshim real i monedhës.
- **Prioritet:** P3
- **Skedarë:** `language_screen.dart`, `currency_screen.dart`

### 5. Legal / Help / About
- **Funksionon:** Ekrane të navigueshme me tekst/statik.
- **Mungon:** CMS / faqet zyrtare të përditësueshme; Help FAQ jo ekspanduese me përmbajtje.
- **Prioritet:** P2 para store review (Privacy/Terms reale)
- **Skedarë:** `terms_screen.dart`, `privacy_screen.dart`, `help_screen.dart`, `about_screen.dart`

### 6. Orders UX avancuar
- **Funksionon:** Listë + detail sheet + totals + status labels.
- **Mungon:** Timeline shipment, tracking number, invoice download.
- **Prioritet:** P2

### 7. Firestore rules — profile `status`
- **Funksionon:** `role` nuk ndryshohet nga update payload i app-it; rule kërkon `role` të pandryshuar.
- **Rrezik:** Rule lejon update nëse `role` i njëjtë — **`status` nuk është i mbrojtur eksplicitisht** në rule (`firestore.rules` users update). App nuk e dërgon, por klient malicioz mund ta ndryshojë status në teori.
- **Prioritet:** P1 (rules harden)

---

## 4. Missing Features

### 1. Quipu Payment Gateway + VISA/MC
- **Pse duhet:** Pagesë online reale.
- **Impact:** Ecommerce online **i bllokuar**.
- **Çfarë mungon në kod:** Not found — zero `quipu`, `initiateQuipu`, payment WebView/redirect, return URL handler.
- **Backend hints:** `transactions` collection është server-only në rules (mobile nuk lexon/shkruan).
- **Modules:** checkout/payments feature + Cloud Functions + deep link return.

### 2. Payment verification / callbacks
- **Pse:** Sukses/dështim/cancel të konfirmuara server-side.
- **Impact:** Pa këtë, “card” orders janë të pasigurta.
- **Not found in mobile code.**

### 3. Bank transfer workflow
- **Pse:** Instruksione IBAN + referencë + status Pending.
- **Impact:** Opsioni UI mashtron.
- **Not found** — vetëm `paymentMethod: 'bank'` string.

### 4. Firebase Cloud Messaging / push
- **Pse:** Order status, marketing.
- **Not found:** `firebase_messaging` jo në `pubspec.yaml`; pa push token storage.

### 5. In-app notifications reale
- **Aktualisht:** Hardcoded list në `notifications_bottom_sheet.dart`.
- **Rules:** `users/{uid}/notifications` ekziston — **mobile nuk e lexon**.

### 6. Analytics / Crashlytics / App Check / Sentry
- **Not found** në `pubspec.yaml` dhe `lib/`.
- **Impact:** Pa observabilitet production; App Check mungon për abuse protection.

### 7. Deep linking
- **Not found:** `app_links` / `uni_links`; pa payment return / product universal links.

### 8. Messages / chat
- **Aktualisht:** Fake conversations në `messages_screen.dart`.
- **Impact:** Tab “Mesazhe” jofunksional.

### 9. Offline queue / connectivity UX
- **Not found** retry queue; ka cache TTL për reads, por jo offline write queue.

### 10. Firestore rules skedar në këtë repo
- **Not found** `firestore.rules` në `cava_ecommerce` — jetojnë në `VscProjects/cava`.

---

## 5. Critical Production Blockers

### P0
1. **Quipu / card payment** — UI ekziston, gateway jo.
2. **Mos lejo “card/bank” pa flow të plotë** (ose disabled derisa Quipu/bank UX të jetë gati) — risk UX/fraud pretence.
3. **Payment verification + return deep link** — pa këtë card checkout është i rremë.
4. **Final Firestore rules audit + deploy** (cart rules; harden `status`; transaction secrecy).

### P1
5. **Crashlytics (ose Sentry)** — crashes në production të panjohura.
6. **App Check** — mbrojtje thirrjesh Functions/Firestore.
7. **Privacy / Terms** përmbajtje legale reale për store review.
8. **Push notifications** për status porosive (pritet nga userët ecommerce).

### P2
9. Home CMS reale / hiq dead `HomeFirestoreDataSource` stub.
10. Notifications UI → Firestore `notifications`.
11. Bank transfer instructions ekran.
12. Order tracking / invoice.

---

## 6. Firestore / Firebase Audit

### Collections / paths që mobile përdor (evidencë kod)
| Path | Mobile R/W | Notes |
|------|------------|-------|
| `products/{id}` | R | Public read; cache TTL |
| `categories/{id}` | R | Active categories |
| `orders/{id}` | R | Create **false** — vetëm CF `placeOrder` |
| `users/{uid}` | R/W (limited) | Profile; create client role |
| `users/{uid}/addresses/{id}` | R/W | Owner |
| `users/{uid}/wishlist/{id}` | R/W | Owner |
| `users/{uid}/cart/{productId}` | R/W | Owner — **required** for logged-in cart |
| `settings`, `pillar_cards`, `promotions`, `banners` | — | Config paths exist në `FirebaseConfig`; Home CMS **nuk** i përdor ende |
| `transactions/{id}` | **Denied** client | Quipu server-only |
| `users/{uid}/notifications` | Rules allow owner | **Mobile nuk e përdor** |

### Cloud Functions dependency (mobile)
- Callable **`placeOrder`** via `cloud_functions` → `CheckoutFirebaseDataSource`.
- **Not found** në mobile: `initiateQuipuPayment`, payment verify callables.

### Rules compatibility notes
- Cart/wishlist/addresses **aligned** me mobile (owner R/W).
- Orders create disabled for clients — korrekt për CF.
- `transactions` client-denied — korrekt; mobile must never store Quipu secrets.
- **Missing in Flutter repo:** rules file vetë — audit/deploy nga backend repo.
- **Potential gap:** user update rule nuk i bën `status`/`email` immutable në rule (vetëm app discipline për payload).

### Firebase packages në `pubspec.yaml`
Present: `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `cloud_functions`  
**Absent:** messaging, analytics, crashlytics, app_check

`firebase_options.dart`: present (FlutterFire configured).

---

## 7. Test Coverage

| Module | Test files (approx) | Status |
|--------|---------------------|--------|
| Account (auth/profile/orders/addresses) | 24 | good |
| Cart | 7 | good (incl. firestore + merge) |
| Wishlist | 7 | good (incl. to-cart flow) |
| Categories | 11 | good |
| Checkout | 8 | good unit/controller; **no live CF/e2e** |
| Products | 8 | good |
| Search | 2 | adequate unit |
| Home | 6 | unit; home still mock DS |
| Core | 11 | good |
| Payments / Quipu | 0 | **missing** |
| FCM / Analytics | 0 | **missing** |
| E2E / integration device | 0 | **missing** |

**Summary:** `flutter test` → **371 passed**. Coverage është e fortë për domain/data; mungon testet e gateway pagesës dhe e2e.

---

## 8. Roadmap

### Phase A — Pre-payment stabilization
- [ ] Disable or clearly gate `card`/`bank` në checkout derisa të jenë reale
- [ ] Harden Firestore user update rules (`status`/`email` immutable për non-admin)
- [ ] Confirm deployed rules include `cart` subcollection
- [ ] Replace Help/Privacy/Terms me tekst legal final
- [ ] Wire Home away from dead Firestore stub OR implement HomeFirestore
- [ ] Fix Messages tab (hide or real inbox) — avoid fake chats in production build

### Phase B — Quipu payment
- [ ] Cloud Function initiate payment + Hosted Page URL
- [ ] Mobile: open HPP / redirect
- [ ] Return deep link success/fail/cancel
- [ ] Server verification → update order/paymentStatus
- [ ] Never expose `quipuOrderPassword` to client (`transactions` remains server-only)
- [ ] Card UI → real flow only after verify OK

### Phase C — Notifications / App Check / Crashlytics
- [ ] Add `firebase_messaging` + token save
- [ ] Order lifecycle push templates
- [ ] Replace mock notifications sheet with `users/{uid}/notifications`
- [ ] App Check on Functions/Firestore
- [ ] Crashlytics (or Sentry) + basic Analytics purchase/search events

### Phase D — Production release
- [ ] Final UI polish (empty/error/skeletons consistency)
- [ ] Bank transfer instructions + Pending status
- [ ] Order tracking / invoice if required by ops
- [ ] Store assets: splash/icon/privacy permissions
- [ ] Release builds + TestFlight / Play internal
- [ ] Final QA checklist (auth, cart merge, cash order, card order, logout)

---

## 9. Final Verdict

| Pyetje | Përgjigje |
|--------|-----------|
| A është app-i **production ready**? | **Jo** (`❌ Not production ready`) |
| A mund të publikohet si **catalog / browse + wishlist**? | **Po, me kufizime** — katalog/search/cart lokale funksionojnë; fshi/fshi tab Mesazhe fake & notifications mock |
| A mund të publikohet si **ecommerce real** (pagesë online)? | **Jo** — Quipu/verification/deep link **missing** |
| A funksionon **cash/COD** për beta të kontrolluar? | **Po, në princip** — auth + address + `placeOrder` + cart clear — kërkon QA live me CF + rules të deployuara |
| Çfarë duhet **patjetër** para release ecommerce? | 1) Quipu+verify 2) Deep link return 3) Crashlytics/App Check 4) Rules final 5) Legal pages 6) Mos ofro card/bank fake |

### Bottom line
Mobile Cava është një **aplikacion ecommerce solid për catalog → cart → cash checkout** (fazat 11–22 të mbyllura me testë të forta).  
**Bllokuesi real për production të plotë është pagesa online (Quipu) + observabilitet + deep links**, jo katalogu apo sync i cart/wishlist.

---

## Appendix — Key evidence paths

```
pubspec.yaml
lib/firebase_options.dart
lib/core/firebase/firebase_config.dart
lib/core/di/injection.dart
lib/core/router/app_router.dart
lib/features/checkout/presentation/screens/checkout_screen.dart
lib/features/checkout/data/datasources/checkout_firebase_datasource.dart
lib/features/cart/data/datasources/cart_firestore_datasource.dart
lib/features/wishlist/data/datasources/wishlist_firestore_datasource.dart
lib/features/search/presentation/controllers/search_controller.dart
lib/core/widgets/notifications_bottom_sheet.dart   # mock
lib/features/messages/presentation/screens/messages_screen.dart  # mock
lib/features/home/data/datasources/home_firestore_datasource.dart  # UnimplementedError
../VscProjects/cava/firestore.rules   # backend rules (not in this repo)
```

**Deps abstante (explicit Not found):** `firebase_messaging`, `firebase_analytics`, `firebase_crashlytics`, `firebase_app_check`, `app_links`/`uni_links`, çdo Quipu SDK.
