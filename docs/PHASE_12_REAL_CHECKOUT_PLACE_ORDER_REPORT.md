# Phase 12 — Real Checkout with placeOrder Cloud Function

**Data:** 8 korrik 2026  
**Qëllimi:** Checkout krijon porosi reale përmes Cloud Function `placeOrder` — jo success screen fake.

---

## Problemi fillestar

`CheckoutScreen` butoni **"Bli"** bënte vetëm:

```dart
context.go(AppRoutes.orderSuccess);
```

`OrderSuccessScreen` shfaqte të dhëna hardcoded (`#CP-2024-01568`, `€61,90`). Asnjë Cloud Function, asnjë pastrim shporte.

---

## Si thirret `placeOrder`

```
CheckoutScreen
  → CheckoutController.submitOrder()
    → PlaceOrderUseCase
      → CheckoutRepositoryImpl
        → PlaceOrderPayloadMapper.toPayload(...)
        → CheckoutFirebaseDataSource.placeOrder(payload)
          → FirebaseFunctionsGateway.call('placeOrder', payload)
```

**Skedarë kryesorë:**
- `lib/features/checkout/data/datasources/checkout_firebase_datasource.dart`
- `lib/core/firebase/firebase_functions_gateway.dart`
- `lib/features/checkout/data/firebase/firebase_functions_gateway_impl.dart`

---

## Payload i dërguar

**Nuk përfshin `total`** — llogaritet në server.

```json
{
  "customerType": "user",
  "customer": {
    "firstName": "Urim",
    "lastName": "Tusha",
    "fullName": "Urim Tusha",
    "email": "user@email.com",
    "phone": "+383...",
    "address": "Rruga ...",
    "city": "Prishtinë",
    "country": "Kosovë",
    "zip": "10000"
  },
  "items": [
    { "productId": "wine-001", "quantity": 2 }
  ],
  "paymentMethod": "cash|bank|card",
  "termsAccepted": true,
  "source": "mobile"
}
```

Mapper: `lib/features/checkout/data/mappers/place_order_payload_mapper.dart`

---

## Si merren user / address / cart

| Burim | Detaje |
|-------|--------|
| **Auth** | `AuthRepository.getCurrentUser()` — kërkon login; guest bllokohet |
| **Adresa** | `AddressesRepository.getAddresses()` → default (`isDefault`) ose e para |
| **Cart** | `CartRepository.getItems()` pas `hydrateFromStorage()` — vetëm `productId` + `quantity` |

**Guest checkout:** bllokuar me snackbar *"Kyçu për të vazhduar me porosinë."*

**Pa adresë:** snackbar *"Shto një adresë para porosisë."*

---

## CheckoutScreen (UI i pandryshuar në layout)

- `_UserInfoCard` tregon email/adresë/qytet/shtet nga controller (jo hardcoded)
- Butoni **"Bli"** → `submitOrder()` me loading spinner
- Validon: cart, terms, login, address
- Sukses → `context.go(orderSuccess, extra: PlaceOrderResultEntity)`
- Error → snackbar shqip

---

## Error mapping

`lib/features/checkout/data/utils/place_order_exception_mapper.dart`

| Code | Mesazh |
|------|--------|
| OUT_OF_STOCK | Një produkt nuk është më në stok. |
| PRICE_MISMATCH | Çmimi i një produkti ka ndryshuar. Rifresko shportën. |
| TERMS_REQUIRED | Duhet të pranosh kushtet. |
| UNAUTHENTICATED | Kyçu për të vazhduar. |
| RATE_LIMITED | Provo përsëri më lonë. |
| default | Porosia nuk u krijua. Provo përsëri. |

---

## Kur pastrohet cart

**Vetëm pas suksesit** të `placeOrder`:

```dart
await _clearCart();
await _cartController.load();
```

Në error — cart mbetet i paprekur.

---

## OrderSuccessScreen

- Pranon `PlaceOrderResultEntity` nga router `extra`
- Shfaq: `orderNumber` (ose fallback `orderId`), `total` real, `paymentMethod`
- Nëse mungojnë të dhëna → `GetOrderByIdUseCase` lexon nga Firestore (`orders/{id}`)

Hardcoded `#CP-2024-01568` / `€61,90` **u hoq**.

---

## Çfarë mbetet për Quipu / card payment

- **Quipu SDK/API** — pa integrim
- **Pagesë me kartë** — opsioni UI ekziston (`paymentMethod: card`) por nuk ka redirect/gateway
- **Webhook/server verify** — varet nga backend pas `placeOrder`
- **Guest checkout** — i bllokuar në këtë fazë

---

## Dependency e re

- `cloud_functions` në `pubspec.yaml`

---

## Teste

| Skedar | Mbulim |
|--------|--------|
| `place_order_payload_mapper_test.dart` | payload pa total, customer/items |
| `place_order_exception_mapper_test.dart` | error codes shqip |
| `checkout_repository_impl_test.dart` | auth/address/payload |
| `place_order_usecase_test.dart` | delegim repository |
| `checkout_controller_test.dart` | success/clear cart, errors, validation |
| `order_success_screen_test.dart` | të dhëna reale |

---

## Rezultatet

| Komandë | Rezultat |
|---------|----------|
| `flutter analyze` | **No issues found** |
| `flutter test` | **265 teste kaluan** |

---

## Rezultat final

Checkout tani krijon porosi reale përmes **`placeOrder` callable**, cart pastrohet vetëm në sukses, dhe OrderSuccessScreen shfaq të dhëna reale nga response ose Firestore.
