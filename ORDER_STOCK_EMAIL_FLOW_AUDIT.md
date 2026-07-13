# ORDER_STOCK_EMAIL_FLOW_AUDIT

**Data e auditimit:** 12 Korrik 2026  
**Scope:** Cava Mobile (`cava_ecommerce`) + Cloud Functions backend (`cava` repo)  
**Metoda:** Vetëm read-only. Asnjë kod, rules, UI, Cloud Function ose dependency nuk u ndryshua.  
**Rregull:** Çdo pretendim mbështetet në file path + funksion. Sjelljet e paverifikueshme shënohen si `[E paverifikueshme vetëm nga repository]`.

---

## 0. Kufijtë e repository-ve

| Komponent | Path | Status në audit |
|-----------|------|-----------------|
| Flutter Mobile | `/Users/urim/StudioProjects/cava_ecommerce` | Analizuar |
| Cloud Functions / Firestore rules | `/Users/urim/VscProjects/cava` | Analizuar (repo i veçantë) |
| Folder `functions/` brenda `cava_ecommerce` | — | **Nuk ekziston** |
| `firestore.rules` brenda `cava_ecommerce` | — | **Nuk ekziston** |

Mobile thërret callable Firebase **`placeOrder`** (region `us-central1`). Implementimi server-side jeton në repo-n `cava`, jo në mobile repo.

Web dhe Mobile përdorin **të njëjtin** Cloud Function `placeOrder`. Dallimet janë vetëm në payload-in e klientit (shih §2.3).

---

## 1. Arkitektura reale e porosisë

### 1.1 Flow tekstual (implementimi aktiv)

```
ProductDetailScreen / WishlistScreen
  → ProductDetailController.addToCart / WishlistController.addToCart
  → AddToCartUseCase
  → CartRepositoryImpl
  → CartLocalDataSource (guest) | CartFirestoreDataSource (user)

CartScreen
  → CartController.updateQuantity / removeAt
  → UpdateCartQuantityUseCase / RemoveFromCartUseCase
  → (pa kontroll stoku numerik)

CheckoutScreen (“Bli”)
  → CheckoutController.submitOrder
  → PlaceOrderUseCase
  → CheckoutRepositoryImpl.placeOrder
      → _refreshItemPrices() (Firestore products/{id})
      → PlaceOrderPayloadMapper.toUserPayload | toGuestPayload
  → CheckoutFirebaseDataSource.placeOrder
  → FirebaseFunctionsGatewayImpl.call('placeOrder')
  → Cloud Function placeOrder (cava/functions)
      → validatePlaceOrderPayload
      → rate limits
      → db.runTransaction (stock + order + counter + idempotency)
      → sendPlaceOrderConfirmationEmail (jashtë transaction; best-effort)
  → ClearCartUseCase + navigim OrderSuccessScreen
```

### 1.2 Shtresat Mobile (file / class / përgjegjësi)

| Layer | File | Class / Method | Përgjegjësia |
|-------|------|----------------|--------------|
| UI Product | `lib/features/products/presentation/screens/product_detail_screen.dart` | `ProductDetailScreen._handleAddToCart` | Sasi lokale `_quantity`, thirrje add-to-cart, SnackBar |
| Controller Product | `lib/features/products/presentation/controllers/product_detail_controller.dart` | `addToCart` | Refuzon nëse `!inStock` ose `quantity <= 0` |
| UI Cart | `lib/features/cart/presentation/screens/cart_screen.dart` | `_updateQuantity` | `+`/`-` pa kufi stoku |
| Controller Cart | `lib/features/cart/presentation/controllers/cart_controller.dart` | `updateQuantity`, `load` | Delegon te use cases |
| Use case Cart | `lib/features/cart/domain/usecases/add_to_cart.dart` | `AddToCartUseCase.call` | Shton produkt në shportë |
| Repository Cart | `lib/features/cart/data/repositories/cart_repository_impl.dart` | `addProduct`, `updateQuantity` | Guest vs logged-in routing |
| Data source Cart | `cart_local_datasource.dart` / `cart_firestore_datasource.dart` | `addProduct`, `updateQuantity` | Persistencë; **pa** validim stoku |
| UI Checkout | `lib/features/checkout/presentation/screens/checkout_screen.dart` | `_handlePlaceOrder` | Butoni `Bli`, payment, terms |
| Controller Checkout | `checkout_controller.dart` | `submitOrder`, `_validateBeforeSubmit` | Validim lokal + place order + clear cart |
| Use case Order | `lib/features/checkout/domain/usecases/place_order.dart` | `PlaceOrderUseCase.call` | Wrapper repository |
| Repository Checkout | `checkout_repository_impl.dart` | `placeOrder`, `_refreshItemPrices` | Auth/adresë, rifreskim çmimi, payload |
| Mapper Payload | `place_order_payload_mapper.dart` | `toUserPayload` / `toGuestPayload` | `source: mobile`, items `{productId, price, quantity}` |
| Data source CF | `checkout_firebase_datasource.dart` | `placeOrder` | `httpsCallable('placeOrder')` |
| Gateway | `firebase_functions_gateway_impl.dart` | `call` | Firebase Functions SDK |
| Error UI | `place_order_exception_mapper.dart` | `toUserMessage` | Mapim kod → mesazh shqip |
| Success UI | `order_success_screen.dart` | `OrderSuccessScreen` | `'Porosia u Krye!'` |

