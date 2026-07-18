# QUPU_IN_APP_WEBVIEW_REPORT

Data: 2026-07-18
Projekti: `cava_ecommerce` (Flutter). Backend-i (`cava`) i paprekur.

## 1. Çfarë u ndryshua

Hosted Payment Page e Quipu nuk hapet më në Safari/browser të jashtëm: tani
hapet **brenda aplikacionit si ekran i plotë me WebView** (`webview_flutter`
^4.13.0, paketë e re — projekti nuk kishte zgjidhje WebView më parë). I gjithë
flow-i ekzistues mbetet i pandryshuar:

- `placeOrder`, `initiateQuipuPayment`, `verifyQuipuPayment`, idempotency,
  stoku, shporta dhe backend-i: **të paprekura**.
- Asnjë fushë Flutter për numër karte / CVV / expiry — të dhënat futen vetëm
  brenda faqes së sigurt të Quipu, tani të shfaqur në WebView.
- Suksesi shfaqet **vetëm** kur backend-i kthen `verifiedPaid=true`; arritja e
  return URL-së në WebView vetëm mbyll WebView-në dhe nis verifikimin.
- Fallback-u ekzistues në browser të jashtëm **nuk u hoq** (shih §4).
- Asnjë UI/logjikë jashtë ekranit të pagesës me kartelë nuk u ndryshua.

## 2. File-t e krijuar dhe ndryshuar

**Të krijuar:**

| File | Roli |
|---|---|
| `lib/features/checkout/domain/utils/quipu_hpp_navigation_policy.dart` | Policy pure-Dart e navigimit: allow / interceptReturn / openExternal + nxjerrja e `transactionId` |
| `lib/features/checkout/presentation/screens/quipu_hpp_webview_screen.dart` | Ekrani full-screen WebView (loading, error, retry, browser fallback, back handling) |
| `test/features/checkout/domain/utils/quipu_hpp_navigation_policy_test.dart` | 11 teste të URL interception |

**Të ndryshuar:**

| File | Ndryshimi |
|---|---|
| `pubspec.yaml` | + `webview_flutter: ^4.13.0` |
| `lib/features/checkout/presentation/screens/card_payment_screen.dart` | `_openPaymentPage` hap WebView-në në vend të browser-it; trajton rezultatet returned/dismissed/external; `_openExternalBrowser` mbetet si fallback (buton në gjendjen error) |
| `lib/l10n/app_sq.arb`, `lib/l10n/app_en.arb` (+ të gjeneruarat) | 3 çelësa të rinj: `cardPaymentWebviewLoadError`, `cardPaymentRetry`, `cardPaymentOpenInBrowser` |
| `test/features/checkout/presentation/controllers/card_payment_controller_test.dart` | Test i ri i return-flow: interceptim → transactionId përputhet → verifikim server-side vendos statusin |

Asnjë ndryshim në `CardPaymentController`, domain entities, data layer,
backend, router apo DI — WebView është vetëm shtresë prezantimi.

## 3. Flow-i WebView → return URL → backend verification

```
CardPaymentScreen.start ──► initiateQuipuPayment CF ──► redirectUrl (i njëjti)
        │
        ▼
QuipuHppWebviewScreen (full-screen, MaterialPageRoute fullscreenDialog)
  WebViewController + NavigationDelegate.onNavigationRequest
        │
        ├─ http/https (HPP, 3DS/ACS) ──────────────► lejohet në WebView
        ├─ path == /payment/return ────────────────► PREVENT + pop(HppWebviewReturned(txId))
        │   (URL-ja e kthimit NUK ngarkohet kurrë)
        └─ skema jo-web (bankapp://, intent://…) ──► PREVENT + external app fallback
        │
        ▼
CardPaymentScreen merr rezultatin:
  HppWebviewReturned  → controller.verifyNow() → verifyQuipuPayment CF
  HppWebviewDismissed → mbetet awaitingPayment (JO anulim, JO verifikim automatik)
  HppWebviewOpenedExternally → verifikim në app-resume ose me butonin "Verifiko"
        │
        ▼
Vetëm verifiedPaid=true → paid (pastro shportën); ndryshe pending/failed/
cancelled/expired — identike me flow-n ekzistues.
```

- `transactionId` nga return URL-ja nxirret nga policy (kufi 128 karaktere) dhe
  krahasohet/mbulohet nga ai i ruajtur lokalisht — verifikimi përdor gjithmonë
  transaksionin e ruajtur të controller-it.
- **Back button**: nëse WebView ka histori → `goBack()` një faqe; përndryshe
  del nga ekrani me `HppWebviewDismissed` — pagesa **nuk** shënohet e anuluar
  pa verifikim (statusi `cancelled` vjen vetëm nga gateway përmes
  `verifyQuipuPayment`). `PopScope(canPop:false)` e zbaton edhe për back-un e
  sistemit (Android).
- **Loading**: `LinearProgressIndicator` mbi WebView gjatë `onPageStarted` →
  `onPageFinished`.
- **Gabimet e WebView**: vetëm dështimet e main-frame (`isForMainFrame`)
  kalojnë në gjendjen e gabimit me "Provo përsëri" (reload) dhe "Hape në
  shfletues" (fallback).

