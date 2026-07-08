# Phase 17 — Global Product Search from Home

**Data:** 8 korrik 2026  
**Qëllimi:** Search bar në Home të bëhet funksional dhe të kërkojë produkte reale duke përdorur cache ekzistuese pa bërë Firestore query për çdo shkronjë.

---

## Si hapet search nga Home

- **HomeScreen:** vazhdon të përdorë të njëjtin `CavaSearchBar` vizual në krye të faqes së parë.  
- `CavaSearchBar` tani pranon `onTap` dhe në Home është i lidhur me router:
  - `onTap: () => context.push(AppRoutes.search)`
- **Routing:**
  - `AppRoutes.search = '/search'`
  - `app_router.dart` shton një `GoRoute` të re me `parentNavigatorKey: _rootNavigatorKey` dhe `pageBuilder` që përdor `state.pageKey`:
    - `path: AppRoutes.search`
    - `child: const SearchScreen()`
- Bottom navigation/ShellRoute mbetet i paprekur; search hapet si faqe modale sipër shell-it ekzistues.

Skedarë kryesorë:
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/core/router/app_routes.dart`
- `lib/core/router/app_router.dart`

---

## Si bëhet kërkimi

### SearchController

- Shtuar `SearchController` si `BaseController` auth-agnostik:
  - Fusha kryesore:
    - `query` (string aktual i kërkimit)
    - `results` (`List<ProductEntity>` e filtruar dhe e renditur)
    - `_allProducts` (cache në memorie e të gjithë produkteve)
    - `hasLoadedProducts` (tregon nëse cache është mbushur një herë)
    - `isSearching` (loading flag gjatë leximit fillestar të produkteve)
    - `recentSearches` (`List<String>` nga SharedPreferences)
  - Përdor `GetAllProductsUseCase`, i cili nga ana e tij përdor `ProductRepository.getAll()` → kjo shfrytëzon cache ekzistuese 5-min në `ProductDataSource.getAllProducts()`.
  - Nuk bën query të ri Firestore për çdo shkronjë; produktet lexohen **një herë** dhe kërkimi është plotësisht client-side.

### SearchScreen

- `SearchScreen` ka:
  - AppBar me:
    - Back button (`context.pop()`)
    - Fushë search në titull me `CavaSearchBar` (variant editable me `controller`)
    - Clear (`Fshij`) që pastron query-n
  - `CavaLoadingOverlay` rreth body për të treguar loading vetëm gjatë leximit të parë të produkteve.
  - Body që shfaq:
    - **Initial state** kur query bosh
    - **Recent searches** kur ka histori
    - **Grid rezultatesh** kur ka match-e
    - **Empty state** kur s’ka rezultate (por vetëm pasi të ketë përfunduar searching)
    - **Error minimal + retry** nëse `GetAllProductsUseCase` dështoi (përdor `errorMessage` nga `BaseController`).

Skedarë:
- `lib/features/search/presentation/controllers/search_controller.dart`
- `lib/features/search/presentation/screens/search_screen.dart`

---

## Fushat ku kërkohet

Kërkimi bëhet mbi `ProductEntity` në memory. Për çdo produkt, ndërtimi i relevance score bazohet në `query` të ulët (`query.toLowerCase()`):

- Me peshë më të lartë:
  - `name`
- Me peshë mesatare:
  - `brand`
  - `categoryName`
- Me peshë më të ulët:
  - `country` / origjina
  - `type` (lloji/subcategory)
  - `volume`
  - `description`

Çdo fushë që përmban query-n rrit `score` me një peshë të caktuar. Vetëm produktet me `score > 0` futen në rezultate.

---

## Si funksionon debounce + minimum 2 karaktere

- `SearchController.debounceDuration = 300ms`.
- `updateQuery(String value)`:
  - Ruhet `query = value.trim()`.
  - Anulohet `Timer` i mëparshëm (nëse ekziston).
  - Nëse `query.length < 2`:
    - `results.clear()`
    - Kryhet `notifyListeners()` pa bërë asnjë kërkim.
  - Përndryshe, krijohet një `Timer` 300ms që pas skadimit:
    - thërret `_ensureProductsLoaded()` (lexon produktet vetëm në thirrjen e parë),
    - dhe më pas `_applySearch()`.
- `submitQuery()` thërret `_ensureProductsLoaded()`, `_applySearch()` dhe ruan query-n në recent searches vetëm nëse është të paktën 2 karaktere.

Kjo shmang kërkimet e panevojshme gjatë shtypjes së shpejtë.

---

## Recent searches — si ruhen dhe shfaqen

### Storage

- Shtuar `RecentSearchStorage` bazuar në `SharedPreferences`:
  - Key: `recent_searches_v1`
  - Ruhet si `List<String>` e serializuar me `jsonEncode`.
  - Maksimumi 8 kërkime:
    - Query i ri futet në krye të listës
    - Duplicatët hiqen (nëse query ekziston, largohet nga pozicionet e tjera)
    - Nëse lista kalon 8 elementë, bishti pritet.

### Rrjedha

- Në `SearchController.loadInitial()` lexohen recent searches dhe ekspozohen në `recentSearches`.
- Kur përdoruesi bën submit (p.sh. shtyp Enter në tastierë ose thjesht pret të aplikohen rezultatet) thirret `submitQuery()`:
  - Nese query ka ≥ 2 karaktere → `RecentSearchStorage.addQuery(query)` dhe refresh i listës.
- `clearRecentSearches()` thërret `RecentSearchStorage.clear()` dhe boshatis `recentSearches`.
- Kur query bosh dhe ekzistojnë `recentSearches`, `SearchScreen` shfaq seksionin:
  - Titull “Kërkimet e fundit”
  - `ActionChip` për secilën query
  - Buton “Fshij të gjitha” për clear.
- Tap në një chip thërret `selectRecentQuery(q)`:
  - Vendos `query = q`,
  - refreshon UI dhe aplikon kërkimin mbi cache ekzistuese pa lexime të reja Firestore.

Skedar:
- `lib/features/search/data/local/recent_search_storage.dart`

---

## Si shmangen Firestore reads të tepërta

- `ProductRepositoryImpl.getAll()` tashmë bazohet në `ProductDataSource.getAllProducts()` me cache 5-min (ekzistues).
- `SearchController` përdor vetëm `GetAllProductsUseCase` një herë për seancë search-i:
  - `_ensureProductsLoaded()` kontrollon `hasLoadedProducts` dhe `isSearching` për të mos rifilluar fetch-in.
  - Pas leximit të parë, të gjitha kërkimet e mëvonshme janë **thjesht filtrime në memory**.
- Nuk ka query Firestore per karakter — Firestore lexohet vetëm nëpërmjet pipeline-it standard `getAllProducts`.

---

## UI bazë & komponentë ekzistues

- `CavaSearchBar` në Home **nuk ndryshon pamjen**:
  - ende shfaq ikonën e kërkimit + hint text “Kërko produkte…”
  - tani vetëm ka `onTap` për të hapur search.
- `SearchScreen` përdor:
  - `CavaSearchBar` si fushë search në AppBar, duke ruajtur vizualin konsistent.
  - `ProductGridCard` për shfaqjen e rezultateve:
    - përdor `ProductImageView` për foto reale
    - ka `ProductWishlistToggle` që vazhdon të funksionojë si më parë
    - tap në card hap `ProductDetailScreen` përmes `AppRoutes.product(id)` (sjellje ekzistuese e `ProductGridCard`).
- Home layout (sections, category chips, visit store banner, etj.) mbetet identik.
- Nuk u prekën: Cart, Wishlist, Checkout, Auth, Orders, backend/web, Firestore rules.

Skedarë UI të prekur:
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/search/presentation/screens/search_screen.dart`
- Komponentë ekzistues: `CavaSearchBar`, `ProductGridCard`, `ProductImageView`.

