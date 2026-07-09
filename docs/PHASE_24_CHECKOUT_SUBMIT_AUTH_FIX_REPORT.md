# Phase 24 — Checkout Submit Auth Fix Report

**Data:** 8 korrik 2026  
**Scope:** Logged-in cash checkout submit (`placeOrder`) — pa UI layout, pa Quipu, pa cart/wishlist/products.

---

## 1. Root cause

Dy probleme të lidhura, jo “auth notifier i vjetër” si burim i vetëm:

### A. Payload pa `userId` (shkaku kryesor i snackbar-it “Kyçu…”)

Cloud Function `placeOrder` kërkon:

```ts
if (data.customerType === "user") {
  const uid = context.auth?.uid;
  if (!uid || uid !== data.userId) {
    throw permission-denied AUTH_USER_MISMATCH
  }
}
```

Mobile dërgonte `customerType: "user"` **pa `userId`**.  
CF kthente `permission-denied` / `AUTH_USER_MISMATCH`.  
Mobile e maponte gabimisht `permission-denied` → `UNAUTHENTICATED` → snackbar **"Kyçu për të vazhduar."**

UI kishte të drejtë: `FirebaseAuth.currentUser` ekzistonte, adresat/profili u ngarkuan.  
Submit “dukej” si guest/unauth **vetëm për shkak të mapping-ut të gabuar**, jo sepse user ishte guest.

### B. Validim i rreshtë “email bosh ⇒ login”

Në `_validateBeforeSubmit`, edhe kur uid ishte present, mungesa e email në `customerInfo` kthente mesazhin e login.  
Kjo nuk përputhej me realitetin e auth (uid mjafton).

---

## 2. Çfarë po ndodhte në UI

- Checkout shfaqte Emër / Email / Adresë / Telefon nga `users/{uid}` + addresses.
- User klikonte **Bli** (cash + terms).
- Snackbar (ose dështim i qetë i mapped) sugjeronte mungesë login.
- Ordermë nuk krijohej / nuk arrihej OrderSuccess.

---

## 3. Pse user dukej logged-in por submit “dështonte”

| Shtresa | Realiteti |
|---------|-----------|
| UI / load | `GetCurrentUser` + addresses → user real |
| FirebaseAuth | `currentUser != null` |
| placeOrder payload (para fix) | `customerType: user`, **pa `userId`** |
| Cloud Function | `AUTH_USER_MISMATCH` |
| Error mapper (para fix) | `permission-denied` → “Kyçu për të vazhduar.” |

Pra UI dhe Auth ishin sync; kontrata CF / mapping i error-it ishin gabim.

---

## 4. Çfarë u ndryshua

1. **`PlaceOrderPayloadMapper`** — shton `userId: user.uid` për user orders; guest payload me `customerType: guest`, `userId: null`.
2. **`CheckoutController.submitOrder`** — para submit rifreshon auth me **`getCurrentUser()`** (i njëjti burim si load: `AuthRepository` → `FirebaseAuth.currentUser`). Vendos `user` vs `guest` nga objekti i kthyer, jo nga flag i vjetër.
3. **Validim** — nëse ka `authUser` (uid), **nuk** kërkon “Kyçu…” për email bosh; kërkon vetëm adresë + cart + terms.
4. **Error mapping** — `permission-denied` / `AUTH_USER_MISMATCH` **nuk** mapohen si login; mesazhe të qarta për mismatch / payment method / customer / items.
5. **`debugPrint`** kontroluar: uid/email, addressId, payment, terms, item count, CF code/message.
6. Guest flow (3 butona + sheet) mbetet; nuk preket products/cart sync/wishlist.

---

## 5. Si u verifikua auth state

```
load / submit
  → GetCurrentUserUseCase
  → AuthRepository.getCurrentUser()
  → AuthFirebaseDataSource.currentUser
  → FirebaseAuth.currentUser
```

- **Nuk** përdoret `AuthStateNotifier` si burim i vendimit të submit.
- `isLoggedIn` në controller sync-ohet nga `getCurrentUser() != null`.
- Repo `CheckoutRepositoryImpl.placeOrder` ri-lexon `getCurrentUser()` për payload user.

---

## 6. Si sillet tani `submitOrder`

