# Phase 15 — Remove Hardcoded Discount

**Data:** 8 korrik 2026  
**Qëllimi:** Hiq plotësisht zbritjen fake €5 nga cart/checkout — aplikacioni nuk përdor kuponë ose promocione.

---

## Ku ishte hardcoded discount

| Skedar | Problemi |
|--------|----------|
| `lib/features/cart/data/datasources/cart_local_datasource.dart` | `static const double _discount = 5.0` dhe `getDiscount()` kthente 5 kur shporta nuk ishte bosh |
| `lib/features/cart/data/mock/mock_cart.dart` | `discount = 5.0` dhe `total = subtotal - discount + ...` |
| `lib/features/cart/presentation/screens/cart_screen.dart` | Shfaqte gjithmonë rreshtin "Zbritja" |

**Nuk u prekën:** `order_detail_bottom_sheet` (zbritje nga porosi reale Firestore), `order_mapper`, `promotionsCollection` në config.

---

## Çfarë u hoq

1. **`_discount = 5.0`** — fshirë nga `CartLocalDataSource`
2. **`getDiscount()`** — kthen gjithmonë `0`
3. **`MockCart.discount`** — ndryshuar në `0` (mock layer i cart-it)
4. **Rreshti "Zbritja" në cart** — shfaqet vetëm kur `discount > 0` (aktualisht kurrë)

---

## Si llogaritet tani totali

```
subtotal = Σ (price × quantity)
vat      = 0
shipping = 0
discount = 0
total    = subtotal + vat + shipping
```

**Shembull:** 2 × €25 = **€50** total (më parë €45 pas zbritjes fake €5).

---

## CartSummaryEntity.discount

- Field **`discount`** mbeti për kompatibilitet me UI/controller/tests
- Vlera nga repository/datasource është **gjithmonë 0**
- `CartController.discount` → `summary.discount` → 0

---

## PlaceOrder payload

`PlaceOrderPayloadMapper` **nuk dërgon**:
- `total`
- `discount`
- `coupon`

Payload mbetet: `customer`, `items`, `paymentMethod`, `termsAccepted`, `source`.

---

## Checkout UI

Checkout screen **nuk shfaqte** rresht "Zbritja" — vetëm total në footer. Nuk u ndryshua layout.

---

## UI bazë

- Cart summary: i njëjti card, por pa rresht "Zbritja" kur discount = 0
- Spacing/layout tjetër i pandryshuar
- Checkout, product detail, navigation — të paprekura

---

## Testet

| Test | Skedar |
|------|--------|
| discount is always zero | `cart_local_datasource_test.dart` |
| total equals subtotal without fake discount | `cart_local_datasource_test.dart` |
| summary.discount = 0 | `cart_repository_impl_test.dart` |
| Cart UI hides "Zbritja" | `cart_screen_test.dart` |
| payload without discount/coupon/total | `place_order_payload_mapper_test.dart` |
| add/remove/quantity regression | testet ekzistuese `cart_local_datasource_test`, `add_to_cart_flow_test` |

---

## Rezultatet

### flutter analyze
```
No issues found!
```

### flutter test
```
All tests passed!
```

---

## Rezultati final

Nuk ka më zbritje fake €5 në cart/checkout. Totalet në app përputhen me subtotalin real dhe janë më afër llogaritjes së serverit në `placeOrder`.