---

## Testet

### Logjika e kërkimit

- `test/features/search/presentation/controllers/search_controller_test.dart`:
  - **minimum 2 chars**: siguron që query me 1 karakter nuk gjeneron rezultate.
  - **debounce 300ms**: verifikon që rezultatet shfaqen vetëm pasi të ketë kaluar debounce.
  - **filter fushash**: kërkimi për “Test Wine” gjen `testProductEntity`.
  - **recent searches save/load/clear**: ruajtja e një query të ri, shmangia e duplicate-ve dhe delegimi te `RecentSearchStorage.clear()`.

### Navigimi & UI

- Ruta `AppRoutes.search` shtohet në `app_router.dart` si `MaterialPage` me `state.pageKey`, pa prekur ShellRoute/BottomNavigation keys.
- Pjesa e navigimit nga `ProductGridCard` në `ProductDetailScreen` testohen tashmë nga testet ekzistuese të produktit.

---

## Rezultatet

### flutter analyze
```
2 info (avoid_types_as_parameter_names në cart_firestore_datasource.dart)
0 errors, 0 warnings
```

### flutter test
```
All tests passed! (310 tests)
```

---

## Rezultati final

Search bar në Home tani hap një ekran dedikuar kërkimi (`/search`) që përdor produktet reale nga cache ekzistuese (`getAllProducts`), aplikon debounce 300ms me minimum 2 karaktere, kërkon në emër, brand, kategori, përshkrim, origjinë, lloj dhe volum me relevance të thjeshtë, ruan recent searches në SharedPreferences, shmang Firestore reads të tepërta dhe ruan UI bazë të aplikacionit identik.

