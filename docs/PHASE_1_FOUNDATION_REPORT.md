# Phase 1 — Clean Architecture & Firebase Foundation Report

**Projekti:** Cava Premium (`cava_ecommerce`)  
**Data:** 6 korrik 2026  
**Scope:** Foundation layer vetëm — **pa ndryshime UI, routing, apo mock data**

---

## Përmbledhje

Phase 1 shtoi infrastrukturën bazë të Clean Architecture në `lib/core/` dhe dependencies për Firebase/image caching/DI. Asnjë ekran, widget, router, apo mock data nuk u prek. Aplikacioni vazhdon të funksionojë identik si më parë.

---

## 1. Skedarët e krijuar

### `lib/core/error/`

| Skedar | Qëllimi |
|--------|---------|
| `failures.dart` | Hierarki `sealed` e gabimeve domain: `ServerFailure`, `NetworkFailure`, `CacheFailure`, `AuthFailure`, `NotFoundFailure`, `ValidationFailure`, `UnknownFailure` |
| `app_exception.dart` | `AppException` për data layer + `mapExceptionToFailure()` për konvertim në `Failure` |

### `lib/core/result/`

| Skedar | Qëllimi |
|--------|---------|
| `result.dart` | Wrapper `Result<T>` me `Success` / `Error`, plus `guard()` dhe `guardSync()` për try/catch të standardizuar |

### `lib/core/usecase/`

| Skedar | Qëllimi |
|--------|---------|
| `base_usecase.dart` | Kontrata bazë: `BaseUseCase`, `BaseUseCaseNoParams`, `SyncUseCase`, `SyncUseCaseNoParams`, `NoParams` |

### `lib/core/di/`

| Skedar | Qëllimi |
|--------|---------|
| `injection.dart` | Service locator me `get_it` (`sl`), `configureDependencies()` placeholder, `resetDependencies()` për teste |

### `lib/core/firebase/`

| Skedar | Qëllimi |
|--------|---------|
| `firebase_config.dart` | Emërtime Firestore/Storage (`products`, `categories`, `promotions`, etj.) + flag `enabled = false` |
| `firebase_initializer.dart` | `FirebaseInitializer.initialize()` — gati për Phase 2, **nuk thirret nga `main.dart`** |

### Dependencies (`pubspec.yaml`)

| Package | Version (resolved) | Arsye |
|---------|-------------------|-------|
| `get_it` | ^9.2.1 | Service locator pa ndryshuar widget tree |
| `firebase_core` | ^4.11.0 | Bootstrap Firebase |
| `cloud_firestore` | ^6.6.0 | Firestore datasource (Phase 2) |
| `firebase_auth` | ^6.5.4 | Auth layer (Phase 4) |
| `firebase_storage` | ^13.4.3 | Product/banner images (Phase 6) |
| `cached_network_image` | ^3.4.1 | Network image caching (Phase 2/6) |

**Zgjedhja DI:** `get_it` u zgjodh në vend të `riverpod` sepse nuk kërkon `ProviderScope` rreth `MaterialApp` — zero ndryshim në UI/runtime tree.

---

## 2. Pse u krijuan

| Komponent | Problemi që zgjidh |
|-----------|-------------------|
| **Failure / AppException** | Gabimet e Firebase/HTTP nuk duhet të kalojnë si exception të papërpunuara në UI |
| **Result\<T\>** | Use cases dhe repositories kthejnë sukses/gabim pa `try/catch` në çdo ekran |
| **BaseUseCase** | Kontratë e njëtrajtshme për logjikën e biznesit — e testueshme dhe e izoluar |
| **get_it (sl)** | Swap mock ↔ Firebase pa ndryshuar konstruktorët e widget-eve |
| **FirebaseConfig** | Emërtime të centralizuara koleksionesh/paths — shmang string-e të shpërndara |
| **FirebaseInitializer** | Pika e vetme e inicializimit — aktivizohet vetëm kur `FirebaseConfig.enabled = true` |

---

## 3. Çfarë NUK u prek

