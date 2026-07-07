# Phase 13 — Checkout Address Selection

**Data:** 8 korrik 2026  
**Qëllimi:** Checkout nuk përdor më automatikisht adresën default. Përdoruesi zgjedh adresën e dorëzimit; ajo dërgohet te `placeOrder` dhe ruhet lokalisht për vizitat e ardhshme.

---

## Problemi fillestar

Phase 12 zgjidhte automatikisht adresën default (ose të parën) në `CheckoutRepositoryImpl._resolveDefaultAddress()` dhe `CheckoutController._refreshSession()`. Përdoruesi nuk kishte kontroll mbi adresën e dorëzimit; butoni **"Ndrysho"** në checkout ishte no-op.

---

## Si ngarkohen adresat

```
CheckoutScreen.initState()
  → CheckoutController.load()
    → GetAddressesUseCase
      → AddressesRepository.getAddresses()
        → users/{uid}/addresses (Firebase ose mock)
```

Adresat lexohen përmes `AddressRepository` ekzistues — **nuk u krijuar datasource i ri**.

Pas ngarkimit, `CheckoutAddressResolver` vendos nëse ka adresë të zgjedhur:

| Situata | Rezultati |
|---------|-----------|
| Lista bosh | `selectedAddress = null` |
| Pa ID të ruajtur (vizita e parë) | `selectedAddress = null` — përdoruesi duhet të zgjedhë |
| ID i ruajtur ekziston në listë | zgjidhet automatikisht |
| ID i ruajtur u fshi | fallback te default, pastaj te adresa e parë |

Skedari: `lib/features/checkout/domain/utils/checkout_address_resolver.dart`

---

## Si ruhet adresa e zgjedhur

**Storage:** `CheckoutSelectedAddressStorage`  
**Key:** `checkout_selected_address_id_v1` në SharedPreferences

```
CheckoutController.selectAddress(address)
  → _selectedAddressStorage.writeAddressId(address.id)
  → _syncCustomerInfo()
```

Në hapjen e ardhshme të checkout:

```
CheckoutController._refreshSession()
  → readAddressId()
  → CheckoutAddressResolver.resolve(...)
```

Skedari: `lib/features/checkout/data/local/checkout_selected_address_storage.dart`

---

## Si përditësohet checkout (UI)

### User Information Card

Seksioni **"Adresa e dorëzimit"** shfaq:

- Emri i adresës (Home, Office…)
- Marrësi, telefoni, adresa, qyteti, kodi postar
- **Ndrysho >** në të djathtë → hap bottom sheet

### Empty state (pa adresa)

- Ikonë location
- *"Nuk ke asnjë adresë."*
- Buton **"Shto adresë"**

### Bottom sheet (`checkout_address_selector_bottom_sheet.dart`)

- Rounded 28, drag handle, SafeArea, scroll, keyboard aware
- Card premium për çdo adresë
- Adresa aktive: border burgundy, check icon, background më i errët
- **+ Shto adresë të re** → `showAddAddressBottomSheet` ekzistues; lista rifreskohet pas ruajtjes

Skedarët:
- `lib/features/checkout/presentation/screens/checkout_screen.dart`
- `lib/features/checkout/presentation/widgets/checkout_address_selector_bottom_sheet.dart`

---

## Si ndryshon payload i placeOrder

`PlaceOrderRequest` tani kërkon `addressId`:

```dart
PlaceOrderRequest(
  paymentMethod: paymentMethod,
  termsAccepted: termsAccepted,
  addressId: selectedAddress!.id,
)
```

`CheckoutRepositoryImpl` zgjidh adresën sipas ID-së së zgjedhur — **jo më default automatik**:

```dart
final address = await _resolveAddress(request.addressId);
final payload = PlaceOrderPayloadMapper.toPayload(
  user: user,
  address: address,  // adresa e zgjedhur nga përdoruesi
  items: items,
  ...
);
```

Nëse nuk ka adresë të zgjedhur ose ID invalid → `ValidationFailure` me mesazh *"Shto ose zgjidh një adresë."*

---

## Validimi i checkout

| Rast | Mesazh snackbar |
|------|-----------------|
| Pa adresa | *"Shto ose zgjidh një adresë."* |
| Ka adresa por asnjë e zgjedhur | *"Shto ose zgjidh një adresë."* |
| Guest | *"Kyçu për të vazhduar me porosinë."* |
| Shportë bosh | *"Shporta është bosh."* |

---

## Skedarë të ndryshuar / të shtuar

| Skedar | Roli |
|--------|------|
| `checkout_selected_address_storage.dart` | Persistencë lokale e ID-së |
| `checkout_address_resolver.dart` | Logjikë zgjedhje/fallback |
| `checkout_controller.dart` | `selectAddress`, `refreshAddresses`, validim |
| `checkout_repository.dart` | `PlaceOrderRequest.addressId` |
| `checkout_repository_impl.dart` | `_resolveAddress(addressId)` |
| `checkout_session_state.dart` | Fusha shtesë në `CheckoutCustomerInfo` |
| `checkout_address_selector_bottom_sheet.dart` | UI zgjedhje adrese |
| `checkout_screen.dart` | Seksioni dorëzimi + empty state |
| `injection.dart` | DI për storage |

**Nuk u prekën:** Product, Cart, Orders, Payments, backend.

---

## Testet

| Test | Skedar |
|------|--------|
| Load addresses pa auto-select | `checkout_controller_test.dart` |
| Select address + persist | `checkout_controller_test.dart` |
| Restore persisted address | `checkout_controller_test.dart` |
| Deleted selected → fallback | `checkout_controller_test.dart` |
| Empty addresses → block checkout | `checkout_controller_test.dart` |
| Block pa zgjedhje | `checkout_controller_test.dart` |
| Payload përdor adresën e zgjedhur | `checkout_controller_test.dart`, `checkout_repository_impl_test.dart` |
| Resolver unit tests | `checkout_address_resolver_test.dart` |
| Storage read/write/clear | `checkout_selected_address_storage_test.dart` |

---

## Rezultatet

### flutter analyze

```
No issues found!
```

### flutter test

```
All tests passed! (279 tests)
```

---

## Rezultati final

Checkout përdor adresën që zgjedh përdoruesi, jo më automatikisht adresën default. `placeOrder` merr gjithmonë adresën e saktë të dorëzimit sipas zgjedhjes së ruajtur ose të re të përdoruesit.
