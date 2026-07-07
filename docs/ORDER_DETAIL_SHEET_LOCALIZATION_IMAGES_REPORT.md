# Order Detail Sheet — Localization & Product Images Report

## Qëllimi

Përmirësimi i bottom sheet-it të detajeve të porosisë:
1. Statuset dhe pagesat në **shqip**
2. Produktet me **foto reale** dhe layout premium

---

## Tekste të përkthyera

### Statusi i porosisë

| Raw | Shqip |
|-----|-------|
| `open` | E hapur |
| `delivered` | E dorëzuar |
| `processing` | Në përpunim |
| `pending` | Në pritje |
| `cancelled` | E anuluar |
| `shipped` / `in_transit` | Në rrugëtim |

### Statusi i pagesës

| Raw | Shqip |
|-----|-------|
| `paid` | E paguar |
| `unpaid` | E papaguar |
| `pending` | Në pritje |
| `failed` | Dështuar |
| `refunded` | E rimbursuar |

Status i panjohur → formatim i pastër (`awaiting_pickup` → **Awaiting Pickup**), jo raw lowercase.

**Skedar:** `lib/features/account/presentation/utils/order_formatters.dart`

---

## Produktet me foto

**Skedar i ri:** `lib/features/account/presentation/widgets/order_detail_item_row.dart`

Layout premium për çdo produkt:
- **Foto majtas** (52×52 px, rounded 11, `BoxFit.cover`)
- Emri i produktit
- `quantity × price`
- **Line total djathtas** (burgundy)

Përdor `ProductImageView` + placeholder wine icon ekzistues.

### Burimi i fotos

1. `item.imageUrl` nga order item (Firestore)
2. Fallback: `productId` → `ProductRepository.getById()` → `imageUrl` / `detailImageUrl`

**Skedar:** `lib/features/account/presentation/utils/order_item_image_resolver.dart`

**Mapper:** `OrderMapper` lexon `imageUrl`, `productId` nga items (pa ndryshuar Firestore schema).

---

## Totals & Klienti

Labels në shqip (si më parë):
- Nëntotali, Zbritja, Transporti, TVSH, **Totali**
- Total final: burgundy, font më i fortë

Seksioni Klienti:
- Klienti, Emri, Telefoni, Adresa
- Rreshtat bosh **nuk shfaqen**

---

## Çfarë NUK u prek

- Routing
- Firestore schema / orders query
- Checkout, backend, web
- Profile layout jashtë bottom sheet

---

## Teste

| Test | Verifikon |
|------|-----------|
| `order_formatters_test` | Status/payment mapping shqip |
| `order_item_image_resolver_test` | imageUrl + ProductRepository fallback |
| `account_models_test` | imageUrl/productId mapping |
| `order_detail_item_row_test` | Premium row + image resolve |
| `orders_screen_test` | E dorëzuar, bottom sheet |

---

## Rezultatet

```
flutter analyze
→ No issues found!

flutter test
→ 243 tests passed
```

---

## Përmbledhje

Bottom sheet tani shfaq statuset në shqip dhe produktet si card premium me foto reale ose fallback nga katalogu i produkteve — pa route të re dhe pa ndryshime në backend.
