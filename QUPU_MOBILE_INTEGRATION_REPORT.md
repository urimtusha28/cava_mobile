# QUPU_MOBILE_INTEGRATION_REPORT

Data: 2026-07-18
Projektet: `cava` (website + Firebase Functions backend) dhe `cava_ecommerce` (Flutter).

> **Përditësim (po e njëjta datë):** Hapja e HPP u zhvendos nga browser-i i
> jashtëm në **WebView full-screen brenda aplikacionit**, me interceptim të
> return URL-së dhe fallback në browser/aplikacion të jashtëm. Backend-i,
> controller-i, statuset dhe idempotency mbeten siç përshkruhen këtu. Detajet:
> shih `QUPU_IN_APP_WEBVIEW_REPORT.md`.

---

## 1. Si funksiononte Quipu në website

Flow-i ekzistues (i verifikuar nga kodi në `/Users/urim/VscProjects/cava`):

1. **Porosia krijohet e para, në server.** `PaymentMethod.tsx` thërret callable
   `placeOrder` me `paymentMethod: "stripe"` (kod i brendshëm për kartë) dhe
   `paymentStatus` vendoset `pending` në server (`placeOrder.ts`). Stoku zbritet
   një herë të vetme brenda transaksionit të Firestore, me idempotency
   (koleksioni `placeOrderIdempotency`, TTL 24h, fingerprint server-side ose
   çelës klienti).
2. **Inicimi i pagesës.** Frontend thërret callable
   `initiateQuipuPayment(cavaOrderId)` (`functions/src/quipu/initiateQuipuPayment.ts`):
   - Shuma lexohet **vetëm nga porosia në server** — kurrë nga klienti.
   - Verifikohet pronësia e porosisë (`ORDER_OWNER_MISMATCH`) dhe refuzohet
     porosia e paguar (`ORDER_ALREADY_PAID`).
   - **Idempotency**: ritenton të njëjtin sesion — një transaksion aktiv
     (`created`/`redirect_issued`) për të njëjtën porosi ripërdoret; një
     transaksion `verified_paid` nuk ripërdoret kurrë
     (`findReusableTransaction` në `quipuTransactions.ts`).
   - Krijohet dokument në koleksionin server-only `transactions`
     (firestore.rules: `allow read, write: if false`), thirret Quipu
     `POST /order` me mTLS (certifikatat vetëm si Firebase Secrets:
     `QUIPU_CA_PEM`, `QUIPU_CERT_PEM`, `QUIPU_KEY_PEM`) dhe kthehet **vetëm
     redirect URL** i Hosted Payment Page.
3. **Pagesa bëhet vetëm në Quipu HPP** — website nuk prek kurrë të dhëna karte.
4. **Kthimi**: HPP ridrejton te `/payment/return?transactionId=...`
   (`PaymentReturnPage.tsx`), i cili thërret callable
   `verifyQuipuPayment(transactionId)`.
5. **Verifikimi server-authoritative** (`quipuReturnVerification.ts`): serveri
   pyet Quipu `GET /order/{id}` (server-to-server) dhe **vetëm** kur statusi i
   gateway-t është paid/funded/completed (`isPaidGatewayStatus`) e ngre
   porosinë në `paymentStatus: "paid"` dhe transaksionin në `verified_paid`.
   Email-i i konfirmimit për porositë me kartë dërgohet vetëm pas kalimit në
   `paid` (`functions/src/index.ts`).
6. **Shporta në web** pastrohet pas krijimit të porosisë, para redirect-it
   (sjellje ekzistuese e web-it; në mobile u zbatua rregulli më strikt — shih §5).

**Shënim mbi "webhook":** Në kodin aktual të backend-it **nuk ekziston asnjë
webhook HTTP nga Quipu** (asnjë `onRequest` handler për njoftime të gateway-t).
Burimi i së vërtetës është verifikimi server-to-server (`verifyQuipuPayment` →
Quipu `GET /order/{id}`), i cili luan rolin e "webhook-ut" në këtë arkitekturë.
Skedarët `checkoutSession.js` / `createOrderFromSession.js` ekzistojnë vetëm si
mbetje të kompiluar në `functions/lib/` pa burim përkatës në `functions/src/`.
Unable to verify from current codebase: ndonjë webhook i konfiguruar në anën e
Quipu-s jashtë këtij repo-je.

---

## 2. Çfarë u implementua në mobile

