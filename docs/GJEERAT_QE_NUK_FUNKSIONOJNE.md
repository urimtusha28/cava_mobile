# Cava Premium Mobile — Çfarë ende nuk funksionon

**Data:** 18 korrik 2026  
**Metodë:** Analizë e kodit aktual (`lib/`, `pubspec.yaml`, reporte ekzistuese)  
**Shënim:** `docs/NON_FUNCTIONAL_FEATURES_AUDIT.md` (8 korrik) është **i vjetëruar**. Ky dokument pasqyron gjendjen aktuale.

---

## Verdict i shkurtër

| Pyetje | Përgjigje |
|--------|-----------|
| A funksionon katalogu / auth / cart / wishlist? | **Po** |
| A mund të bëhet porosi cash/bank? | **Po** (nëse Cloud Function `placeOrder` + rules janë live) |
| A funksionon pagesa me kartë? | **Jo** |
| A është gati për App Store / Play Store si ecommerce i plotë? | **Jo** |
| Sa afër publikimit (beta e kontrolluar, vetëm cash)? | **~70–75%** |
| Sa afër publikimit (ecommerce i plotë me kartë)? | **~55–60%** |

---

## 🔴 Nuk funksionojnë / mungojnë plotësisht

### 1. Pagesa online me kartë (Quipu / Stripe / Visa-MC)
- Në checkout shfaqet opsioni **«Kartë»** (`paymentMethod: 'card'`).
- Backend / Cloud Function pret metoda të vlefshme (p.sh. `cash`, `bank`; për kartë shpesh `stripe`) — **`card` dështon**.
- Në repo **nuk ka** SDK Quipu, Stripe, WebView pagese, 3DS, as verification server-side.
- **Rrezik:** përdoruesi mendon se pagoi me kartë, por porosia nuk kalon ose kalon pa pagesë reale.

**Skedarë:** `checkout_screen.dart`, `mock_payment_methods.dart`, `ORDER_STOCK_EMAIL_FLOW_AUDIT.md`

**Çfarë duhet:** ose fshi/disable opsionin «Kartë» derisa të jetë gati, ose integro gateway + deep link return + verify në Cloud Functions.

---

### 2. Push notifications (FCM)
- `firebase_messaging` **nuk ekziston** në `pubspec.yaml`.
- Nuk ka regjistrim token-i, background handler, as push për status porosie.

**Impakt:** klienti nuk njoftohet kur porosia ndryshon status (pavarësisht in-app notifications nga Firestore).

---

### 3. Analytics, Crashlytics, App Check
Mungojnë plotësisht në dependencies:
- `firebase_analytics`
- `firebase_crashlytics` (ose Sentry)
- `firebase_app_check`

**Impakt:** pa metrika conversion, pa raport crash-esh në prod, pa mbrojtje ndaj abuse të Firestore/Functions.

---

### 4. Deep links / Universal Links / App Links
- Navigimi i brendshëm me `go_router` funksionon.
- **Nuk ka** `app_links` / universal links për:
  - kthim nga pagesa online
  - hapje produkti nga email/marketing
  - deep link nga push

---

### 5. Tab / ekrani «Mesazhe» (fake)
- `MessagesScreen` ka listë **hardcoded** bisedash.
- Support chat real ekziston gjetiu (Firestore `supportConversations`), por ky ekran është i rremë.
- Route `/messages` mbetet i arritshëm.

**Skedar:** `lib/features/messages/presentation/screens/messages_screen.dart`

**Veprim:** fshi route-in ose ridrejto te support chat real para release.

---

### 6. Upload imazhesh (produkte / kategori / banner)
- Leximi i imazheve nga Storage URL funksionon.
- **Nuk ka** `image_picker`, `putFile`, as upload nga owner dashboard.

---

### 7. Menaxhim inventari / CRUD produktesh nga owner mobile
- Owner sheh low-stock / counts (read-only).
- **Nuk mund** të ndryshojë stok, çmim, apo të krijojë/editojë produkte nga app.

**Skedarë:** `owner_products_screen.dart`, `owner_dashboard_firebase_datasource.dart`

---

### 8. Home CMS (bannerë / seksione nga Firestore)
- Produktet në home vijnë reale nga Firestore.
- Layout-i i seksioneve vjen nga **`HomeMockDataSource`** (gjithmonë mock në DI).
- `HomeFirestoreDataSource` hedh `UnimplementedError` dhe **nuk** është wired.

**Skedarë:** `injection.dart` (`_registerHome`), `home_firestore_datasource.dart`

---

### 9. Kuponë / promocione
- Koleksioni `promotions` ekziston në `FirebaseConfig`.
- Checkout/cart: `discount = 0`; pa kod kuponi, pa validim server-side i promocioneve nga mobile.

---

### 10. Bank transfer — UX i plotë
- Opsioni «bankë» dërgohet si string te `placeOrder` (mund të krijojë porosi).
- **Mungojnë:** instruksione IBAN, referenca pagese, ekran «Pending» me hapa të qartë për klientin.

---

### 11. Package ID / Firebase sync (store readiness)
- Android: `applicationId = "com.example.cava_ecommerce"` — **jo i pranueshëm** për store publik.
- `firebase_options.dart` mund të ketë bundle ID të vjetër `com.example.*` për iOS.
- Mungon `PrivacyInfo.xcprivacy` (iOS privacy manifest) në repo.

---

### 12. Teste E2E / pajisje reale
- Ka shumë unit/widget tests (~90+ skedarë).
- **Zero** e2e për: pagesë me kartë, flow pajisje reale, TestFlight/Play internal automation.

---