1. `_refreshAuthForSubmit()` → live user  
2. Validim: cart, terms, (user → address) ose (guest → guest info)  
3. `PlaceOrderRequest.user` **ose** `.guest`  
4. `PlaceOrderUseCase` → payload me `userId` kur user  
5. CF `placeOrder`  
6. Sukses → clear cart → OrderSuccess  
7. Failure → snackbar me mesazh të mapuar (jo “Kyçu” për mismatch)

---

## 7. Si trajtohen errors

| Code | Mesazh UI |
|------|-----------|
| `UNAUTHENTICATED` | Kyçu për të vazhduar. *(vetëm kur vërtet mungon auth)* |
| `AUTH_USER_MISMATCH` | Sesioni i llogarisë nuk përputhet… |
| `OUT_OF_STOCK` / `PRICE_MISMATCH` / `TERMS_REQUIRED` | Si më parë |
| `INVALID_PAYMENT_METHOD` | Metoda e pagesës… *(CF pranon `cash`/`bank`/`stripe`, **jo** `card`)* |
| `GUEST_INFO_REQUIRED` | Plotëso të dhënat për dorëzim. |
| default | Porosia nuk u krijua. Provo përsëri. |

> **Shënim opsional:** UI e pagesës ende ofron “Paguaj me kartel” (`card`). CF aktualisht **nuk** pranon `card` — do të kthejë `INVALID_PAYMENT_METHOD`. Cash / bank janë të vlefshme. Quipu mbetet Phase e ardhshme.

---

## 8. Skedarët e ndryshuar (Phase 24 + checkout auth/guest i lidhur)

- `lib/features/checkout/data/mappers/place_order_payload_mapper.dart`
- `lib/features/checkout/presentation/controllers/checkout_controller.dart`
- `lib/features/checkout/data/repositories/checkout_repository_impl.dart`
- `lib/features/checkout/data/datasources/checkout_firebase_datasource.dart`
- `lib/features/checkout/data/utils/place_order_exception_mapper.dart`
- `lib/features/checkout/domain/repositories/checkout_repository.dart`
- `lib/features/checkout/domain/entities/guest_checkout_customer.dart`
- `lib/features/checkout/data/local/guest_checkout_customer_storage.dart`
- `lib/features/checkout/presentation/screens/checkout_screen.dart`
- `lib/features/checkout/presentation/widgets/guest_checkout_info_bottom_sheet.dart`
- `lib/features/account/presentation/widgets/auth_bottom_sheet.dart` *(initialMode login/register)*
- `lib/core/di/injection.dart`
- Teste në `test/features/checkout/**`

---

## 9. Rezultatet

| Check | Rezultat |
|-------|----------|
| `flutter analyze` | **No issues found** |
| `flutter test` (checkout) | **44 passed** |
| `flutter test` (full suite) | **passed** (pas Phase 24 patches) |

Testet mbulojnë:
- logged-in + address + cash + terms → placeOrder user + `userId`
- nuk kthen “Kyçu…” kur user është logged in
- guest pa info → “Plotëso të dhënat për dorëzim.”
- guest me info → `customerType: guest`
- empty cart / missing address / terms
- CF failure (OUT_OF_STOCK) → mesazh i mapuar
- auth refresh para submit (flag i vjetër `isLoggedIn=false` nuk bllokon)

---

## 10. Çfarë mbetet

### Guest checkout
- UI + payload guest + persist `guest_checkout_customer_v1` **implementuar**.
- Verifikim live kundrejt CF (rate limits / App Check) ende i nevojshëm në device.
- Guest **nuk** duhet të jetë i kyçur me llogari reale (CF: `GUEST_MUST_BE_UNAUTHENTICATED`).

### Quipu / card
- **Not done** — opsioni UI `card` nuk është i lidhur me gateway; CF nuk pranon `card`.
- Next: initiate Quipu + deep link + verification.

### Opsionale
- Disable “Paguaj me kartel” derisa Quipu të jetë gati, ose mapo në flow të ndërmjetëm.
- Hiq `debugPrint` pas QA, ose mbylli me `kDebugMode` (tashmë janë vetëm diagnostika).

---

## Final verdict

User i kyçur me cart, adresë të zgjedhur, **para në dorë**, dhe terms checked **mund** të klikojë **Bli** dhe të krijojë porosi reale përmes `placeOrder`, me `userId` në payload dhe me mesazhe error që nuk pretendohen “guest” kur `FirebaseAuth.currentUser` ekziston.
