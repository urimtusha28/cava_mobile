# OWNER_DASHBOARD_FIREBASE_INTEGRATION_REPORT

**Data:** 13 Korrik 2026  
**Scope:** Lidhja e Owner Dashboard Flutter me burimet reale të admin Overview (website)

---

## 1. Si funksiononte dashboard-i web (audit)

Burimi: `/Users/urim/VscProjects/cava`

### Faqet kryesore
- `src/pages/admin/OverviewPage.tsx` — KPI + grafik + porosi të fundit + donut fulfillment
- `src/pages/admin/AnalyticsPage.tsx` — 7/30/90 ditë + payment/fulfillment
- `src/services/firestoreStats.ts` — lexime `statsDaily` + `stats/productsSummary`
- `src/services/firestoreOrders.ts` — `fetchRecentOrdersForAdmin(8)`

### Çfarë NUK ekziston në web admin
- KPI fiks “shitjet sot / këtë javë kalendarike / këtë muaj kalendarik”
- Top selling products
- Lista e produkteve me stok të ulët (vetëm **numra** agregat)
- “Klientë të rinj” si signups në `users`

Web përdor **rolling UTC 7 / 30 / 90 ditë** mbi `statsDaily`, jo javë/muaj kalendarik lokal.

---

## 2. Burimet reale të të dhënave

| Collection / Doc | Përdorim |
|------------------|----------|
| `statsDaily/{YYYY-MM-DD}` | Revenue, orderCount, uniqueBuyerCount, donut_*, pay* |
| `stats/summary` | `totalRevenue`, `totalOrders`, `openOrdersCount` (lifetime) |
| `stats/productsSummary` | `inStock`, `lowStock`, `outStock` |
| `orders` | Porositë e fundit (`orderBy createdAt desc limit 8`) |
| `products` | Lista low-stock (mobile UX; pragu i njëjtë 1–9) |
| `metricsDaily` | **JO** për shitje (vetëm system/POS) |

### Cloud Functions (agregim, jo callable dashboard)
- `onOrderCreatedAggregateStats` / `onOrderUpdatedStats` — `functions/src/orderStats.ts`
- `onProductWriteMaintainSummary` — `functions/src/productStats.ts`

**Nuk ka** Cloud Function callable për dashboard metrics. Mobile lexon Firestore si web Overview.

---

## 3. Formulat (mobile = web)

| Metrika mobile | Formula / burim | Semantikë |
|----------------|-----------------|-----------|
| Shitjet Sot | `statsDaily/{todayUTC}.revenue` | Para (€), volum porosish |
| Shitjet 7 ditë | Sum `revenue` rolling 7 UTC | Si Overview 7d |
| Shitjet 30 ditë | Sum `revenue` rolling 30 UTC | Si Overview 30d |
| Totali i të Ardhurave | `stats/summary.totalRevenue` | Lifetime |
| Numri i Porosive | `stats/summary.totalOrders` | Lifetime |
| Porosi në Pritje | Sum `donut_received` (30d) | Fulfillment |
| Porosi në Proces | Sum confirmed+prepared+shipped+in_transit (30d) | Fulfillment |
| Porosi të Përfunduara | Sum `donut_delivered` (30d) | Fulfillment |
| Porosi të Anuluara | Sum canceled+returned (30d) | Fulfillment |
| Grafiku | `statsDaily.revenue` series 7d UTC | Para/ditë |
| Porositë e fundit | `orders` createdAt desc limit 8 | Si web |
| Stok i ulët (count) | `stats/productsSummary.lowStock` | stock 1–9 |
| Stok i ulët (listë) | Query `products` stock &lt; 10, filter 1–9, limit 10 | UX mobile |
| Klientë | Sum `uniqueBuyerCount` 30d | **Jo** user signups |
| Top products | **Bosh** | Nuk ekziston në web |

### Revenue rules (nga `orderStatsShared` / `orderPricingTotals`)
- Vlera = `totals.total` (subtotal + VAT + shipping − discount)
- Përfshin cash/bank/stripe, unpaid/pending/paid
- **Nuk** heq porositë e anuluara nga revenue në create
- Data bucket = `createdAt` → UTC day key (`toISOString().slice(0,10)`)
- **Nuk** ekziston `paidAt`

---

## 4. Çfarë u implementua në Flutter

Clean Architecture:

```
lib/features/owner_dashboard/
  domain/entities, repositories, usecases, utils
  data/datasources, mappers, repositories
  presentation/controllers, screens
```

- Hiqur `OwnerDashboardPlaceholderData`
- Loading / empty / error / refreshing states
- Pull-to-refresh
- Permission-denied → mesazh i qartë (pa raw Firebase exception)

