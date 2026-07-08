# Phase 22 — Fix Product Images in Cart

**Data:** 8 korrik 2026  
**Qëllimi:** CartScreen të shfaqë foton reale të produktit me `ProductImageView`, jo ikonën placeholder.

---

## Root cause

**UI-only.** `_CartItemCard` në `cart_screen.dart` hardcodonte:

```dart
Icon(Icons.wine_bar_outlined, ...)
```

`CartItemEntity.product` është `ProductEntity` i plotë (nga add ose hydrate via `ProductRepository.getById`) me `imageUrl` nga Firestore/`ProductMapper.cardImageUrl`. Wishlist/Home tashmë përdornin `ProductImageView`; Cart jo.

Asnjë bug në datasource / repository / ProductEntity.

---

## Fix

Zëvendësuar ikonën me të njëjtin pattern si Wishlist:

- `ProductImageView(imageUrl: product.imageUrl, width: 56, height: 72, ...)`
- `Icons.wine_bar_outlined` vetëm si **placeholder** kur mungon URL

Madhësia, spacing, radius, layout — të pandryshuara.

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

Cart përdor `ProductImageView` si Home / Search / Category / Wishlist. Guest dhe logged-in cart shfaqin foto kur `ProductEntity.imageUrl` ekziston.