**Nuk përdoret** Bloc / Cubit / Riverpod. Përdoren `ChangeNotifier` (`BaseController`) + `get_it`.

### 1.3 Backend (file / function / përgjegjësi)

| File | Function | Përgjegjësia |
|------|----------|--------------|
| `cava/functions/src/placeOrder.ts` | `placeOrder` (onCall) | Auth, validim, rate limit, transaction, email kickoff |
| `cava/functions/src/placeOrderValidate.ts` | `validatePlaceOrderPayload` | Customer, items, qty 1–99, productId regex |
| `cava/functions/src/placeOrderIdempotency.ts` | `computePlaceOrderIdempotencyDocId` | Fingerprint / client key → doc id |
| `cava/functions/src/orderNumberCounter.ts` | `allocateNextOrderNumberInTransaction` | `counters/orders` |
| `cava/functions/src/productVisibility.ts` | `isProductAvailableForSale` | `productStatus === "active"` (ose legacy pa fushë) |
| `cava/functions/src/orderConfirmationEmail.ts` | `sendPlaceOrderConfirmationEmail`, `deliverOrderConfirmation` | Resend + claim `emailStatus` |
| `cava/functions/src/emailTemplates.ts` | `buildMinimalConfirmationHtml` | HTML template |
| `cava/functions/src/resendConfig.ts` | `resendFromHeader` | From: `Cava Premium <info@cava-premium.com>` |
| `cava/functions/src/index.ts` | `sendOrderConfirmationEmail` | Firestore `orders` onCreate → email (dedupe) |

### 1.4 Koleksione / fusha stoku

| Element | Vlera reale |
|---------|-------------|
| Collection produkte | `products` |
| Collection porosi | `orders` |
| Fusha e stokut | **`stock`** (numër në dokumentin e produktit) |
| Metadata pas zbritjes | `lastStockChangeAt`, `lastStockChangeSource: "web_order"` |
| Domain mobile | Vetëm `ProductEntity.inStock` (`bool`) — sasia numerike **nuk** ekspozohet në domain |
| Mapping | `ProductMapper`: `inStock = model.stock > 0 \|\| model.inStock` |
| Source of truth gjatë porosisë | **Firestore `products/{id}.stock`** brenda transaction |
| POS / SQL | `getPosProducts` mund të sync-ojë stok në Firestore (admin). **Nuk** lexohet SQL gjatë `placeOrder`. |
| Emra të tjerë (`availableStock`, `webStock`, `posStock`, `inventory`) | **Nuk** përdoren në flow-in e porosisë mobile/CF |

### 1.5 Dallimi Mobile vs Web (i njëjti CF)

| Aspekt | Mobile | Web (`cava/src/services/orderService.ts`) |
|--------|--------|------------------------------------------|
| Callable | `placeOrder` | `placeOrder` |
| `source` | `"mobile"` | `"web"` |
| `idempotencyKey` | **Nuk dërgohet** | Opsionale |
| `discountCode` | **Nuk dërgohet** | Opsionale |
| Items | `productId`, `price`, `quantity` | + name/imageUrl/sku |
| `paymentMethod` | `cash` / **`card`** / `bank` | `cash` / **`stripe`** / `bank` |
| Guest auth | Pa Firebase Auth (null user) | Mund të përdorë anonymous auth |

---

## 2. Skenari normal (stok 10, sasi 1, sukses)

### 2.1 Hapat

1. **Product details:** Përdoruesi zgjedh sasi ≥1; `addToCart` kontrollon vetëm `inStock` (boolean), jo `requested <= stock`.
2. **Cart:** Sasia rritet/ulet lokalisht; **pa** rilexim stoku.
3. **Checkout open:** `CheckoutController.load` → cart + adresë/guest; **pa** stock revalidation.
4. **Para submit:** Validim lokal (shportë, terms, adresë/guest). `isSubmitting = true` çaktivizon butonin `Bli`.
5. **Repository:** `_refreshItemPrices` rilexon çdo produkt nga Firestore për **çmim** (jo për krahasim sasie vs stok në mobile).
6. **CF `placeOrder`:**  
   - Validim payload  
   - Rate limits  
   - Idempotency doc id (server fingerprint, sepse mobile nuk dërgon key)  
   - `runTransaction`: lexon produkte → validon availability/price/stock → zbrit `stock` → shkruan `orders/{id}` + counter + idempotency  
7. **Email:** `sendPlaceOrderConfirmationEmail` **pas** commit; dështimi nuk rollback-on porosinë.  
8. **Mobile:** `ClearCartUseCase`; navigim te `OrderSuccessScreen` me `'Porosia u Krye!'`.