| Zona | Status |
|------|--------|
| **UI** (screens, widgets, theme, spacing, colors, animacione, tekste) | ✅ Pa ndryshime |
| **Routing** (`app_router.dart`, `app_routes.dart`) | ✅ Pa ndryshime |
| **Mock data** (`MockProducts`, `MockCart`, etj.) | ✅ Intakt |
| **`main.dart`** | ✅ Pa ndryshime — Firebase/DI **nuk** inicializohen |
| **Feature presentation layers** | ✅ Pa ndryshime |
| **`catalog_repository.dart`** | ✅ Pa ndryshime |
| **Tests** | ✅ Pa ndryshime |

---

## 4. Si ndihmon kjo për Firebase më vonë

### Rrjedha e re (Phase 2+)

```
Presentation (ViewModel — Phase 2)
        │
        ▼
UseCase extends BaseUseCase<T, Params>
        │  returns Result<T>
        ▼
Repository Interface (domain)
        │
        ▼
RepositoryImpl (data)
        │  throws AppException → mapped to Failure
        ▼
RemoteDataSource (Firestore via FirebaseConfig.productsCollection)
        │
        ▼
Firebase
```

### Shembull i ardhshëm (Phase 2 — nuk ekziston ende)

```dart
class GetProductByIdUseCase extends BaseUseCase<ProductEntity, String> {
  GetProductByIdUseCase(this._repository);
  final ProductRepository _repository;

  @override
  Future<Result<ProductEntity>> call(String productId) {
    return guard(() => _repository.getById(productId));
  }
}
```

### Aktivizimi i Firebase (Phase 2)

1. `flutterfire configure` → gjenero `firebase_options.dart`
2. Vendos `FirebaseConfig.enabled = true`
3. Thirr `FirebaseInitializer.initialize(options: DefaultFirebaseOptions.currentPlatform)` nga `main()` **para** `runApp`
4. Regjistro datasources/repositories në `configureDependencies()`

---

## 5. Çfarë mbetet për Phase 2

### Domain (per feature)

- [ ] Repository **interfaces** në `domain/repositories/` (Products, Categories)
- [ ] Use cases konkrete (`GetProductById`, `GetRecommendedProducts`, etj.)
- [ ] Shtim fushash entity (`createdAt` për New Arrivals)

### Data

- [ ] `ProductModel`, `CategoryModel` + mappers
- [ ] `ProductRemoteDataSource` (Firestore)
- [ ] `ProductRepositoryImpl` që implementon interface domain
- [ ] Zhvendosje logjikës produkteve nga `catalog_repository.dart` te `features/products/`

### Presentation (pa ndryshuar dizajn)

- [ ] ViewModels/Controllers që zëvendësojnë thirrjet direkte `CatalogFacade` / mock
- [ ] Loading/error states me `Result.fold()` — **layout i njëjtë**, vetëm data source ndryshon

### Firebase platform setup

- [ ] `flutterfire configure`
- [ ] `google-services.json` (Android) + `GoogleService-Info.plist` (iOS)
- [ ] Firestore security rules (Phase 8)

### DI wiring

- [ ] Regjistrime në `configureDependencies()`
- [ ] Thirrje nga `main.dart` pas Firebase init

### Images

- [ ] Përdor `cached_network_image` në product widgets (Phase 2/6) — **vetëm kur `imageUrl` vjen nga Firestore**

---

## 6. Verifikim

```bash
flutter analyze lib/core/error lib/core/result lib/core/usecase lib/core/di lib/core/firebase
# → No issues found
```

Aplikacioni buildohet me dependencies të reja pa inicializim Firebase — `FirebaseConfig.enabled = false` garanton që asnjë thirrje Firebase nuk ndodh në runtime.

---

## 7. Struktura e re e `lib/core/`

```
lib/core/
├── constants/
├── di/
│   └── injection.dart          ← NEW
├── error/
│   ├── app_exception.dart      ← NEW
│   └── failures.dart           ← NEW
├── firebase/
│   ├── firebase_config.dart    ← NEW
│   └── firebase_initializer.dart ← NEW
├── result/
│   └── result.dart             ← NEW
├── router/
├── state/                      (bosh — Phase 2+)
├── theme/
├── usecase/
│   └── base_usecase.dart       ← NEW
├── utils/
└── widgets/
```

---

*Phase 1 complete. UI dhe mock data të paprekura. Foundation gati për Phase 2 — Products & Categories me Firestore.*