Asgjë nga Quipu nuk u rikrijua — mobile ripërdor **të njëjtat callables** të
backend-it (`placeOrder`, `initiateQuipuPayment`, `verifyQuipuPayment`), të
njëjtat statuse, të njëjtin model idempotency dhe të njëjtin koleksion
`transactions`. Asnjë secret, certifikatë apo çelës Quipu nuk ekziston në
aplikacion — vetëm URL-ja e HPP e kthyer nga backend-i.

Sipas Clean Architecture ekzistuese (data / domain / repository / use case /
controller / presentation):

- **Domain**: entitete (`QuipuInitiateResultEntity`, `QuipuVerifyResultEntity`
  me mapping konservativ të statusit, `PendingCardPayment`,
  `CardPaymentStatus`), repository abstrakt `QuipuPaymentRepository`, use cases
  `InitiateQuipuPaymentUseCase` / `VerifyQuipuPaymentUseCase`.
- **Data**: `QuipuPaymentFirebaseDataSource` (thërret callables përmes
  `FirebaseFunctionsGateway` ekzistues), `QuipuPaymentRepositoryImpl`,
  `PendingCardPaymentStorage` (SharedPreferences — ekuivalenti mobile i
  sessionStorage të web-it për transaction id).
- **Presentation**: `CardPaymentController` (state machine e plotë) dhe
  `CardPaymentScreen` (hap HPP në shfletuesin e jashtëm me `url_launcher`,
  verifikon në kthim përmes lifecycle observer + buton manual verifikimi).
- **Checkout ekzistues**: `PlaceOrderPayloadMapper` tani përkthen vlerën e UI
  `'card'` në kodin `'stripe'` që pret CF (më parë 'card' refuzohej me
  `INVALID_PAYMENT_METHOD` — pra pagesa me kartë në mobile nuk funksiononte).
  `CheckoutController.submitOrder` për kartë kthen statusin e ri
  `cardPaymentRequired` dhe **nuk** e pastron shportën.

Cash on Delivery, Bank Transfer, checkout-i, stoku, order number dhe UI-të e
tjera nuk u prekën — testet ekzistuese të tyre kalojnë të pandryshuara.

## 3. File-t e krijuar dhe ndryshuar

**Të krijuar (Flutter):**

| File | Roli |
|---|---|
| `lib/features/checkout/domain/entities/quipu_payment_entities.dart` | Entitetet + mapping statusesh + PendingCardPayment |
| `lib/features/checkout/domain/repositories/quipu_payment_repository.dart` | Kontrata e repository-t |
| `lib/features/checkout/domain/usecases/initiate_quipu_payment.dart` | Use case i inicimit |
| `lib/features/checkout/domain/usecases/verify_quipu_payment.dart` | Use case i verifikimit |
| `lib/features/checkout/data/datasources/quipu_payment_data_source.dart` | Kontrata e datasource |
| `lib/features/checkout/data/datasources/quipu_payment_firebase_datasource.dart` | Thirrjet e callables + mapping i gabimeve |
| `lib/features/checkout/data/repositories/quipu_payment_repository_impl.dart` | Implementimi i repository-t |
| `lib/features/checkout/data/local/pending_card_payment_storage.dart` | Persistenca e pagesës në fluturim |
| `lib/features/checkout/presentation/controllers/card_payment_controller.dart` | State machine e pagesës |
| `lib/features/checkout/presentation/screens/card_payment_screen.dart` | Ekrani i pagesës/verifikimit |
| `test/features/checkout/domain/entities/quipu_payment_entities_test.dart` | Teste të entiteteve/statuseve |
| `test/features/checkout/presentation/controllers/card_payment_controller_test.dart` | Teste të controller-it |

**Të ndryshuar (Flutter):**

| File | Ndryshimi |
|---|---|
| `lib/features/checkout/data/mappers/place_order_payload_mapper.dart` | `normalizePaymentMethod`: 'card' → 'stripe' |
| `lib/features/checkout/presentation/controllers/checkout_controller.dart` | Karta → `cardPaymentRequired`; shporta nuk pastrohet |
| `lib/features/checkout/presentation/models/checkout_session_state.dart` | Statusi/factory `cardPaymentRequired` |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | Navigimi te `/card-payment` |
| `lib/features/checkout/presentation/screens/order_success_screen.dart` | Etiketa 'stripe' shfaqet si kartë |
| `lib/core/router/app_routes.dart`, `lib/core/router/app_router.dart` | Route `/card-payment` |
| `lib/core/di/injection.dart` | Regjistrimet DI (`_registerQuipuPayment`, use cases, controller, storage) |
| `lib/l10n/app_sq.arb`, `lib/l10n/app_en.arb` (+ files të gjeneruar) | 18 çelësa të rinj `cardPayment*` shqip/anglisht |
| `test/features/checkout/data/mappers/place_order_payload_mapper_test.dart` | Test 'card'→'stripe' |
| `test/features/checkout/presentation/controllers/checkout_controller_test.dart` | Test: karta s'e pastron shportën |

