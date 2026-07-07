# Phase 10 — Real Orders and Addresses Report

## Qëllimi

Profile section të përdorë të dhëna reale nga Firebase për **Porositë e mia** dhe **Adresat**, me button **Shto** në AppBar të adresave.

---

## Orders — si lexohen

| Përshkrim | Vlerë |
|-----------|--------|
| **Collection** | `orders` |
| **Query** | `userId == currentUser.uid`, `orderBy createdAt desc` |
| **Akses** | Vetëm **read** nga client |

**Flow:**
1. `OrdersController.load()` → `IsLoggedInUseCase`
2. Nëse guest → `requiresLogin = true`
3. Nëse logged in → `GetMyOrdersUseCase` → `OrdersRepository` → `OrdersFirebaseDataSource`
4. Mapohen: `orderNumber`, `status`, `paymentStatus`, `total`, `itemCount`, `createdAt`

**UI (`OrdersScreen`):**
- Guest → "Kyçu për të parë porositë e tua." + button Kyçu
- Bosh → "Nuk ke porosi ende."
- Lista → cards me të njëjtin layout bazë (numër, status, pagesë, total, produkte, datë)

---

## Addresses — si ruhen

| Përshkrim | Vlerë |
|-----------|--------|
| **Path** | `users/{uid}/addresses/{addressId}` |
| **Akses** | Read/write vetëm për current user |

**Fields:** `label`, `fullName`, `phone`, `street`, `city`, `zip`, `country`, `isDefault`, `createdAt`, `updatedAt`

| Veprim | Firestore |
|--------|-----------|
| **Add** | `set()` + `serverTimestamp` për created/updated |
| **Update** | `update()` + `updatedAt` |
| **Delete** | `delete()` |
| **Set default** | batch update — vetëm 1 `isDefault: true` |

Adresa e parë bëhet automatikisht default.

---

## Add address button

Në `AddressesScreen` AppBar (djathtas):
- **Tekst:** "Shto"
- **Kur klikohet:** hap `showAddAddressBottomSheet`
- Form: label, fullName, phone, street, city, zip, country, isDefault
- Validation + loading në button
- Pas suksesit → sheet mbyllet, lista rifreskohet

---

## Skedarët kryesorë

| Skedar | Rol |
|--------|-----|
| `orders_firebase_datasource.dart` | Lexon orders nga Firestore |
| `addresses_firebase_datasource.dart` | CRUD addresses |
| `orders_controller.dart` / `addresses_controller.dart` | State + load |
| `orders_screen.dart` / `addresses_screen.dart` | UI reale |
| `add_address_bottom_sheet.dart` | Form shtimi |
| `cava_app_bar.dart` | `actions` parameter (i ri) |
| `injection.dart` | DI për orders/addresses |

**Pa prekur:** Products, Categories, Cart, Checkout, routing, web/backend, Firestore rules.

---

## UI bazë

**Identik** në layout:
- E njëjta listë cards për orders/addresses
- E njëjta AppBar me back
- Shtesa minimale: button "Shto", badge "Kryesore", login prompt, empty states

---

## Çfarë mbetet për checkout

- Krijimi i order nga app (write në `orders`)
- Order detail route/screen
- Edit/delete address UI (use cases ekzistojnë)
- Lidhja e adresës së zgjedhur me checkout
- Pagesa dhe konfirmimi i porosisë

---

## Teste

| Test | Verifikon |
|------|-----------|
| `account_models_test` | OrderModel, AddressModel, mappers |
| `orders_firebase_datasource_test` | Query userId + sort |
| `addresses_firebase_datasource_test` | add, default, delete |
| `address_form_validator_test` | Validation |
| `orders_controller_test` | Guest + logged in |
| `addresses_controller_test` | Guest, add, setDefault |
| `orders_addresses_usecases_test` | Use case delegation |
| `orders_screen_test` / `addresses_screen_test` | Login prompt |

---

## Rezultatet

```
flutter analyze
→ No issues found!

flutter test
→ 230 tests passed
```

---

## Përmbledhje

Orders lexohen read-only nga `orders` për user-in aktual. Addresses ruhen në `users/{uid}/addresses` me CRUD të plotë dhe default të vetëm. Profile screens tani përdorin Firebase real me auth gate dhe empty states, pa ndryshuar dizajnin bazë.