### 2.2 Përgjigjet e pyetjeve

| # | Pyetje | Përgjigje nga kodi |
|---|--------|-------------------|
| 1 | Ku kontrollohet sasia | Mobile: `quantity <= 0` në add/cart DS. Backend: `qty` 1–99 në validate; pastaj `cur >= need` në transaction |
| 2 | Kur kontrollohet stoku | Në add-to-cart (boolean); **në backend** brenda transaction para write |
| 3 | Frontend dhe/apo backend | Boolean në FE; kontrolli real sasie **vetëm backend** |
| 4 | A rilexohet stoku para create | Po, `transaction.get(products/{id})` |
| 5 | A zbritet stoku | Po |
| 6 | Kur zbritet | Brenda të njëjtit transaction, **para** `transaction.set(orderRef)` (writes: stock update, pastaj order) |
| 7 | Firestore transaction | Po — `db.runTransaction` |
| 8 | Batched write i veçantë | Jo — writes brenda transaction |
| 9 | Order para/pas stock | Në të njëjtin transaction; stock update dhe order set janë atomikë |
| 10 | Status porosi | `status: "open"`, `fulfillmentStatus: "received"`, `paymentStatus: "unpaid"` (cash) ose `"pending"` (bank/stripe) |
| 11 | Response mobile | `{ orderId, totals, discount? }` → `PlaceOrderResultEntity` |
| 12 | Mesazhi UI | `'Porosia u Krye!'` / `'Faleminderit për besimin tuaj.'` |
| 13 | Email | Pas success; Resend; recipient = `order.customer.email` |

### 2.3 Flow i shkurtër

```
Product Screen → Cart → Checkout → PlaceOrderUseCase → CheckoutRepositoryImpl
  → CF placeOrder → Stock validation (transaction) → Stock decrement + Order create
  → Email (best-effort) → Success UI + clear cart
```

---

## 3. Email i konfirmimit

| Pyetje | Gjetje |
|--------|--------|
| Funksioni që dërgon | `deliverOrderConfirmation` / `sendPlaceOrderConfirmationEmail` në `orderConfirmationEmail.ts` |
| Brenda placeOrder apo tjetër | **Të dyja:** (1) inline në fund të `placeOrder`; (2) trigger `sendOrderConfirmationEmail` onCreate në `index.ts` |
| Provider | **Resend** (`functions.config().resend.key`) |
| From | `Cava Premium <info@cava-premium.com>` (`resendConfig.ts`) |
| To | Vetëm `order.customer.email` (lowercase) — **jo** admin BCC në këtë flow |
| Admin/biznes | **Nuk** dërgohet email admin në `deliverOrderConfirmation` |
| Template | HTML: `buildMinimalConfirmationHtml` në `emailTemplates.ts` |
| PDF | `generateInvoicePdf` si attachment (nëse dështon, email pa PDF) |

### 3.1 Të dhënat në email

| Fushë | Përfshihet? |
|-------|-------------|
| Numri i porosisë (`orderNumber`) | Po (`resolveOrderNumber`; fallback `ORD-xxxxxx`) |
| Firestore document ID | **Jo** në body-n e klientit (qëllimisht) |
| Produkte, sasi, çmime | Po |
| Adresa | Po (faturim/dërgesë) |
| Mënyra e pagesës | Po (`paymentMethodDisplay`) |
| Statusi i pagesës | Po |
| Totali | Po |
| Transporti | Po (nga `totals.shipping`) |
| Zbritja | Po nëse `totals.discount > 0` |

### 3.2 Dështimi i email-it

| Pyetje | Sjellja aktuale |
|--------|-----------------|
| A anulohet porosia | **Jo** — koment eksplicit në `placeOrder.ts` |
| A mbetet porosia | **Po** |
| Retry automatik | Claim `emailStatus`; onCreate mund të provojë nëse jo `sent`/`sending`; **nuk** ka queue `emailJobs` |
| Status email | `emailStatus`: `sending` / `sent` / `failed` / `awaiting_payment`; `emailError` |
| A konsiderohet porosia e dështuar nga mobile | **Jo** — mobile merr success, pastron shportën |
| Duplikat email | Mbrojtje me transaction claim (`emailStatus: "sending"`) midis placeOrder dhe onCreate |
| Stripe/card awaiting | `isCardAwaitingPayment` → defer derisa pagesa; mobile dërgon `card` jo `stripe` (shih Gjetja 1) |

### 3.3 Risqe email

- Sukses UI + cart i zbrazur edhe kur klienti nuk merr email.
- Logging i `customerEmail` full në disa `obsLog` (PII).
- Idempotency email e mirë për dual-path; retry i Resend pas `failed` **nuk** është automatic job queue.

---

## 4. Produkt me stok 0

### 4.1 Product card / list

