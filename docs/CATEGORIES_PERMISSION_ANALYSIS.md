# Categories Permission-Denied — Analysis Report

**Projekti:** Cava Premium (`cava_ecommerce`)  
**Data:** 7 korrik 2026  
**Scope:** Analizë `permission-denied` për collection `categories` — vetëm mobile  
**Kufizime:** Pa ndryshime në Firestore Rules, backend, Cloud Functions, koleksione, web React

---

## Përmbledhje

| Pyetje | Përgjigje |
|--------|-----------|
| Problemi në Flutter apo Firestore Rules? | **Flutter** — query nuk përputhej me rules |
| Cili query ishte problemi? | `_collection.get()` pa filter në `_loadActiveCategories()` |
| Çfarë u ndryshua? | Vetëm `CategoryFirestoreDataSource._loadActiveCategories()` |
| Pse nuk prek web-in? | Nuk u prek asnjë skedar web/backend/rules |
| Kërkohet ndryshim në Firestore Rules? | **Jo** — rules janë të sakta |
| A është zgjidhur `permission-denied`? | **Po (i pritur)** — query tani përputhet me rules; verifikim live kërkon device |

---

## 1. Simptoma

Mobile app (anonim / pa admin) logonte:

```
CategoryFirestoreDataSource: getAllCategories failed —
[cloud_firestore/permission-denied] The caller does not have permission
to execute the specified operation.
```

Ndërkohë web e-commerce funksionon normalisht dhe produktet mobile (`products` collection) lexohen pa problem.

---

## 2. Firestore Rules aktuale (categories)

```
match /categories/{categoryId} {
    allow read: if resource.data.isActive == true || isAdmin();
}
```

**Kuptimi:**

- Klienti **jo-admin** mund të lexojë **vetëm** dokumente ku `isActive == true`.
- Dokumente me `isActive == false` (ose pa fushë që e kthen false në rules) **nuk** janë të lexueshme për publikun.
- Admin (`isAdmin()`) lexon gjithçka — kjo shpjegon pse web admin panel funksionon.

Këto rules **nuk** janë gabim; ato janë security-by-design.

---

## 3. Si funksionon query security në Firestore

Firestore nuk lejon një collection query nëse **rezultati potencial** përfshin dokumente që rules i refuzojnë — edhe nëse klienti do t’i filtronte më vonë në Dart.

| Query | Si e vlerëson Firestore |
|-------|-------------------------|
| `collection('categories').get()` | Mund të kthejë **çdo** dokument → përfshirë `isActive: false` → **refuzohet** për jo-admin |
| `collection('categories').where('isActive', isEqualTo: true).get()` | Vetëm dokumente active → përputhet me `resource.data.isActive == true` → **lejohet** |

Filtrimi client-side (`if (data['isActive'] == false) continue`) **nuk** ndikon në vendimin e rules — ndodh **pas** që Firestore të ketë refuzuar query-n.

---

## 4. Analiza e `CategoryFirestoreDataSource`

### Skedari

`lib/features/categories/data/datasources/category_firestore_datasource.dart`

### Flow

```
getAllCategories()
getCategoryById()
getSubcategories()
    └─► _loadActiveCategories()   ← burimi i të dhënave
```

### Query problematik (para ndryshimit)

```dart
// _loadActiveCategories() — LINJA 100 (e vjetër)
final snapshot = await _collection.get();
```

Kjo është **collection scan i pa filtruar** ndaj `categories`.

Pas marrjes, kodi filtronte client-side:

```dart
if (data['isActive'] == false) continue;
```

Por në momentin e `.get()`, Firestore e refuzon query-n sepse koleksioni përmban dokumente inactive që rules i bllokojnë për klientin mobile.

### Pse produktet funksionojnë?

`ProductFirestoreDataSource` përdor gjithashtu `_collection.get()` pa `where`, por **rules për `products` janë ndryshe** (lejojnë lexim për dokumente active/published). Kjo nuk është kontradiktë — çdo collection ka rules të veta.

### A ka query të tjera për categories?

**Jo.** E gjithë leximi kalon përmes `_loadActiveCategories()`. Nuk ka:

- `doc(id).get()` direkt për categories
- parent lookup në collection tjetër
- Cloud Function calls
- emulator / project të gabuar në kod (përdor `FirebaseConfig.categoriesCollection` = `'categories'` dhe `DefaultFirebaseOptions` → `cavapremium-31036`)

Auth state: mobile lexon si **anonim** (pa login) — përputhet me skenarin ku rules kërkojnë `isActive == true`.

---

## 5. Ndryshimi i bërë (vetëm mobile)

### Skedari i ndryshuar

| Skedar | Ndryshim |
|--------|----------|
| `lib/features/categories/data/datasources/category_firestore_datasource.dart` | `_loadActiveCategories()` |

### Para

