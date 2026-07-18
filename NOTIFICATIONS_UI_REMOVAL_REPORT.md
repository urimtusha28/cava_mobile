# NOTIFICATIONS_UI_REMOVAL_REPORT

Data: 2026-07-18
Projekti: `cava_ecommerce` (Flutter).

> **Rishikim sipas kërkesës së përdoruesit:** fillimisht ishte hequr i gjithë
> UI i njoftimeve (bottom sheet, controllers, DI, l10n, asset). Me kërkesë,
> gjithçka u rikthye siç ishte — **e vetmja gjë e hequr tani është ikona e
> ziles nga AppBar**, kështu që njoftimet nuk shfaqen më askund në aplikacion.

## 1. Çfarë u hoq (gjendja përfundimtare)

- **Vetëm ikona e ziles** (`_RingingAction`) nga `CavaAppBar` — shfaqej në çdo
  ekran me `isLogo: true` (Home, Categories, Cart, Wishlist, Profile, etj.).
  Kjo ishte **pika e vetme e hyrjes** drejt `NotificationsBottomSheet` dhe
  unread badge-it, prandaj me heqjen e saj asnjë UI njoftimesh nuk është më i
  arritshëm.
- Bashkë me të: `Badge`-wrapper-i në `_AppBarIconButton` (përdorej vetëm nga
  zilja për unread counter) dhe 3 imports që mbeteshin të papërdorur.

## 2. File-t e ndryshuar

| File | Ndryshimi |
|---|---|
| `lib/core/widgets/cava_app_bar.dart` | Hequr `_RingingAction` + badge-i i `_AppBarIconButton` + imports e papërdorura; `actions` → `[_ChatAction()]` |

**Asnjë file tjetër i ndryshuar dhe asnjë file i fshirë.** Të rikthyera
plotësisht siç ishin (pas rishikimit):

- `lib/core/widgets/notifications_bottom_sheet.dart`
- `lib/features/notifications/presentation/` (controller, unread notifier,
  presentation utils)
- Thirrjet `ensureNotificationsBadgeListening()` në `SplashScreen` dhe
  `NavigationBadgeController` (mbajnë unread notifier-in funksional, thjesht pa
  UI që e shfaq)
- Regjistrimet DI (`NotificationsUnreadNotifier`, `NotificationsController`)
- Çelësat l10n `notifications*` (sq/en)
- `AppAssets.ringing`, hyrja në `pubspec.yaml` dhe `assets/icons/ringing.png`

## 3. Çfarë mbeti i paprekur

- I gjithë backend-i/data layer i njoftimeve (repository, datasource, entitete,
  koleksionet Firestore) — përdoret edhe nga owner support
  (`AdminCreateNotificationUseCase`).
- Ikona e support/chat-it (`_ChatAction`) — pas heqjes së ziles, `AppBar` e
  rendit vetë pastër djathtas; asnjë rregullim spacing-u s'ishte i nevojshëm.
- Porositë, checkout-i, Quipu, bottom navigation, çdo UI/logjikë tjetër.

## 4. Rezultatet e analyze dhe tests

- `flutter analyze`: **0 probleme nga ndryshimi** (2 warnings para-ekzistuese
  në `add_address_bottom_sheet.dart`, skedar i paprekur).
- `flutter test test/features/checkout test/core`: **133/134 kaluan**; dështimi
  i vetëm është testi para-ekzistues i DI (`injection_test.dart`,
  "No Firebase App '[DEFAULT]'"), i verifikuar më herët si i dështuar edhe në
  HEAD të pastër pa asnjë nga ndryshimet e këtij sesioni.

## 5. Konfirmimi

- `_RingingAction` nuk ekziston më; `grep` konfirmon që
  `showNotificationsBottomSheet` nuk thirret nga asnjë vend në `lib/`
  (skedari i bottom sheet-it ekziston, por asgjë s'e hap më).
- Zilja nuk shfaqet më në asnjë AppBar dhe bottom sheet-i "Njoftimet" nuk mund
  të hapet nga asnjë rrugë e aplikacionit.
- Verifikim vizual në pajisje/simulator: Unable to verify from current
  codebase — s'u ekzekutua aplikacioni në pajisje reale në këtë sesion.