- Produkti **mund** të shfaqet (nuk fshihet automatikisht nga katalogu kur `stock === 0`).
- Nuk u gjet overlay/tekst “Out of stock” / “Nuk ka stok” në `product_grid_card.dart` / `product_card.dart`.
- Filter opsional: `'Vetëm në stok'` në `product_filter_bottom_sheet.dart`.
- **[Nuk ekziston feedback i qartë për përdoruesin]** në kartë për stok 0.

### 4.2 Product details

- Hapja lejohet.
- `ProductEntity` ka vetëm `inStock`; UI **nuk** çaktivizon butonat shportë / “Bli tani”.
- Pas klikimit: SnackBar `'Produkti nuk është në stok.'` (`AddToCartResult.outOfStock`).

### 4.3 Cart

- Një produkt që ishte në stok dhe pastaj kalon në 0 **mund** të mbetet në cart (hydrate nuk heq për `inStock == false`, vetëm për `getById == null`).
- **Nuk** ka revalidim stoku kur hapet cart.
- **Nuk** ka warning, auto-remove, apo bllokim checkout për stok 0 në UI.

### 4.4 Checkout / Backend

- Mobile **nuk** bën kontroll real sasie para CF.
- Backend: `cur < need` → `HttpsError failed-precondition` message `OUT_OF_STOCK`, details `{ code, productId }` (pa `availableQty`, pa emër produkti).
- Porosia **nuk** krijohet; stoku **nuk** shkon negativ; email **nuk** dërgohet.
- Mesazhi mobile: `'Një produkt nuk është më në stok.'` — **pa** identifikim produkti/sasie.

---

## 5. Kërkohen 3, stoku është 2

| Layer | Sjellja aktuale |
|-------|-----------------|
| Product details | `+` pa max të lidhur me stok; sasia 3 **lejohet** |
| Cart | Rritja 2→3 **lejohet**; pa validim asinkron; **nuk** kthehet në 2 |
| Checkout | Butoni nuk bllokohet për këtë arsye; **nuk** shfaq “Vetëm 2 copë…” |
| Backend | `need=3`, `cur=2` → `OUT_OF_STOCK` brenda transaction; **pa** partial order |
| Error details | Vetëm `productId` |
| Mobile UX | `'Një produkt nuk është më në stok.'` — frontend **nuk** lexon available qty nga error |

---

## 6. Disa produkte (A ok, B mungesë, C ok)

Brenda `placeOrder` transaction:

1. Lexohen **të gjitha** produktet unike.
2. Validohen të gjitha (ekzistencë, availability, price, stock parse).
3. Agregohen sasitë (`qtyNeededByProduct`).
4. Nëse **ndokush** dështon (`cur < need`) → throw → **e gjithë** transaction anulohet.
5. **Nuk** krijohet porosi pjesërishe.
6. **Nuk** ulet sasia e B automatikisht.
7. **Nuk** zbritet stoku i A/C nëse B dështon (atomik).
8. Email **nuk** dërgohet.

Mobile: mesazh i përgjithshëm OUT_OF_STOCK; **nuk** tregon cili produkt (A/B/C).

---

## 7. Race conditions (stok 1, dy përdorues)

| Kontroll | Status |
|----------|--------|
| Transaction | Po |
| Rilexim dokumenti brenda transaction | Po |
| Reads para writes | Po (koment + strukturë në `placeOrder.ts`) |
| Retry-on-conflict Firestore | Po (sjellje standarde e SDK) |
| Dy porosi për të njëjtën copë | Parandaluar nga transaction + `cur < need` |
| Stok negativ | Parandaluar (`next = cur - need` vetëm pas check) |
| Success i gabuar | Jo — njëri dështon me OUT_OF_STOCK |
| Dy email për dy porosi valide | Vetëm nëse dy porosi të ndryshme kalojnë (stok i mjaftueshëm); për stok 1 vetëm një porosi |
| Order + stock atomik | Po |
| Locking tjetër | Idempotency fingerprint + rate limits (jo lock inventari i veçantë) |

**Verdict race/stock:** **Safe** (brenda Firestore; bazuar në `runTransaction` + checks në `placeOrder.ts`).

---

## 8. Stoku ndryshon gjatë checkout-it

1. Cart/checkout mbajnë sasi lokale; stoku numerik **nuk** ruhet në cart entity.
2. Në submit, mobile rifreskon **çmimin**, jo krahasimin e sasisë me stok.
3. Backend rilexon stokun real → refuzon me `OUT_OF_STOCK` nëse `need > cur`.
4. Cart **nuk** rifreskohet automatikisht me sasi të re.
5. **Nuk** thuhet “tani ka vetëm 1”.
6. **Nuk** ulet sasia automatikisht.
7. Formular/adresa: mbeten në controller state pas error (nuk ka navigim away); `isSubmitting` kthehet false.
8. Shporta **nuk** pastrohet në error (clear vetëm në success).

---

## 9. Produkte hidden / të fshira / pa çmim

