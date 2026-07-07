# Orders Total and Detail Sheet Report

## Problemi

Te **Porositë e mia**, çmimi shfaqej **0,00 €** edhe kur porosia në Firestore kishte total real.

**Shkaku:** `OrderMapper` lexonte vetëm fushën top-level `total`. Në web backend, totali real zakonisht gjendet në **`totals.total`** (objekt i mbivendosur), ndërsa `total` top-level mund të jetë `0` ose të mungojë.

---

## Ku gjendet totali real në Firestore

Prioriteti i ri i mapper-it:

| Prioritet | Burimi |
|-----------|--------|
| 1 | `totals.total` |
| 2 | `total` |
| 3 | `amount` |
| 4 | `grandTotal` |
| 5 | Fallback: `sum(item.price * item.quantity)` ose `item.total` |

Shembull web schema:

```json
{
  "orderNumber": "#CP-2024-01568",
  "status": "delivered",
  "paymentStatus": "paid",
  "totals": {
    "subtotal": 8.5,
    "discount": 0,
    "shipping": 2,
    "vat": 1.5,
    "total": 12
  },
  "items": [
    { "name": "Verë", "quantity": 1, "price": 8.5, "total": 8.5 }
  ]
}
```

---

## Si u rregullua mapper-i

**Skedar:** `lib/features/account/data/mappers/order_mapper.dart`

- `resolveTotal()` — prioritet `totals.total` → `total` → `amount` → `grandTotal` → items sum
- Parse `items` me `name`, `quantity`, `price`, `lineTotal`
- Parse `totals` për subtotal, discount, shipping, vat
- Parse `customer` / `shippingAddress` për info klienti
- `orderNumber` nullable — mos përdor id të gjatë si fallback
- `OrderEntity.displayOrderNumber` → `#CP-...` ose `Porosia #XXXX` (4–6 karaktere të fundit të id)

Formatimi mbeti: **8,50 €**

---

## Order card

Shfaq:
- `displayOrderNumber` (jo id të gjatë)
- status (shqip)
- paymentStatus (shqip)
- total real
- numri i produkteve
- data

Klikimi hap bottom sheet — **pa route të re**.

---

## Bottom sheet — Detajet e porosisë

**Skedar:** `lib/features/account/presentation/widgets/order_detail_bottom_sheet.dart`

- Rounded top **28**, white, draggable, SafeArea, keyboard aware
- Title: **Detajet e porosisë**
- Order number, status, pagesa, data
- Lista produkteve (name, qty, price, line total)
- Totals: subtotal, zbritje, transport, TVSH, total
- Info klienti (emri, telefoni, adresa) nëse ekziston
- Button **Mbyll**
- Empty items: *"Nuk ka produkte në këtë porosi."*

---

## Routing

**I paprekur** — asnjë route e re, vetëm modal sheet nga `OrdersScreen`.

---

## Teste

| Test | Verifikon |
|------|-----------|
| `totals.total` mapping | Total 8.5 nga nested totals |
| Items fallback | Sum kur total mungon |
| orderNumber fallback | `Porosia #123456` |
| paymentStatus mapping | `paid` → E paguar |
| Bottom sheet opens | Detajet + Mbyll |
| Missing fields | No crash |

---

## Rezultatet

```
flutter analyze
→ No issues found!

flutter test
→ 234 tests passed
```

---

## Përmbledhje

Totali 0,00 € dilte sepse mapper-i nuk lexonte `totals.total`. Tani totali real merret me prioritet të saktë dhe fallback nga items. Klikimi i porosisë hap bottom sheet premium me detaje të plota, pa ndryshuar routing.
