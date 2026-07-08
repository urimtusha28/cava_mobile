# Phase 19 — Real User Profile Edit

**Data:** 8 korrik 2026  
**Qëllimi:** Profile të lexojë dhe editojë të dhënat reale nga Firestore `users/{uid}`, pa foto profili dhe pa lejuar client të ndryshojë `role`/`status`.

---

## Fushat e mbështetura

| Fusha | Lexim | Editim nga client |
|-------|-------|-------------------|
| `uid` | po | jo |
| `name` | po | po (derivuar `firstName + lastName`) |
| `firstName` | po | po (required) |
| `lastName` | po | po (optional) |
| `email` | po (+ fallback Auth) | jo (readonly) |
| `phone` | po | po (optional + validim) |
| `role` | po | **jo** |
| `status` | po | **jo** |
| `createdAt` | po | jo (vetëm në create) |
| `updatedAt` | po | serverTimestamp në save |

**Pa foto profili** — header mban `Icons.person_outline` si më parë; nuk u shtua upload / Storage avatar.

---

## Si lexohet `users/{uid}`

```
ProfileScreen
  → ProfileController.load()
    → AuthController.load()
    → GetCurrentProfileUseCase
      → UserProfileRepositoryImpl.getCurrentProfile()
        → AuthRepository.getCurrentUser() (uid + email)
        → UserProfileFirebaseDataSource.getProfile(uid, authEmail:)
```

`UserProfileModel.fromFirestore`:
- nëse ka `firstName`/`lastName` → i përdor
- përndryshe ndan `name` me `UserProfileNameSplitter`
- nëse `email` mungon në doc → `FirebaseAuth.currentUser.email` (përmes fallback)

---

## Si ruhet editimi

1. Tile **“Edito profilin”** (vetëm kur logged in) hap bottom sheet premium (radius 28).
2. Fushat: Emri, Mbiemri, Telefoni, Email (disabled).
3. Validim: emri required; telefoni optional por me format 8–15 shifra.
4. **Ruaj** → `updateProfile` shkruan vetëm:

```json
{
  "firstName": "...",
  "lastName": "...",
  "name": "firstName lastName",
  "phone": "..." | null,
  "updatedAt": "<serverTimestamp>"
}
```

`SetOptions(merge: true)` — **nuk** dërgon `role`/`status`, pra client nuk mund të bëhet admin.

Snackbar:
- sukses: “Profili u përditësua.”
- gabim: “Profili nuk u përditësua. Provo përsëri.”

---

## Siguria role/status

- `UserProfileModel.updatePayload` nuk përmban kurrë `role`/`status`.
- Register (`AuthFirebaseDataSource._writeUserDoc`) vendos `role: client` vetëm në create.
- `ensureUserDocExists` gjithashtu vendos `role: client` vetëm nëse dokumenti nuk ekziston.
- Testet verifikojnë që pas update, `role`/`status` mbeten të paprekura.

---

## Register compatibility

Register tashmë shkruan:
- `name`, `email`, `firstName`, `lastName` (nga split i name), `phone: null`
- `role: client`, `status: active`, timestamps

---

## UI

- Struktura e listës së tile-ve mbetet; u shtua vetëm tile “Edito profilin” kur logged in.
- Header tregon emrin e plotë, email dhe telefon (nëse ka).
- Guest: “Kyçu”; pas logout kthehet në guest.
- Routing kryesor i paprekur.
- Products/Cart/Wishlist/Checkout/Orders të paprekur.
- Firestore rules të pandryshuara.

---

## Skedarë kryesorë

| Skedar | Roli |
|--------|------|
| `user_profile_entity.dart` | Domain entity |
| `user_profile_model.dart` | Firestore mapping |
| `user_profile_firebase_datasource.dart` | get/update/ensure |
| `user_profile_repository_impl.dart` | Auth-aware repo |
| `profile_controller.dart` | load/save/logout |
| `edit_profile_bottom_sheet.dart` | UI edit |
| `profile_screen.dart` | Header + tile |
| `auth_firebase_datasource.dart` | Register + firstName/lastName |

---

## Testet

- Model: split fallback, email auth fallback, updatePayload pa role/status
- Firestore DS: get, update pa prekur role, ensure create
- ProfileController: logged out, load/update, logout
- ProfileFormValidator: emri/telefoni
- Auth register: firstName/lastName/phone null

---

## Rezultatet

### flutter analyze
```
2 info (cart_firestore_datasource — ekzistues)
0 errors, 0 warnings
```

### flutter test
```
All tests passed! (343 tests)
```

---

## Rezultati final

Profile shfaq dhe editon të dhënat reale të user-it nga Firestore `users/{uid}`, pa foto profili, me email readonly, dhe pa lejuar client të ndryshojë `role`/`status`.