| Skenar | Mobile | Backend |
|--------|--------|---------|
| `productStatus` draft/hidden | `getProductById` kthen `null`; hydrate cart **fshin** rreshtin | `PRODUCT_UNAVAILABLE` |
| Dokument i fshirë | `getById` null → heq nga cart në hydrate | `OUT_OF_STOCK` (snap mungon) |
| Në checkout mid-session, produkt bëhet hidden | `_refreshItemPrices` bën `latest ?? item.product` → **mban snapshot të vjetër** | CF refuzon `PRODUCT_UNAVAILABLE` |
| Çmim invalid / mismatch | Mobile dërgon price të rifreskuar ose stale | `PRICE_MISMATCH`; në order ruhet **dbPrice** |

Mobile **nuk** mapon `PRODUCT_UNAVAILABLE` në `PlaceOrderExceptionMapper` / `_codeFromMessage` → bie te mesazhi default ose `error.message` raw.

---

## 10. Siguria e çmimit dhe sasisë

| Kontroll | Verdict |
|----------|---------|
| Klienti dërgon çmim për artikull | Po (`items[].price`) |
| Backend i beson çmimit të klientit për total | **Jo** — krahasim ±0.01, ruhet `dbPrice` |
| Rilexim çmimi nga Firestore | Validated in both (mobile refresh + CF) |
| Manipulim çmimi në request | Backend refuzon `PRICE_MISMATCH` — **Validated in backend** |
| Quantity negative | FE: refuzohet ≤0; BE validate: `< 1` → `INVALID_QUANTITY` — **both** |
| Quantity 0 | **both** (refuzuar) |
| Decimal quantity | Mobile UI int; BE `Number.isFinite` **pa** `Number.isInteger` — **Not validated** (integer) në backend |
| Product ID inekzistent | BE `OUT_OF_STOCK` — **backend** |
| I njëjti productId disa herë | BE agregon sasitë — **backend** |
| Max qty për produkt | BE `MAX_QTY = 99` — **backend**; FE **pa** max stoku |
| Max items për porosi | BE `items.length` 1–120 — **backend** |
| Total/VAT/shipping nga klienti | Mobile **nuk** i dërgon; server i llogarit |

---

## 11. Idempotency

| Aspekt | Gjetje |
|--------|--------|
| Client idempotency key (mobile) | **Nuk** dërgohet |
| Server fingerprint | Po — items+qty+email+paymentMethod+discount+scope; TTL **24h** (`PLACE_ORDER_IDEMPOTENCY_TTL_MS`) |
| Collection | `placeOrderIdempotency` |
| Replay | Kthen `orderId` ekzistues pa transaction të ri të stokut |
| Double-click UI | `isSubmitting` + `enabled: !_controller.isSubmitting` |
| Network retry i njëjtë fingerprint | Replay → e njëjta porosi (mirë për timeout) |
| Porosi e qëllimshme e dytë identike brenda 24h | Mund të kthejë porosinë e parë (pa stok të ri / pa email të ri nëse tashmë sent) |
| CF retry + email | Claim `emailStatus` redukton duplikatet |
| Requests paralel me payload të ndryshëm | Dy porosi të ndara (nëse stoku lejon) |

---

## 12. Tabela e gabimeve dhe UI feedback

| Skenari | Backend behavior | Mobile behavior | Mesazhi real | Problem |
|---------|------------------|-----------------|--------------|---------|
| Porosia me sukses | Transaction OK + email best-effort | Clear cart → OrderSuccess | `Porosia u Krye!` | Email fail i padukshëm për user |
| Stok 0 | `OUT_OF_STOCK` | SnackBar error | `Një produkt nuk është më në stok.` | Pa emër/sasi; UI add-to-cart: `Produkti nuk është në stok.` |
| Kërkohen 3, ka 2 | `OUT_OF_STOCK` | SnackBar | `Një produkt nuk është më në stok.` | Pa “vetëm 2 në dispozicion” |
| Një nga disa pa stok | E gjithë porosia refuzohet | SnackBar | `Një produkt nuk është më në stok.` | Pa identifikim produkti |
| Produkti nuk ekziston | `OUT_OF_STOCK` | SnackBar | `Një produkt nuk është më në stok.` | I njëjti mesazh si stoku |
| Produkt hidden/draft | `PRODUCT_UNAVAILABLE` | Default / raw | `Porosia nuk u krijua. Provo përsëri.` (tipikisht) | Kodi nuk mapohet |
| Çmimi ndryshon | `PRICE_MISMATCH` | SnackBar | `Çmimi i një produkti ka ndryshuar. Rifresko shportën.` | Nuk auto-refresh cart UI |
| Network timeout | Varion | Default ose exception map | `Porosia nuk u krijua. Provo përsëri.` | Mund të ketë porosi të krijuar + fingerprint replay |
| CF internal error | `internal` | Default | `Porosia nuk u krijua. Provo përsëri.` | — |
| Permission denied | p.sh. `AUTH_USER_MISMATCH` | Mapped | `Sesioni i llogarisë nuk përputhet. Dil dhe kyçu përsëri.` | — |
| Email dështon | Order mbetet; `emailStatus=failed` | Success UI | `Porosia u Krye!` | User mendon që gjithçka OK pa email |
| Request i dyfishtë | Idempotency replay | Success me të njëjtin orderId | Success | OK për retry; risk për reorder të qëllimshëm |
| User jo auth (user flow) | `AUTH_USER_MISMATCH` / unauthenticated | Mapped | `Kyçu për të vazhduar.` | — |
| Address invalid / mungon | Validim FE/repo | Validation | `Shto ose zgjidh një adresë.` | — |
| Guest info incomplete | FE + BE `INVALID_CUSTOMER` | Mapped | `Plotëso të dhënat për dorëzim.` / `Të dhënat e dorëzimit nuk janë të vlefshme.` | — |
| Payment `card` | `INVALID_PAYMENT_METHOD` | Mapped | `Metoda e pagesës nuk është e vlefshme. Zgjidh para në dorë ose bankë.` | Opsioni UI “Paguaj me kartel” është i thyer |
| Terms jo | Vetëm FE | Validation | `Duhet të pranosh kushtet.` | BE nuk enforce `TERMS_REQUIRED` |
| Rate limit | `RATE_LIMITED` | Mapped | `Provo përsëri më vonë.` | — |