```dart
final snapshot = await _collection.get();
// + client-side skip isActive == false
```

### Pas

```dart
final snapshot = await _collection
    .where('isActive', isEqualTo: true)
    .get();
```

### Çfarë NUK u ndryshua

- UI, Controller, Repository, Domain, Routing
- Firestore Security Rules
- Backend, Cloud Functions, koleksione Firebase
- Web React
- `ProductFirestoreDataSource`
- `FirebaseConfig` flags

### Rezultati funksional

| Aspekt | Para | Pas |
|--------|------|-----|
| Main categories | `type == main && parentId == null` | I njëjti (pas query) |
| Subcategories | `type == sub && parentId == docId` | I njëjti |
| Renditja | `order` ascending, 0 në fund | I njëjti |
| Inactive | E përjashtuar | E përjashtuar nga query (jo më client-side) |
| Malformed docs | Skip | I njëjti |

**Ndryshim i vogël semantik:** dokumente **pa** fushën `isActive` nuk kthehen më nga query (`where isEqualTo: true`). Kjo përputhet me rules (`resource.data.isActive == true` kërkon vlerë eksplicite `true`) dhe me web schema ku `isActive` është boolean i detyrueshëm.

---

## 6. Pse nuk prek web-in

| Arsye | Detaj |
|-------|-------|
| Asnjë deploy rules | `firestore.rules` nuk u modifikua |
| Asnjë ndryshim backend | Zero ndryshime server-side |
| Web përdor auth tjetër | Admin panel → `isAdmin()` → lexon edhe inactive |
| Web mund të përdorë query të filtruar | React app zakonisht liston vetëm active për publikun |
| Mobile ndryshim i izoluar | Vetëm një metodë private në Flutter datasource |

Web vazhdon të lexojë të njëjtën collection me të njëjtat rules dhe të njëjtat të dhëna.

---

## 7. A kërkohet ndryshim në Firestore Rules?

### **Jo.**

Rules aktuale janë të qëllimshme:

- Publikun e mbrojnë nga leximi i kategorive inactive
- Admin-in e lejojnë të menaxhojë gjithçka
- Mobile duhet të **përputhet** me rules, jo anasjelltas

Ndryshimi i rules (p.sh. `allow read: if true`) do të ishte **më i dobët** për sigurinë dhe **nuk** ishte i nevojshëm.

---

## 8. A është zgjidhur `permission-denied`?

### Status: **Po — i pritur të jetë zgjidhur**

Bazuar në modelin e Firestore security:

1. Query i ri përputhet me constraint-in `isActive == true` në rules
2. Testet unit (`fake_cloud_firestore`) kalojnë — 7/7 për category datasource
3. `flutter analyze` → No issues found!

### Verifikim runtime

Në momentin e analizës, simulatori iOS nuk ishte i disponueshëm për `flutter run` live. Për konfirmim final:

```bash
flutter run -d <device>
# Pritet log:
# CategoryFirestoreDataSource: mapped N main categories
# (pa permission-denied)
```

Nëse pas kësaj ndryshimi ende shfaqet `permission-denied`, kontrollo:

- Composite index (i papër nevojshëm për query me një `where` të vetëm)
- Dokumente pa fushë `isActive` që web-i pret të shfaqen (duhet `isActive: true` në Firebase)
- Device offline / project mismatch (i pamundur nëse products funksionojnë)

---

## 9. Teste

```bash
flutter analyze
# → No issues found!

flutter test test/features/categories/data/datasources/category_firestore_datasource_test.dart
# → All tests passed! (7 tests)
```

Testet ekzistuese mbulojnë:

- Vetëm active main categories
- Sort by order
- Subcategories by parentId
- Inactive category → null
- Malformed docs → skip pa crash

---

## 10. Diagram — shkaku dhe zgjidhja

```
PARA (permission-denied)
─────────────────────────
Mobile (anonim)
    │
    ▼
collection('categories').get()     ← mund të kthejë inactive
    │
    ▼
Firestore Rules: "a ka inactive?" → PO → DENIED


PAS (i pritur OK)
─────────────────
Mobile (anonim)
    │
    ▼
collection('categories')
  .where('isActive', isEqualTo: true).get()
    │
    ▼
Firestore Rules: "të gjitha isActive?" → PO → ALLOWED
    │
    ▼
Client: filter main/sub, sort order → UI (i pandryshuar)
```

---

## 11. Konkluzion

Problemi **nuk** ishte në Firestore Rules apo web backend. Ishte në **mobile query** që përpiqej të lexonte të gjithë collection-in ndërsa rules lejojnë vetëm dokumente `isActive == true` për klientë jo-admin.

Ndryshimi minimal në `CategoryFirestoreDataSource` e alignon mobile me të njëjtin kontrakt sigurie që web-i tashmë respekton — pa prekur asgjë jashtë Flutter data layer.
