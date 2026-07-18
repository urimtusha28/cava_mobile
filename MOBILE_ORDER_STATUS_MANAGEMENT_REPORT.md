# Mobile Order Status Management Report

## Problemi para ndryshimit

Në mobile ekzistonte vetëm shfaqja read-only e porosive. Owner/admin nuk mund ta ndryshonte `fulfillmentStatus` nga aplikacioni, edhe pse web-admin përdorte tashmë një kontratë të qartë backend-i me tranzaksione Firestore, `statusTimeline`, rregulla tranzicioni dhe side effects për stokun/pagesën.

## Kontrakti real i backend-it

Implementimi në mobile u portua sipas sjelljes së web-admin:

- Fushat kryesore të update-it: `fulfillmentStatus`, `status`, `updatedAt`, `statusTimeline`, dhe `paymentStatus` kur nevojitet.
- Normalizimi i statusit aktual:
  - `fulfilled` konsiderohet `delivered`
  - vlera të panjohura bien në `received`
- Raw values të mbështetura:
  - `received`
  - `confirmed`
  - `prepared`
  - `shipped`
  - `in_transit`
  - `delivered`
  - `returned`
  - `canceled`
- Rregullat e tranzicionit:
  - nga çdo status jo-terminal lejohet kalimi në çdo status tjetër
  - nga `returned` dhe `canceled` nuk lejohet ndryshim i mëtejshëm
- Side effects të portuara:
  - kur statusi kalon në `canceled`, rikthehet `stock` për secilin `items[].productId`
  - kur statusi kalon në `delivered`, dhe porosia ka `paymentMethod == cash` dhe `paymentStatus == unpaid`, pagesa përditësohet në `paid`
  - `statusTimeline` merr hyrje të re me `status`, `label`, `at`, dhe opsionalisht `by`

## Skedarët e ndryshuar

- Domain/data:
  - `lib/features/account/domain/entities/order_entity.dart`
  - `lib/features/account/domain/entities/order_customer_entity.dart`
  - `lib/features/account/domain/entities/order_fulfillment_status.dart`
  - `lib/features/account/domain/utils/order_fulfillment_status_machine.dart`
  - `lib/features/account/domain/repositories/orders_repository.dart`
  - `lib/features/account/domain/usecases/get_order_by_id_for_admin.dart`
  - `lib/features/account/domain/usecases/update_order_fulfillment_status.dart`
  - `lib/features/account/data/models/order_model.dart`
  - `lib/features/account/data/mappers/order_mapper.dart`
  - `lib/features/account/data/datasources/orders_data_source.dart`
  - `lib/features/account/data/datasources/orders_firebase_datasource.dart`
  - `lib/features/account/data/datasources/orders_mock_datasource.dart`
  - `lib/features/account/data/repositories/orders_repository_impl.dart`
  - `lib/core/di/injection.dart`
- UI/l10n:
  - `lib/features/account/presentation/widgets/order_detail_bottom_sheet.dart`
  - `lib/features/account/presentation/screens/orders_screen.dart`
  - `lib/features/account/presentation/utils/order_formatters.dart`
  - `lib/features/account/presentation/utils/order_fulfillment_status_l10n.dart`
  - `lib/features/owner_dashboard/presentation/screens/owner_orders_screen.dart`
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_sq.arb`
  - gjeneruar nga `flutter gen-l10n`: `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`, `lib/l10n/app_localizations_sq.dart`
- Teste:
  - `test/features/account/domain/utils/order_fulfillment_status_machine_test.dart`
  - `test/features/account/presentation/screens/orders_screen_test.dart`
  - `test/helpers/test_di.dart`

## Arkitektura dhe rrjedha e të dhënave

1. UI hap bottom sheet-in e detajeve të porosisë.
2. Nëse user-i është owner/admin, bottom sheet bën `getOrderByIdForAdmin` për të marrë snapshot-in e plotë të porosisë.
3. Dropdown-i i statusit ndërtohet nga `allowedStatusesForCurrent`.
4. Pas konfirmimit, UI thërret `UpdateOrderFulfillmentStatusUseCase`.
5. Use case:
   - thërret repository/data source për update transaksional
   - bën re-fetch me `getOrderByIdForAdmin`
   - kthen porosinë e rifreskuar
6. Bottom sheet rifreskon veten dhe thërret callback-un `onOrderUpdated`.
7. Lista përditëson vetëm kartën përkatëse pa loading global.

## Raw values vs labels

Raw values mbeten të pandryshuara në storage dhe kontrata backend:

- `received`
- `confirmed`
- `prepared`
- `shipped`
- `in_transit`
- `delivered`
- `returned`
- `canceled`

Mapimi i label-ave të UI është centralizuar te:

- `lib/features/account/presentation/utils/order_fulfillment_status_l10n.dart`

Ky util jep etiketat e lokalizuara për detajet dhe selector-in e statusit.

## Autorizimi

- Kontrolli i UI bëhet me `AppSessionNotifier.instance.isOwner`.
- User jo-owner sheh vetëm detaje read-only, pa dropdown editimi.
- Verifikimi real i shkrimit mbetet në backend/Firestore rules:
  - `orders/{orderId}` lejon `update` vetëm për admin sipas rregullave ekzistuese.

## Verifikimi i ekzekutuar

Komandat e ekzekutuara:

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test test/features/account/domain/utils/order_fulfillment_status_machine_test.dart test/features/account/presentation/screens/orders_screen_test.dart`

Rezultatet reale:

- `flutter gen-l10n`: sukses
- `flutter test ...`: sukses
- `flutter analyze`: pa errore nga ndryshimet e reja; mbeten 2 çështje ekzistuese, të palidhura me këtë task:
  - `lib/features/account/presentation/widgets/add_address_bottom_sheet.dart`: `prefer_final_fields`
  - `lib/features/account/presentation/widgets/add_address_bottom_sheet.dart`: `unused_field`

## Çfarë mbulojnë testet

- normalizimi i statusit (`fulfilled` -> `delivered`, fallback -> `received`)
- statuset e lejuara për gjendje terminale dhe jo-terminale
- dropdown nuk shfaqet për user jo-owner
- ndryshimi i statusit shfaq dialog konfirmimi
- double-submit bllokohet gjatë loading
- pas suksesit:
  - bottom sheet tregon statusin e ri
  - lista përditëson vetëm kartën e saktë
- në dështim:
  - statusi i vjetër mbetet aktiv
  - shfaqet mesazh gabimi i kuptueshëm

## Kufizimet e mbetura

- Owner list përdor override lokal për kartat e përditësuara derisa ekrani të ringarkohet natyrshëm; kjo shmang loading global dhe ruan UI responsive.
- `statusTimeline.label` ruhet me tekst shqip sipas kontratës së portuar; nëse backend-i web ndryshon etiketat në të ardhmen, duhet sinkronizuar edhe mobile.