---

## 13. Logging dhe observability

### Mobile
- `debugPrint` në `kDebugMode`: `[Checkout] placeOrder…`, payload, item prices, auth uid/email.
- **Nuk** ka Crashlytics/Sentry në këtë repo (sipas kërkimit të kodit).
- Production: logging i kufizuar.

### Cloud Functions
- `obsLog` strukturuar (`observability.ts`): orderId, correlationId (=orderId), authUid, stock decrements, OUT_OF_STOCK me productId + requestedQty + currentStock (në log, jo në client error details për qty).
- Email events: sent/failed/skip.
- `auditLogs` për gabime kritike.
- Disa log-e përfshijnë `customerEmail` full.

**Verdict observability:** **Pjesërisht e mjaftueshme** (backend i mirë; mobile production i dobët; PII në email logs; klienti nuk merr availableQty).

---

## 14. Firestore / data consistency

| Collection / Document | Read | Write | Transactional | Purpose |
|----------------------|------|-------|---------------|---------|
| `products/{id}` | Po | Update `stock` + metadata | Po (në placeOrder) | Source of truth stok |
| `orders/{id}` | — | Create | Po | Porosia |
| `counters/orders` | Po | Increment | Po | `orderNumber` |
| `placeOrderIdempotency/{hash}` | Po | Set | Po | Dedupe |
| `settings/store` | Po (cache jashtë tx) | Jo nga placeOrder | Jo | VAT rate |
| `discounts/{id}` | Po | usage++ | Po (nëse kod) | Zbritje — mobile nuk dërgon kod |
| `rate_limits` | — | Po | Jashtë tx kryesor | Anti-abuse |
| `stats` / `statsDaily` | — | Trigger onCreate | Jashtë placeOrder tx | Analytics |
| `auditLogs` | — | Gabime kritike | Jo | Audit |
| `users/{uid}/cart/{productId}` | Mobile | Mobile | Jo CF | Shporta e userit |
| Email jobs collection | — | — | — | **Nuk ekziston** |

### Consistency notes
- Stock + order janë atomikë.
- Email, stats triggers, rate limits janë **side effects** pas / jashtë transaction.
- Nëse email dështon: order + stock update mbeten (by design).
- Nëse stats trigger dështon: `[E paverifikueshme plotësisht në runtime]`; kodi i trigger-it është i ndarë.
- Orphan orders nga stock failure: **jo** (transaction rollback).
- Orphan: porosi pa email — **po**, e mundur.

---

## 15. Klasifikimi i problemeve

### Gjetja 1 — `paymentMethod: "card"` vs backend `"stripe"`

**Severity:** Critical  
**Status:** Confirmed  
**Layer:** Mobile / Backend  
**Files:**
- `lib/features/checkout/presentation/screens/checkout_screen.dart` (`_payment`, value `'card'`)
- `cava/functions/src/placeOrder.ts` (`methods = ["cash", "stripe", "bank"]`)

**Sjellja aktuale:** UI ofron “Paguaj me kartel”; CF refuzon me `INVALID_PAYMENT_METHOD`.  
**Pse është problem:** Rruga e pagesës me kartë në mobile nuk funksionon.  
**Skenari:** User zgjedh kartë → `Bli` → mesazhi për metodë të pavlefshme.  
**Prova:** Checkout dërgon `_payment`; CF `methods.includes`.  
**Ndikimi:** UX / humbje financiare (kartë e bllokuar) / support.  
**Drejtim:** Mapo `card`→`stripe` ose ndrysho UI value; mos implemento tani.

---

### Gjetja 2 — Nuk ka kufizim sasie kundrejt stokut numerik në UI