## 4. 3D Secure dhe external-app fallback

- Të gjitha redirect-et http/https (HPP → ACS → HPP) lejohen brenda WebView-së
  me `JavaScriptMode.unrestricted`; `about:`/`data:`/`blob:` lejohen për
  iframe-t/interstitial-et e 3DS.
- Skemat jo-web (`bankid://`, `intent://`, apps bankare, `mailto:`, `tel:`)
  bllokohen në WebView dhe hapen me `url_launcher`
  (`LaunchMode.externalApplication`). Pas handoff-it të suksesshëm, WebView
  mbyllet me `HppWebviewOpenedExternally` dhe verifikimi vazhdon në kthimin e
  aplikacionit në foreground (lifecycle observer ekzistues) ose me butonin
  manual "Verifiko pagesën".
- Fallback-u i plotë në browser mbetet i arritshëm në dy vende: nga gjendja e
  gabimit e WebView-së dhe nga gjendja `error` e CardPaymentScreen ("Hape në
  shfletues" mbi të njëjtin redirect URL).
- **Kujdes**: nuk pretendohet që 3D Secure funksionon në të gjitha bankat pa
  test end-to-end. Sjellja e ACS-ve reale (popup, skema apps bankare specifike,
  `window.open`) — Unable to verify from current codebase; kërkon test manual
  në sandbox (§6).

## 5. Rezultatet e analyze dhe tests

- `flutter pub get`: OK (`webview_flutter 4.x` + platform packages).
- `dart format`: u formatuan **vetëm** 15 skedarët e prekur nga ky ndryshim.
  (`dart format .` mbi gjithë projektin do të riformatonte 224 skedarë të
  palidhur — u shmang qëllimisht për të mos prekur kod jashtë fushës së
  task-ut.)
- `flutter analyze`: **0 probleme nga ndryshimet e reja** (2 warnings
  para-ekzistuese në `add_address_bottom_sheet.dart`, skedar i paprekur).
- `flutter test test/features/checkout`: **84/84 kaluan**, përfshirë:
  - 11 teste të reja të `QuipuHppNavigationPolicy` (lejimi i HPP/3DS URL-ve,
    interceptimi i return URL në çdo host, trailing slash + query + fragment,
    nxjerrja/refuzimi i `transactionId`, skema bankare → external, input i
    paparsueshëm → external);
  - 1 test i ri return-flow (interceptim → përputhje transactionId → redirect
    pa `verifiedPaid` NUK është sukses → verifikimi e vendos `paid` dhe pastron
    shportën);
  - të gjitha testet ekzistuese të controller-it, checkout-it, cash/bank të
    pandryshuara.
- Testet e WebView-së si widget nuk u shtuan: `webview_flutter` kërkon
  platform view reale; logjika e interceptimit u nxor te policy pure-Dart
  pikërisht që të testohet pa WebView.
- Suite e plotë e projektit ka 5 dështime **para-ekzistuese** (verifikuar në
  worktree të pastër të HEAD pa këto ndryshime): DI test (Firebase eager init),
  2 teste cart delegimi, 1 string i order formatters, dhe `widget_test.dart`
  (timeout 10-min edhe në HEAD të pastër). Asnjëri nuk lidhet me Quipu/WebView.

## 6. Çfarë duhet testuar manualisht në Quipu sandbox

1. Pagesë e plotë me kartë testi në HPP brenda WebView → kthimi intercepton
   `/payment/return` → verifikimi kthen `verifiedPaid=true` → ekrani "paid"
   dhe shporta pastrohet.
2. **3D Secure challenge reale** në WebView (ACS e sandbox-it): redirect-et
   hyrëse/dalëse, iframe-t, dhe kthimi në HPP. Unable to verify from current
   codebase — duhet provuar me kartat e testit 3DS të Quipu-s.
3. Anulim brenda HPP dhe back button (me/pa histori WebView): statusi mbetet
   pending/cancelled sipas gateway-t, shporta e paprekur.
4. Gabim rrjeti gjatë ngarkimit → gjendja e gabimit → "Provo përsëri" dhe
   "Hape në shfletues".
5. Skemë bankare / app i jashtëm nga faqja e pagesës (nëse sandbox-i e ofron)
   → hapja e aplikacionit të jashtëm → kthimi në app → verifikimi në resume.
6. iOS dhe Android reale: rendering i HPP në WKWebView / Android WebView
   (Unable to verify from current codebase — s'u ekzekutua në pajisje).

## 7. Gati për testim real?

**Po, nga ana e kodit** — flow-i është i plotë, i analizuar dhe i mbuluar me
teste; backend-i nuk kërkon asnjë ndryshim (return URL-ja mbetet e njëjta dhe
tani thjesht interceptohet para ngarkimit). Kushtet e mbetura para testimit
real në sandbox: funksionet me sekretet Quipu të deploy-uara (Unable to verify
from current codebase: gjendja e deploy-it) dhe verifikimi manual i pikave të
§6, veçanërisht 3D Secure në pajisje reale iOS/Android.