## 🟡 Funksionojnë pjesërisht (me kufizime)

| Feature | Çfarë punon | Çfarë mungon |
|---------|-------------|--------------|
| **Checkout** | Cash + bank via CF `placeOrder`; guest checkout; adresë; clear cart pas suksesit | Kartë e thyer; bank pa IBAN UX |
| **Email porosi** | Resend në backend (Cloud Functions) | Soft-fail: porosia mund të suksesojë edhe pa email; mobile nuk tregon status email |
| **Njoftime in-app** | Lexim nga Firestore `users/{uid}/notifications` | Pa push FCM; pa marketing campaigns |
| **Owner dashboard** | Stats, porosi, support, ndryshim `fulfillmentStatus` | Pa CRUD produktesh, pa upload, top-sellers të kufizuara |
| **Search** | Global + filter/sort client-side | Pa Algolia / server query (OK për katalog të vogël) |
| **Legal (Terms/Privacy/Help)** | Ekrane me tekst + l10n | Jo CMS; duhen rishikuar ligjërisht para store |
| **Currency** | Route / UI | Pa FX real; çmimet gjithmonë € |
| **Maps** | Hap Google Maps via URL | Adresë/koordinata hardcoded; pa Maps SDK |
| **Error / empty states** | Disa ekrane i kanë | Jo konsistente kudo; mungojnë CTA në shumë empty states |
| **Offline** | Cache TTL 5 min + cart/wishlist persist | Pa offline write queue |

---

## ✅ Çfarë funksionon mirë (pikat e forta)

Këto **nuk** janë probleme për release beta cash:

1. **Arkitekturë e pastër** — clean architecture (domain / data / presentation), GetIt DI, Result/Failure
2. **Firebase Auth** — login, register, forgot password, logout
3. **Katalog** — produkte + kategori Firestore, imazhe Storage, cache TTL
4. **Search + filter/sort** i avancuar
5. **Cart & Wishlist** — guest local + cloud sync + merge pas login
6. **Add to cart** nga product detail me validim stoku
7. **Checkout cash/bank** — callable `placeOrder`, adresë, guest checkout, order success real
8. **Porosi klient** — listë + detail sheet
9. **Owner** — dashboard, porosi, support chat, update status përmbushjeje
10. **Support chat** real (Firestore)
11. **i18n** — Shqip / English me ARB + persistencë
12. **Test coverage** e fortë për domain/data (unit/widget)
13. **Store location** banner + Maps URL

---

## ⚠️ Pikat e dobëta (përmbledhje)

1. **Pagesa me kartë e rreme/e thyer** — bllokuesi #1 për ecommerce të plotë  
2. **Observability zero** — pa Crashlytics / Analytics / App Check  
3. **Pa FCM** — UX i dobët pas porosisë  
4. **Package ID `com.example.*`** — bllokon publikim serioz në store  
5. **UI mashtruese** — Mesazhe fake, opsion kartë, bank pa instruksione  
6. **Home ende mock** për layout  
7. **Owner mobile i kufizuar** — ops/admin i plotë mbetet në web  
8. **Legal/store compliance** i paplotë (privacy manifest, package naming, FAQ legale)  
9. **Pa deep links** — pagesa online e pamundur edhe kur Quipu/Stripe të shtohet  
10. **Firestore rules** jetojnë jashtë këtij repo — risk drift deploy

---

## Checklist para publikimit

### Beta e kontrolluar (vetëm cash / bank) — ~2–3 javë punë
- [ ] Disable ose fshi opsionin **Kartë** në checkout
- [ ] Fshi ose ridrejto **MessagesScreen** fake
- [ ] Ndrysho Android/iOS package ID nga `com.example.*`
- [ ] Sinkronizo `firebase_options` me bundle ID të ri
- [ ] Crashlytics + App Check (minimum)
- [ ] Rishiko Privacy / Terms me tekst ligjor final
- [ ] QA live: register → add to cart → checkout cash → order në Firestore → owner status update
- [ ] Konfirmo Cloud Functions + Firestore rules të deployuara
- [ ] TestFlight / Play Internal testing

### Ecommerce i plotë (kartë) — +4–8 javë
- [ ] Integrim Quipu ose Stripe (initiate + HPP/WebView)
- [ ] Deep link return success/fail/cancel
- [ ] Server-side payment verification
- [ ] FCM për status porosie
- [ ] Analytics events (view_item, add_to_cart, purchase)
- [ ] Bank transfer UX (IBAN + referencë)
- [ ] PrivacyInfo.xcprivacy + store listing assets
- [ ] E2E test i purchase flow

---

## Sa afër publikimit?

```
Catalog + Auth + Cart ████████████████████ 100%
Cash checkout         ████████████████░░░░  80%  (varet nga CF live + disable card)
Owner ops bazë        ██████████████░░░░░░  70%
Store compliance      ████████░░░░░░░░░░░░  40%
Pagesë online         ██░░░░░░░░░░░░░░░░░░  10%
Push + Analytics      ░░░░░░░░░░░░░░░░░░░░   0%
─────────────────────────────────────────────
Beta cash (kontrolluar)     ~70–75%
Release ecommerce i plotë   ~55–60%
```

**Përfundim:** App-i është **storefront i fortë + checkout cash/bank**, jo ende **dyqan online i plotë**. Mund të dalë në **beta të mbyllur** pas disable të kartës, fix package ID, Crashlytics dhe pastrim UI mashtruese. **Publikim publik si ecommerce me pagesë kartë** kërkon akoma gateway pagese + deep links + FCM + compliance store.

---

*Dokument i gjeneruar nga audit i kodit — 18 korrik 2026.*