**Severity:** High  
**Status:** Confirmed  
**Layer:** Mobile / UI / Domain  
**Files:**
- `product_entity.dart` (vetëm `inStock`)
- `product_detail_screen.dart` (`_QuantityControl` pa max)
- `cart_screen.dart` (`onIncrease` pa limit)

**Sjellja aktuale:** User mund të vendosë sasi > stok; dështimi zbulohet vetëm në CF.  
**Pse:** Over-ordering UX; more load; mesazh i paqartë.  
**Ndikimi:** UX i paqartë / support.  
**Drejtim:** Ekspozo `stock` në domain dhe kufizo selector/cart.

---

### Gjetja 3 — `OUT_OF_STOCK` pa availableQty / emër produkti në client

**Severity:** High  
**Status:** Confirmed  
**Layer:** Backend / Mobile / UI  
**Files:**
- `placeOrder.ts` (details vetëm `productId`)
- `place_order_exception_mapper.dart`

**Sjellja aktuale:** Mesazh i përgjithshëm; logs backend kanë `requestedQty`/`currentStock`.  
**Ndikimi:** UX / support.  
**Drejtim:** Zgjero details + mapim UI për produkt + sasi të disponueshme.

---

### Gjetja 4 — `PRODUCT_UNAVAILABLE` i pamapuar në mobile

**Severity:** High  
**Status:** Confirmed  
**Layer:** Mobile  
**Files:**
- `placeOrder.ts` (throw `PRODUCT_UNAVAILABLE`)
- `place_order_exception_mapper.dart` / `checkout_firebase_datasource.dart` (`_codeFromMessage` listë)

**Sjellja aktuale:** Mesazh default ose raw CF message.  
**Ndikimi:** UX i paqartë.  
**Drejtim:** Shto case + mesazh shqip.

---

### Gjetja 5 — Sukses porosi + clear cart edhe kur email dështon

**Severity:** High  
**Status:** Confirmed  
**Layer:** Backend / Email / Mobile  
**Files:**
- `placeOrder.ts` (try/catch email)
- `checkout_controller.dart` (clear cart on success)

**Sjellja aktuale:** Order + stock OK; `emailStatus=failed`; user sheh success.  
**Ndikimi:** Support / email i gabuar (mungesë).  
**Drejtim:** Mos e trajto email-in si soft-fail të padukshëm në UX; alert/ops retry.

---

### Gjetja 6 — Idempotency fingerprint pa client key (mobile)

**Severity:** Medium  
**Status:** Confirmed  
**Layer:** Backend / Mobile  
**Files:**
- `placeOrderIdempotency.ts`
- `place_order_payload_mapper.dart` (pa `idempotencyKey`)

**Sjellja aktuale:** Dy submit identikë brenda 24h mund të kthejnë të njëjtin `orderId`.  
**Ndikimi:** Porosi “duplikate” të qëllimshme të bllokuara; ose OK për retry.  
**Drejtim:** Dërgo UUID `idempotencyKey` per attempt nga mobile.

---

### Gjetja 7 — Nuk ka UI out-of-stock / butona aktivë

**Severity:** Medium  
**Status:** Confirmed  
**Layer:** UI  
**Files:**
- `product_detail_screen.dart`
- `product_grid_card.dart`

**Sjellja aktuale:** Produkti hapet; butonat aktivë; feedback vetëm pas klikimit.  
**Ndikimi:** UX.  
**Drejtim:** Badge + disable CTA kur `!inStock`.

---

### Gjetja 8 — Cart nuk revalidon stokun

**Severity:** Medium  
**Status:** Confirmed  
**Layer:** Mobile  
**Files:**
- `cart_firestore_datasource.dart` / `cart_local_datasource.dart`
- `checkout_repository_impl.dart` (`_refreshItemPrices` vetëm price)

**Sjellja aktuale:** Articuj OOS mbeten; problemi zbulohet në CF.  
**Ndikimi:** UX.  
**Drejtim:** Revalidate stock në load cart/checkout.

---

### Gjetja 9 — `_refreshItemPrices` ruan produkt stale kur `getById` është null

**Severity:** Medium  
**Status:** Confirmed  
**Layer:** Mobile  
**Files:**
- `checkout_repository_impl.dart`

**Sjellja aktuale:** `latest ?? item.product` — mund të dërgojë item të fshehur/fshirë te CF.  
**Ndikimi:** Error i vonë; jo data corruption (CF refuzon).  
**Drejtim:** Hiq item ose fail validation lokalisht.

---

### Gjetja 10 — Quantity decimal e lejuar nga validimi BE

**Severity:** Medium  
**Status:** Confirmed (kodi); exploit nga mobile UI jo i drejtpërdrejtë  
**Layer:** Backend  
**Files:**
- `placeOrderValidate.ts` (`Number.isFinite`, jo integer)

**Sjellja aktuale:** `1.5` kalon validate; pastaj përdoret në llogaritje.  
**Ndikimi:** Data inconsistency / stok.  
**Drejtim:** Kërko `Number.isInteger(qty)`.

