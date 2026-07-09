# Phase 25 — Callable Auth Token Fix Report

**Data:** 8 korrik 2026  
**Scope:** Vetëm transporti i autentikimit për Cloud Functions callable `placeOrder` (pa ndryshuar UI/checkout payload/cart/address/profile).

---

## 1. Simptoma

- `FirebaseAuth.currentUser` ekziston (`uid` + `email`).
- Callable `placeOrder` kthen:
  - `code=unauthenticated`
  - `message=Unauthenticated`
- Pra klienti ka sesion Auth, por request-i callable nuk e dërgonte / nuk e bashkangjiste si duhet ID token-in në transport.

---

## 2. Root cause (mobile)

Para fix-it, gateway-i ishte:

```dart
FirebaseFunctionsGatewayImpl(FirebaseFunctions.instance)
```

Problemet:

1. **Pa force-refresh të ID token** para `httpsCallable(...).call(...)`.  
   Token i skaduar / jo i ngarkuar në interceptor-in e callable → backend `context.auth == null` → `unauthenticated`.
2. **Pa region eksplicit.** Default Flutter Functions është `us-central1`; deploy Gen1 pa `.region()` është `us-central1`, por mungesa e eksplicitimit + mungesa e `instanceFor(app:)` e bënte wiring-un të brishtë.
3. **Pa lidhje eksplicite me të njëjtin `FirebaseApp`** si Auth (i njëjti `Firebase.app()`).

### Shënim backend (jo ndryshuar në këtë fazë)

Në `callableConfig.ts`, `placeOrder` ka `enforceAppCheck: true` (default).  
Nëse pas fix-it token-i Auth arrin por ende shfaqet `unauthenticated`/`failed-precondition` nga App Check, duhet App Check në mobile **ose** disable i përkohshëm `FUNCTIONS_APPCHECK_ENFORCE` në Functions — **jashtë** scope-it të kësaj detyre (transport Auth ID token).

---

## 3. Çfarë u ndryshua

### `FirebaseFunctionsGatewayImpl`
- Factory `createDefault()`:
  - `Firebase.app()` (i njëjtë me Auth)
  - `FirebaseFunctions.instanceFor(app: app, region: FirebaseConfig.functionsRegion)`
  - region = **`us-central1`**
- Para çdo `call(name, data)`:
  - `currentUser.getIdToken(true)` përmes `CallableAuthBridge.ensureFreshIdToken()`
- Debug log (`kDebugMode` only):
  - callable name
  - uid
  - token yes/no
  - auth projectId
  - functions projectId
  - region

### `FirebaseConfig`
- `functionsRegion = 'us-central1'`

### DI
- `FirebaseFunctionsGatewayImpl.createDefault()` në vend të `FirebaseFunctions.instance`

### Tests
- Token refresh thirret **para** invoker-it
- Guest path: `ensureFreshIdToken` → false, por callable vazhdon (guest)
- Auth projectId == functions projectId (`cavapremium-31036`)
- Region `us-central1`

---

## 4. Verifikimi i project / region

| Check | Expected |
|-------|----------|
| Auth projectId | `cavapremium-31036` |
| Functions projectId | `cavapremium-31036` |
| Region | `us-central1` |
| Emulator | Jo i lidhur (`useFunctionsEmulator` not found) |

---

## 5. Expected runtime behavior

Kur user është logged in:

1. Gateway force-refresh ID token.
2. Callable përdor App + region korrekte.
3. Backend `context.auth.uid` duhet të plotësohet.
4. Nuk duhet më `unauthenticated` **për shkak të token-it që mungon/skadon**.

Log tipik debug:

```
[CallableAuth] name=placeOrder uid=… token=yes authProject=cavapremium-31036 functionsProject=cavapremium-31036 region=us-central1
```

---

## 6. Rezultatet e analizës / testeve

| Check | Rezultat |
|-------|----------|
| `flutter analyze` (gateway + config + di) | Warning i hequr (unused import); pastaj **clean** në full run |
| `flutter test` (checkout + gateway) | **47 passed** (incl. 3 gateway tests) |
| `flutter test` (full) | shih run final |

---

## 7. Skedarët e ndryshuar

- `lib/features/checkout/data/firebase/firebase_functions_gateway_impl.dart`
- `lib/core/firebase/firebase_config.dart`
- `lib/core/di/injection.dart`
- `test/features/checkout/data/firebase/firebase_functions_gateway_impl_test.dart`
- `docs/PHASE_25_CALLABLE_AUTH_TOKEN_FIX_REPORT.md`

---

## 8. Çfarë nuk u prek

- Checkout UI / layout  
- `placeOrder` payload (`userId`, guest/user fields)  
- Cart / address / profile / wishlist  
- Firestore rules  
- Cloud Function `placeOrder` source  

---

## 9. Nëse ende dështon pas hot restart

1. Lexo log `[CallableAuth]` — `token=yes`? projectIds match?
2. Nëse `token=yes` por CF ende `unauthenticated` → kontrollo **App Check** enforcement në Functions.
3. Konfirmo që function-i i deployuar është në `us-central1` (`firebase functions:list`).

---

## Final verdict

Transporti i Auth ID token për callables është rregulluar: **fresh token + same FirebaseApp + region eksplicit**.  
User i kyçur duhet të arrijë `context.auth.uid` në `placeOrder` (duke përjashtuar bllokimet e veçanta të App Check në backend).
