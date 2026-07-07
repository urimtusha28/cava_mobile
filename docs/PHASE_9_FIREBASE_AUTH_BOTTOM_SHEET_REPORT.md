# Phase 9 — Firebase Auth Bottom Sheet Report

## Qëllimi

Kur user klikon **"Kyçu"** në ProfileScreen, të hapet një bottom modal sheet premium për Firebase Auth (login / register / forgot password).

---

## Çfarë u implementua

| Komponent | Përshkrim |
|-----------|-----------|
| `AuthFirebaseDataSource` | Login, register, forgot password, logout, `authStateChanges`, `currentUser` |
| `FirebaseAuthGateway` | Wrapper testues rreth `FirebaseAuth` |
| `AuthUserEntity` | `uid`, `email`, `displayName`, `displayLabel` |
| `AuthExceptionMapper` | Firebase errors → mesazhe në shqip |
| `AuthFormValidator` | Email, password, name, confirm password |
| `auth_bottom_sheet.dart` | UI premium me toggle Kyçu / Regjistrohu |
| `FirebaseConfig.useFirebaseAuth` | `true` — aktivizon Firebase Auth në DI |
| Use cases | `LoginUseCase`, `RegisterUseCase`, `ForgotPasswordUseCase` |
| `AuthController` | `signIn`, `signUp`, `resetPassword`, `logout`, loading state |

**Pa ndryshuar:** routing, bottom navigation, products/categories/cart/wishlist, backend/web.

---

## Si hapet bottom sheet

1. User i pa loguar shikon **"Kyçu"** në header (si më parë)
2. Tap → `showAuthBottomSheet(context, controller: _controller)`
3. Vetëm kur `FirebaseConfig.enabled && FirebaseConfig.useFirebaseAuth`
4. Sheet: rounded top **28**, white background, `DraggableScrollableSheet`, SafeArea, keyboard inset

---

## Login / Register / Forgot password

| Formë | Fushat | Veprim |
|-------|--------|--------|
| **Kyçu** | Email, Password | `AuthController.signIn` → `LoginUseCase` → Firebase |
| **Regjistrohu** | Emri, Email, Password, Confirm | `AuthController.signUp` → `RegisterUseCase` → Firebase + Firestore doc |
| **Harrove fjalëkalimin?** | Email | `AuthController.resetPassword` → snackbar suksesi |

- Validation client-side para submit
- Loading spinner në button gjatë request-it
- Sheet **nuk mbyllet** derisa të përfundojë
- Në sukses → mbyll sheet (forgot password → snackbar + mbyll)

---

## Firestore `users/{uid}`

Në **register** krijohet/merge dokumenti:

```json
{
  "email": "user@example.com",
  "name": "Emri",
  "role": "client",
  "status": "active",
  "createdAt": "<server timestamp>",
  "updatedAt": "<server timestamp>"
}
```

- `role` vendoset **vetëm** në krijim të ri (`client` — kurrë admin nga client)
- Në dokument ekzistues përditësohen `email`, `name`, `status`, `updatedAt`

---

## Error handling

| Firebase code | Mesazh |
|---------------|--------|
| `user-not-found`, `wrong-password`, `invalid-credential` | Email ose fjalëkalim i pasaktë. |
| `email-already-in-use` | Ky email është i regjistruar. |
| `weak-password` | Fjalëkalimi është shumë i dobët. |
| `invalid-email` | Email nuk është valid. |
| `network-request-failed` | Kontrollo lidhjen me internet. |
| default | Diçka shkoi keq. Provo përsëri. |

---

## Profile pas login

- Header shfaq `displayName` nëse ekziston, përndryshe **email**
- Tile **"Dil"** shfaqet vetëm kur user është logged in
- Layout bazë i listës mbeti i njëjtë

---

## DI

```dart
if (FirebaseConfig.enabled && FirebaseConfig.useFirebaseAuth) {
  return AuthFirebaseDataSource(...);
}
return const AuthMockDataSource();
```

Testet përdorin `AuthMockDataSource` si default në `configureTestDependencies`.

---

## UI bazë

**Identik** — vetëm tap behavior i "Kyçu" dhe tile "Dil" kur logged in. Asnjë ndryshim routing/nav.

---

## Teste

| Test | Verifikon |
|------|-----------|
| `auth_firebase_datasource_test` | login, register doc, forgot, logout, error mapping |
| `auth_exception_mapper_test` | të gjitha kodet Firebase |
| `auth_form_validator_test` | validation rules |
| `auth_controller_test` | signIn, signUp, resetPassword, logout |
| `auth_repository_impl_test` | delegation |
| `auth_usecases_test` | use case wiring |
| `profile_screen_test` | bottom sheet hapet nga "Kyçu" |
| `injection_test` | `useFirebaseAuth` flag + mock default në tests |

---

## Rezultatet

```
flutter analyze
→ No issues found!

flutter test
→ 210 tests passed
```

---

## Përmbledhje

Firebase Auth real është i lidhur përmes Clean Architecture. ProfileScreen hap një bottom sheet premium për kyçje/regjistrim/rikthim fjalëkalimi, me validation, loading, error mapping në shqip, dhe dokument user në Firestore me `role: client`.