---

## 5. File-t e rinj

- `domain/entities/owner_dashboard_entities.dart`
- `domain/repositories/owner_dashboard_repository.dart`
- `domain/usecases/get_owner_dashboard_snapshot.dart`
- `domain/utils/owner_dashboard_metrics.dart`
- `data/mappers/owner_dashboard_mapper.dart`
- `data/datasources/owner_dashboard_data_source.dart`
- `data/datasources/owner_dashboard_firebase_datasource.dart`
- `data/repositories/owner_dashboard_repository_impl.dart`
- `presentation/controllers/owner_dashboard_controller.dart`
- `test/features/owner_dashboard/owner_dashboard_metrics_test.dart`
- `test/features/owner_dashboard/owner_dashboard_controller_test.dart`
- `OWNER_DASHBOARD_FIREBASE_INTEGRATION_REPORT.md`

## 6. File-t e modifikuar

- `presentation/screens/owner_dashboard_screen.dart` (+ analytics/orders/products)
- `lib/core/di/injection.dart`
- `lib/core/firebase/firebase_config.dart` (`stats`, `statsDaily`)
- Fshirë: `data/owner_dashboard_placeholder_data.dart`

---

## 7. Firestore indexes

Query e re (lista low-stock):

```
products where stock < 10 orderBy stock
```

Nëse Firebase kërkon indeks, krijo single-field ose composite për `stock` Ascending.  
Në mungesë indeksi, lista kthehet bosh; **numrat** nga `productsSummary` mbeten.

Indeksi ekzistues për recent orders: `orders.createdAt` desc (përdoret edhe nga web).

---

## 8. Ndryshimet në rules

**Asnjë.** `stats`, `statsDaily`, `orders` (admin read), `products` (admin read) tashmë lejojnë `isAdmin()` (claim `admin` ose `users.role == admin`).

---

## 9. Strategjia realtime / fetch

| Seksion | Strategji |
|---------|-----------|
| Summary + chart + statuset | One-shot `get` mbi `statsDaily` + `stats/*` |
| Recent orders | One-shot `get` (si Overview poll, jo listener) |
| Low stock counts | One-shot `productsSummary` |
| Low stock list | One-shot query products |
| Refresh | Pull-to-refresh manual |

Nuk u shtua polling 5-min (web); mobile përdor refresh manual për të kursyer reads.

---

## 10. Error handling

- `permission-denied` → `AuthFailure` + UI error + retry
- Gabime të tjera Firebase → `ServerFailure` me mesazh shqip
- Low-stock query fail → listë bosh, pa rrëzuar gjithë dashboard-in
- Top products → empty state i dokumentuar (jo shifra false)

---

## 11. Testet

- `owner_dashboard_metrics_test.dart` — UTC keys, donut buckets, stock threshold, aggregate mapper, orderNumber
- `owner_dashboard_controller_test.dart` — success, empty, permission error, refresh partial failure, use case guard

---

## 12. Krahasimi mobile vs website

| Metrika | Përputhje | Shënim |
|---------|-----------|--------|
| Revenue 7d / 30d | Po | I njëjti rolling UTC + `statsDaily.revenue` |
| Sot | Po | Dita UTC aktuale |
| Lifetime revenue/orders | Po | `stats/summary` |
| Recent orders (8) | Po | I njëjti query |
| Low stock count | Po | `productsSummary`, prag 1–9 |
| Klientë | Po (semantikë Overview) | Sum daily unique buyers — **jo** “të rinj” signup |
| Top products | N/A | Bosh në të dyja (web nuk e ka) |
| Status buckets | Pjesërisht | Web tregon donut të detajuar; mobile grupon për kartat ekzistuese |

### Mospërputhje të mbetura / të qëllimshme
1. Labelat fillestare “Këtë Javë / Muaj” u riformuluan në UI si **7 ditë / 30 ditë** për të mos gënjyer (web nuk përdor kalendar lokal).
2. “Klientët e rinj” → “Blerës unikë ditorë (30 ditë)” — e njëjta metrikë si Overview “Klientë”.
3. Lista low-stock është shtesë mobile (web ka vetëm count).
4. Nuk u bë krahasim live numrash në këtë sesion (kërkon llogari admin + Firebase runtime) — `[E paverifikueshme pa mjedis live]`.

---

## 13. Verifikim manual i rekomanduar

1. Kyçu me user `admin` (claim ose `users.role`).
2. Hap `/owner` dhe Overview web për të njëjtën ditë UTC.
3. Krahaso: 7d revenue, 30d revenue, lifetime totals, recent 8 orders, lowStock count.
4. Customer/guest që hap `/owner` → redirect Home; nëse forcohet fetch → permission error.