**Backend (`/Users/urim/VscProjects/cava`): asnjë ndryshim.**

## 4. Flow-i i pagesës në mobile

```
Checkout (card) ──► placeOrder CF (paymentMethod=stripe, paymentStatus=pending,
                    stoku zbritet 1 herë, idempotency server-side)
        │
        ▼
CardPaymentScreen ──► initiateQuipuPayment CF ──► redirect URL (HPP)
        │                    (ripërdor transaksionin aktiv në retry)
        ▼
url_launcher hap HPP në shfletuesin e jashtëm (karta futet VETËM te Quipu)
        │
        ▼  (kthimi në app: lifecycle resume OSE butoni "Verifiko pagesën")
verifyQuipuPayment CF ──► Quipu GET /order/{id} (server-to-server)
        │
        ├─ verifiedPaid=true  → statusi "paid": pastro shportën + pending storage,
        │                        porosia → paymentStatus "paid" (nga backend-i)
        └─ verifiedPaid=false → pending / failed / cancelled / expired
                                 (shporta dhe porosia mbeten të paprekura)
```

Statuset e UI: `success (paid)`, `pending`, `failed`, `cancelled`, `expired`,
plus `error` i ritentueshëm për dështime rrjeti. Mapimi nga `gatewayStatus`
është konservativ: çdo status i panjohur trajtohet si `pending`, kurrë si
sukses. Unable to verify from current codebase: fjalori i plotë i statuseve që
kthen Quipu përtej atyre paid (`paid/funded/fully paid/fully funded/completed`)
— prandaj mapimi cancelled/expired/failed bëhet me përputhje teksti
(`cancel/expire/timeout/fail/decline/reject/error`) dhe bie në `pending` në
rast dyshimi.

## 5. Webhook-u, statuset, idempotency, stoku dhe shporta

- **"Webhook"/burimi i së vërtetës**: mbetet backend-i — `verifyQuipuPayment`
  pyet vetë serverin e Quipu-s dhe vetëm ai e ngre porosinë në `paid`.
  Redirect-i i suksesit në HPP nuk besohet asnjëherë nga mobile (testuar
  eksplicit: `gatewayStatus="paid"` pa `verifiedPaid` nuk jep sukses).
- **Statuset**: identike me web — porosi `pending` → `paid`; transaksion
  `created` → `redirect_issued` → `verified_paid`/`failed`.
- **Idempotency / double tap / porosi të dyfishta**:
  - `placeOrder` CF ka fingerprint idempotency server-side (24h TTL) — dy
    submit-e me të njëjtën shportë kthejnë të njëjtin `orderId` pa zbritje të
    dytë stoku; për kartë, një porosi e paguar nuk ripërdoret kurrë.
  - `CheckoutController.isSubmitting` bllokon double-tap në UI.
  - `CardPaymentController.start()` është idempotent (i njëjti order → i njëjti
    redirect pa thirrje të dytë) dhe backend-i ripërdor transaksionin aktiv.
  - `verifyNow()` bllokon thirrjet paralele dhe pas `paid` nuk thërret më
    backend-in.
- **Stoku**: zbritet vetëm një herë, në transaksionin e `placeOrder` — mobile
  nuk e prek fare stokun.
- **Shporta**: pastrohet **vetëm** pasi `verifiedPaid=true` kthehet nga
  backend-i (`CardPaymentController._onVerifiedPaid`). Në pending / failed /
  cancelled / expired / error shporta mbetet e paprekur (testuar). (Kjo është
  më strikte se web-i, i cili e pastron shportën para redirect-it.)
- **Rimëkëmbja**: pagesa në fluturim persistohet në `PendingCardPaymentStorage`;
  pas restart-i, `restorePending()` + verifikim e vazhdon flow-in.

## 6. Testet e ekzekutuara dhe rezultatet

