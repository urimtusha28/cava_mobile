# Phase 26 — PRICE_MISMATCH Checkout Fix

**Data:** 9 korrik 2026  
**Qëllimi:** Rregulluar `PRICE_MISMATCH` në checkout mobile pa ndryshuar backend-in.

---

## Simptoma

- User i kyçur, auth OK, `placeOrder` thirret me sukses.
- Cloud Function kthen:
  - `code=failed-precondition`
  - `message=PRICE_MISMATCH`
- UI shfaq snackbar: *"Çmimi i një produkti ka ndryshuar. Rifresko shportën."*

---

## Shkaku i saktë

Backend-i (`placeOrder`) validon çdo artikull:

```ts
const dbPrice = Number(d.price) ?? 0;
const clientPrice = asNumber(item.price);
const priceOk = Math.abs(dbPrice - clientPrice) <= PRICE_EPS; // 0.01
```

Web-i dërgon `price` nga shporta (`buildOrderItemsFromCart`).

Mobile **nuk dërgonte fare** fushën `price` — vetëm `productId` + `quantity`:

```dart
// Para rregullimit
{ 'productId': item.product.id, 'quantity': item.quantity }
```

Kur `price` mungon, `asNumber(undefined)` në CF kthehet `0`.  
Çdo produkt me çmim > 0 në Firestore dështonte me `PRICE_MISMATCH`.

Kjo ishte gabim payload-i, jo problem auth-i apo total-i të llogaritur gabimisht (mobile nuk dërgon `total`/`vat`/`transport` — serveri i llogarit vetë).

---

## Analiza e flow-it

```
CheckoutScreen
  → CheckoutController.submitOrder()
    → PlaceOrderUseCase
      → CheckoutRepositoryImpl.placeOrder()
        → _loadCartItems() (hydrate + refresh çmimesh)
        → PlaceOrderPayloadMapper.toUserPayload / toGuestPayload
        → _logPlaceOrderPayload() [debug only]
        → CheckoutFirebaseDataSource.placeOrder(payload)
          → FirebaseFunctionsGateway.call('placeOrder', payload)
```

### Fushat e payload-it

| Fushë | Mobile (para) | Mobile (pas) | Backend pret |
|-------|---------------|--------------|--------------|
| `customerType` | ✅ | ✅ | `user` \| `guest` |
| `userId` | ✅ | ✅ | UID për user |
| `customer` | ✅ | ✅ | Emër, email, adresë… |
| `items[].productId` | ✅ | ✅ | ID produkti |
| `items[].quantity` | ✅ | ✅ | Sasia |
| `items[].price` | ❌ mungonte | ✅ | Krahasohet me Firestore |
| `paymentMethod` | ✅ | ✅ | `cash` \| `stripe` \| `bank` |
| `termsAccepted` | ✅ | ✅ | `true` |
| `source` | ✅ `mobile` | ✅ | Opsionale |
| `total` / `vat` / `transport` | ❌ (saktë) | ❌ (saktë) | Llogariten në server |

---

## Çfarë u rregullua

### 1. `PlaceOrderPayloadMapper` — shtuar `price`

Çdo artikull tani dërgon çmimin njësi nga `CartItemEntity.product.price`, si web-i.

### 2. `CheckoutRepositoryImpl` — rifreskim çmimesh para submit

Para ndërtimit të payload-it, çdo produkt rilexohet nga `ProductRepository.getById()` (Firestore) që të mos përdoret çmim i vjetëruar nga cache i shportës. Shporta lokale **nuk modifikohet** — vetëm payload-i i porosisë.

### 3. Debug logs (`kDebugMode` only)

Para thirrjes së CF, printohen:

- payload i plotë
- për çdo item: `productId`, `unitPrice`, `quantity`, `lineSubtotal`
- totalet nga cart: `subtotal`, `vat`, `transport`, `discount`, `total`, `paymentMethod`

Prefix: `[Checkout] placeOrder …`

### 4. DI

`CheckoutRepositoryImpl` merr `ProductRepository` në `injection.dart`.

---

## Skedarët e ndryshuar

| Skedar | Ndryshim |
|--------|----------|
| `lib/features/checkout/data/mappers/place_order_payload_mapper.dart` | `price` në `items` |
| `lib/features/checkout/data/repositories/checkout_repository_impl.dart` | refresh çmimesh + debug logs |
| `lib/core/di/injection.dart` | injektim `ProductRepository` |
| `test/features/checkout/data/mappers/place_order_payload_mapper_test.dart` | assert `price` |
| `test/features/checkout/data/repositories/checkout_repository_impl_test.dart` | mock `ProductRepository` + assert |

---

## Verifikimi

```bash
flutter analyze lib/features/checkout/ lib/core/di/injection.dart
# No issues found

flutter test test/features/checkout/data/mappers/place_order_payload_mapper_test.dart \
           test/features/checkout/data/repositories/checkout_repository_impl_test.dart
# All tests passed
```

**Test manual i rekomanduar:**

1. Shto produkt në shportë → checkout → Bli (cash).
2. Në debug console, verifiko:
   - `[Checkout] placeOrder item … unitPrice=<çmimi i Firestore>`
   - Nuk duhet më `PRICE_MISMATCH` kur çmimi nuk ka ndryshuar.
3. Nëse admin ndryshon çmimin në Firestore **pas** që user hap checkout, `PRICE_MISMATCH` duhet të mbetet (mekanizëm sigurie) — user rifreskon shportën.

---

## Çfarë nuk u prek

- Backend / Cloud Functions
- UI checkout
- Guest checkout flow
- Cart persistence dhe merge
- `PRICE_MISMATCH` error mapping në UI
- Lint config

---

## Çfarë mbetet për fazat e ardhshme

1. **UX pas PRICE_MISMATCH legjitim** — si web-i, ofro modal që shfaq çmimin e ri dhe lejon ripërpjekje (tani vetëm snackbar).
2. **Rifreskim automatik i shportës** kur CF kthen `PRICE_MISMATCH` (reload produkte + përditëso UI).
3. **VAT / transport në mobile** — përputhje me llogaritjen e serverit në ekranin e checkout (tani cart kthen 0 për guest/local).
4. **Payment `card`** — CF pranon `stripe`, jo `card`; mapping i metodës së pagesës nëse përdoret kartelë.
5. **App Check** — ri-aktivizim në prod pas integrimit mobile (Phase 25).