---

### Gjetja 11 — TERMS_REQUIRED vetëm në klient

**Severity:** Low  
**Status:** Confirmed  
**Layer:** Mobile / Backend  
**Files:**
- `checkout_controller.dart`
- `placeOrder.ts` (ruan `termsAccepted` nëse true, **nuk** throw TERMS_REQUIRED)

**Ndikimi:** Compliance (nëse kërkohet enforce server).  
**Drejtim:** Enforce në CF.

---

### Gjetja 12 — PII email në logs

**Severity:** Medium  
**Status:** Confirmed  
**Layer:** Email / Backend  
**Files:**
- `orderConfirmationEmail.ts` (`customerEmail` në logBase)

**Ndikimi:** Privacy.  
**Drejtim:** Logo vetëm domain (`recipientDomain` ekziston por nuk zëvendëson gjithmonë).

---

### Gjetja 13 — Domain stock boolean; source of truth i fshehur nga UI

**Severity:** Low  
**Status:** Confirmed  
**Layer:** Domain / Data  
**Files:**
- `product_entity.dart`, `product_mapper.dart`, `product_model.dart` (`stock`)

**Ndikimi:** Pengon UX të saktë për sasi.  
**Drejtim:** Shto `stock` në entity.

---

## 16. Përmbledhje ekzekutive

### Executive Summary

- Procesi i porosisë **cash/bank** është i strukturuar mirë në backend me Firestore transaction.
- Kontrolli i stokut në **backend është i sigurt** kundër overselling dhe stokut negativ (brenda modelit Firestore).
- **Overselling concurrent:** i parandaluar nga transaction.
- **Email flow:** i dobishëm (Resend + dedupe), por **jo i garantuar** për UX — dështimi nuk ndikon success-in e porosisë.
- **Feedback përdoruesi** për stok/sasinë është i dobët (mesazhe të përgjithshme; pa limite UI).
- **Pagesa me kartë në mobile nuk është production-ready** (`card` ≠ `stripe`).
- Sistemi mobil për porosi cash/bank: **production-ready with issues**; për kartë + UX stoku: **jo**.

### Current Flow Verdict

**Not production-ready** (për shkak të pagesës me kartë të thyer + UX stoku të dobët),  
me nënvizim: **stock/order core në backend = Safe** (jo “Critical stock/order risks” për race overselling).

Nëse vlerësohet vetëm cash/bank + stock atomicity: do të ishte **Production-ready with minor issues**.  
Duke përfshirë mobile card + stock UX + email soft-fail: **Not production-ready**.

### Top 5 Risks

1. **Critical:** `card` vs `stripe` — pagesa me kartë e thyer në mobile.  
2. **High:** Mungesa e limiteve të sasisë në UI kundrejt stokut.  
3. **High:** Error OUT_OF_STOCK pa available quantity / emër për user.  
4. **High:** Email fail → user sheh success + cart cleared.  
5. **High:** `PRODUCT_UNAVAILABLE` i pamapuar në mobile.

### Confirmed Behaviors

- Callable i vetëm i porosisë nga mobile: `placeOrder`.
- Stock field: `products.stock`; zbritje me `lastStockChangeSource: "web_order"`.
- Multi-item all-or-nothing në një transaction.
- Çmimi autoritativ nga Firestore; client price vetëm për match.
- Email Resend te klienti; dual-path me `emailStatus` claim.
- Mobile dërgon `source: "mobile"`, pa discount/idempotencyKey.
- Clear cart vetëm pas success CF.
- Race stoku: Safe.

### Unverified Behaviors

- Konfigurimi real i deploy-uar i Firebase / secrets Resend: `[E paverifikueshme vetëm nga repository]`
- Dashboard Resend / deliverability: `[E paverifikueshme…]`
- Të dhëna reale Firestore / POS SQL production: `[E paverifikueshme…]`
- Runtime logs production: `[E paverifikueshme…]`
- Nëse App Check është enforced në prod: `[E paverifikueshme…]`
- Nëse TTL policy GCP është aktiv për `placeOrderIdempotency`: dokumentuar në kod/setup md, runtime `[E paverifikueshme…]`

### Recommended Fix Order

1. **P0:** Rregullo mapping `paymentMethod` card/stripe (ose fshi opsionin kartë derisa Quipu të jetë wired në mobile).  
2. **P1:** Backend error details (productId, name, availableQty, requestedQty) + mapim mobile (`OUT_OF_STOCK`, `PRODUCT_UNAVAILABLE`).  
3. **P2:** Limite sasie në product/cart bazuar në `stock`; revalidim në checkout; UI out-of-stock.  
4. **P3:** IdempotencyKey per-attempt nga mobile; UX/ops për email failure; integer qty enforce; redukto PII në logs; TERMS në CF.

---

*Fund i auditimit. Asnjë ndryshim funksional nuk u krye përveç krijimit të këtij dokumenti.*
