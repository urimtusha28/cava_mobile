# Store Card Image Preview — Report

## Qëllimi

Zëvendësimi i ilustrimit të hartës në **VisitStoreBanner** (Home) me foto reale të lokacionit/store-it, pa ndryshuar layout, tekst, maps logic, ose dimensionet e card-it.

---

## Skedarët e ndryshuar / shtuar

| Skedar | Ndryshim |
|--------|----------|
| `assets/images/store_location.jpg` | **I ri** — kopjuar nga `assets/icons/cava2.png` |
| `assets/icons/cava2.png` | Burimi origjinal i fotos |
| `pubspec.yaml` | Regjistruar `cava2.png` dhe `store_location.jpg` |
| `lib/core/constants/app_assets.dart` | `AppAssets.storeLocation` |
| `lib/core/widgets/visit_store_banner.dart` | `Image.asset` + fallback ilustrim |
| `test/core/widgets/visit_store_banner_test.dart` | Test për image preview |

**Pa ndryshuar:** madhësia e card-it (148px preview), layout, tekstet, adresa, click, dialog, Maps URL, border radius, spacing.

---

## Implementimi vizual

### Preview (148px lartësi)

```dart
Image.asset(
  AppAssets.storeLocation, // assets/images/store_location.jpg
  fit: BoxFit.cover,
  errorBuilder: (_, _, _) => const _MapIllustrationFallback(),
)
```

- **Clip:** Card-i parent ka `clipBehavior: Clip.antiAlias` + `BorderRadius.circular(AppRadius.lg)` — fotoja në pjesën e sipërme respekton të njëjtin radius.
- **Badge:** `"Cava Premium Store"` mbetet `Positioned` bottom-left mbi foto.
- **Pin icon:** Hequr nga qendra — me foto reale nuk përshtatej; `near_me` te adresa mbetet.

### Fallback

Nëse asset-i nuk ngarkohet → `_MapIllustrationFallback` (grid + `surfaceMuted`), e njëjta ilustrim si më parë pa pin.

---

## Assets

| Path | Përshkrim |
|------|-----------|
| `assets/icons/cava2.png` | Foto burimore |
| `assets/images/store_location.jpg` | Path i përdorur në UI (PNG content, emër `.jpg` sipas spec) |

---

## Teste

| Test | Verifikon |
|------|-----------|
| `shows store location image preview` | `Image` widget + badge; pa pin qendror |
| Testet ekzistuese maps/address | Pa regresion |

---

## Rezultatet

```
flutter analyze
flutter test
```

---

## Përmbledhje

Store Visit Card shfaq tani foto reale të lokacionit në vend të hartës ilustruese, me fallback automatik te ilustrimi i vjetër nëse fotoja dështon.
