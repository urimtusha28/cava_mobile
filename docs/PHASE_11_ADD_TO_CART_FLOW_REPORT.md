# Phase 11 — Add To Cart Flow Report

**Data:** 8 korrik 2026  
**Qëllimi:** Çdo vend ku përdoruesi shton produkt në shportë duhet të thërrasë `AddToCartUseCase` me produkt real, quantity, persistencë dhe badge — jo vetëm navigim te `/cart`.

---

## Problemi fillestar

Në `ProductDetailScreen`, butoni **"Bli tani"** dhe **ikona e shportës** bënin vetëm:

```dart
context.push(AppRoutes.cart);
```

(`product_detail_screen.dart` — para Phase 11)

`AddToCartUseCase` ishte i lidhur **vetëm** nga `WishlistController` / wishlist screen. `ProductGridCard` (Home, Category, All Products) **nuk ka** buton add-to-cart — vetëm `ProductWishlistToggle`; UI e re nuk u shtua (sipas spec).

---

## Çfarë u ndryshua

### 1. Domain — quantity në add-to-cart

| Skedar | Ndryshim |
|--------|----------|
| `lib/features/cart/domain/usecases/add_to_cart.dart` | `AddToCartParams { product, quantity }`; use case thërret `repository.addProduct(..., quantity:)` |
| `lib/features/cart/domain/add_to_cart_result.dart` | **I ri** — `success`, `outOfStock`, `failure` |
| `lib/features/cart/domain/repositories/cart_repository.dart` | `addProduct(product, {quantity = 1})` |
| `lib/features/cart/data/datasources/cart_data_source.dart` | I njëjti signature |
| `lib/features/cart/data/datasources/cart_local_datasource.dart` | Shton `quantity` në një rresht; rrit totalin nëse produkti ekziston; `_persistAsync()` menjëherë |
| `lib/features/cart/data/repositories/cart_repository_impl.dart` | Përditëson `CartStateNotifier` pas add |

### 2. Product Detail — controller + UI (layout i pandryshuar)

| Skedar | Ndryshim |
|--------|----------|
| `lib/features/products/presentation/controllers/product_detail_controller.dart` | Injektim `AddToCartUseCase`; metodë `addToCart({required int quantity})` → `AddToCartResult` |
| `lib/features/products/presentation/screens/product_detail_screen.dart` | `_handleAddToCart()` — pa ndryshim layout; vetëm `onTap` callbacks |

**Butonat e lidhur:**

| Veprim | Sjellja |
|--------|---------|
| **Ikona shporte** | `addToCart(quantity)` → snackbar *"Produkti u shtua në shportë."* — **nuk navigon** |
| **Bli tani** | `addToCart(quantity)` → pastaj `context.push(/cart)` |

**Out of stock:** nëse `product.inStock == false` → snackbar *"Produkti nuk është në stok."* — pa add, pa ndryshim UI.

**Gabim:** snackbar *"Nuk u shtua në shportë. Provo përsëri."*

### 3. Wishlist — add-to-cart ekzistues

| Skedar | Ndryshim |
|--------|----------|
| `lib/features/wishlist/presentation/controllers/wishlist_controller.dart` | `addToCart` kthen `AddToCartResult`; kontroll `inStock` |
| `lib/features/wishlist/presentation/screens/wishlist_screen.dart` | Snackbar success / out-of-stock / error pas *"Shto në shportë"* |

### 4. Product Grid / Cards

**Asnjë ndryshim** — `ProductGridCard` nuk ka buton add-to-cart (vetëm wishlist toggle). Nuk u shtua UI e re.

### 5. DI

`ProductDetailController` regjistrohet me 4 dependency (`sl(), sl(), sl(), sl()` — përfshirë `AddToCartUseCase`).

---

## Si respektohet quantity

- Product detail: `_quantity` nga `_QuantityControl` kalon te `controller.addToCart(quantity: _quantity)`.
- `CartLocalDataSource.addProduct(product, quantity: n)`:
  - Produkt i ri → një rresht me `quantity: n`
  - Produkt ekzistues → `current.quantity + n` (jo dublikatë)
- Wishlist → gjithmonë `quantity: 1`.

---

## Badge dhe persistencë

| Mekanizëm | Skedar |
|-----------|--------|
| Badge | `CartRepositoryImpl._notifyChange()` → `CartStateNotifier.update(itemCount)` |
| SharedPreferences | `CartLocalDataSource._persistAsync()` pas çdo `addProduct` (`guest_cart_items_v1`) |

---

## UI

**Identik** — të njëjtat butona, madhësi, ngjyra, layout. Ndryshuar vetëm `onTap` / logjika pas scenes.

Routing, Firebase products/categories, checkout — **pa prekje**.

---

## Teste

| Skedar | Mbulim |
|--------|--------|
| `test/features/products/presentation/controllers/product_detail_controller_test.dart` | quantity, outOfStock, failure |
| `test/features/products/presentation/screens/product_detail_screen_test.dart` | cart icon snackbar + badge; Bli tani quantity 3 + navigim CartScreen; out-of-stock |
| `test/features/cart/add_to_cart_flow_test.dart` | badge + persistencë; merge duplicate |
| `test/features/cart/data/datasources/cart_local_datasource_test.dart` | quantity 4; duplicate → 3 |
| `test/features/cart/domain/usecases/cart_usecases_test.dart` | AddToCartParams quantity |
| `test/features/cart/data/repositories/cart_repository_impl_test.dart` | badge pas add |
| `test/features/wishlist/presentation/controllers/wishlist_controller_test.dart` | delegim use case |

---

## Rezultatet

| Komandë | Rezultat |
|---------|----------|
| `flutter analyze` | **No issues found** |
| `flutter test` | **253 teste kaluan** |
| `flutter run` | Build macOS i nisur (kërkon device/emulator për verifikim manual) |

---

## Rezultat final

- ✅ Product Detail shton produkt real në shportë me quantity të zgjedhur  
- ✅ Ikona shporte → snackbar, pa auto-navigim  
- ✅ Bli tani → add + navigim `/cart`  
- ✅ Out-of-stock bllokon add  
- ✅ Duplicate rrit quantity; persistencë SharedPreferences; badge sync  
- ✅ Wishlist *"Shto në shportë"* me të njëjtat rregulla  
- ⚪ Product grid cards — pa add-to-cart button (asnjë UI e re)