- `flutter analyze`: **0 probleme nga ndryshimet e reja** (2 warnings
  para-ekzistuese në `add_address_bottom_sheet.dart`, skedar i paprekur).
- `flutter test test/features/checkout`: **72/72 kaluan** — përfshirë:
  - 12 teste të reja të `CardPaymentController` (double-tap, pastrim shporte
    vetëm në paid, mapimi cancelled/expired/failed, error i ritentueshëm,
    resume pas restart-i, onAppResumed);
  - 11 teste të entiteteve/statuseve Quipu;
  - test i ri 'card'→'stripe' në payload mapper;
  - test i ri që karta kthen `cardPaymentRequired` pa pastruar shportën;
  - të gjitha testet ekzistuese të checkout/cash/bank të pandryshuara.
- `flutter test` (suite e plotë): **439 kaluan, 5 dështuan — të 5 dështimet u
  verifikuan si para-ekzistuese** (dështojnë identikisht edhe në `git stash` /
  worktree të pastër të HEAD pa asnjë nga ndryshimet e këtij integrimi):
  - `test/core/di/injection_test.dart` — "No Firebase App '[DEFAULT]'" nga
    `FirebaseFirestore.instance` eager në `_registerSupport` (kod i vjetër);
  - `test/features/cart/domain/usecases/cart_usecases_test.dart` — 2 teste
    delegimi (AddToCart/UpdateCartQuantity);
  - `test/features/account/presentation/utils/order_formatters_test.dart` —
    mospërputhje stringu 'E dorëzuar' vs 'U dorëzua';
  - `test/widget_test.dart` — timeout 10-minutësh; ngec edhe në HEAD të
    pastër të izoluar.
- Backend (`cava/functions`): `npm run build` (tsc) OK dhe `npm test` —
  **122/122 teste kaluan, 21/21 suites** (përfshirë `quipuTransactions.test.ts`).
  Backend-i nuk u ndryshua fare.

## 7. Konfigurim manual i mbetur

1. **App Check**: `ENFORCE_APPCHECK_ON_CRITICAL_CALLABLES` është aktualisht OFF
   në backend (`FUNCTIONS_APPCHECK_ENFORCE` != "true") pikërisht sepse mobile
   nuk dërgon token App Check (`callableConfig.ts` e dokumenton). Për prodhim:
   shto `firebase_app_check` në Flutter dhe rikthe enforcimin.
2. **Return URL / deep link**: HPP ridrejton shfletuesin te
   `https://cava-premium.com/payment/return` (faqja web e verifikon edhe vetë —
   e padëmshme, verifikimi është idempotent). Përdoruesi kthehet manualisht në
   app dhe verifikimi ndodh në resume. Opsionale: konfiguro App Links /
   Universal Links për kthim automatik në app — kërkon konfigurim
   platformash (AndroidManifest / entitlements) dhe s'u bë pa kërkesë.
3. **Sekretet Quipu në Firebase** (`QUIPU_CA_PEM`, `QUIPU_CERT_PEM`,
   `QUIPU_KEY_PEM`) dhe env vars (`QUIPU_ENV`, `QUIPU_MERCHANT_ID`,
   `QUIPU_API_URL`, `QUIPU_HPP_RETURN_URL`): duhet të jenë të vendosura në
   projektin Firebase. Unable to verify from current codebase: vlerat aktuale
   të deploy-uara.
4. **Asnjë deploy, commit apo push nuk u bë** — sipas kërkesës.

## 8. Gati për sandbox / production?

- **Sandbox (test)**: **Gati nga ana e kodit.** Backend-i është hardcoded me
  default-e sandbox (`ECOM_TEST298`, `3dss2test.quipu.de`) dhe mobile ripërdor
  të njëjtin backend pa asnjë ndryshim. Kusht: funksionet me sekretet Quipu të
  jenë të deploy-uara (Unable to verify from current codebase: gjendja e
  deploy-it aktual).
- **Production**: **I bllokuar**, jo nga mobile: (a) `QUIPU_ENV=production` dhe
  kredencialet/certifikatat e prodhimit s'janë të konfiguruara (moduli vetë
  shënohet "not-yet-certified" në `quipuConfig.ts`); (b) App Check enforcement
  është OFF dhe mobile ende s'ka `firebase_app_check`; (c) certifikimi i
  Quipu-s për prodhim është proces jashtë këtij kodi. Unable to verify from
  current codebase: statusi i certifikimit me Quipu.
