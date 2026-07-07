# Store Location & Maps — Report

## Qëllimi

Përditësimi i **Store Visit Card** në Home me adresën e re në Ferizaj dhe hapja e lokacionit në Google Maps kur përdoruesi klikon card-in.

---

## Skedarët e ndryshuar

| Skedar | Ndryshim |
|--------|----------|
| `lib/core/widgets/visit_store_banner.dart` | Adresë e re, clickable, dialog, `openStoreInMaps()` |
| `pubspec.yaml` | Shtuar `url_launcher: ^6.3.1` |
| `test/core/widgets/visit_store_banner_test.dart` | **I ri** — adresë, dialog, URL |

**Pa ndryshuar:** layout, ngjyra, spacing, font, map illustration, Home structure, Firebase/backend.

---

## Adresa e re

```
The Village - Shopping & Fun, 1 Ahmet Kaçiku, Ferizaj 70000
```

Zëvendëson: `Rruga e Dibrës 12, Tiranë`

Konstante: `VisitStoreBanner.storeAddress`

---

## Click behavior

1. Përdoruesi klikon të gjithë card-in (`GestureDetector`, `HitTestBehavior.opaque`).
2. Shfaqet **AlertDialog** premium:
   - **Title:** Open Maps?
   - **Message:** Dëshiron ta hapësh lokacionin në Maps?
   - **Cancel** — mbyll dialogun
   - **Open Maps** — burgundy accent, hap Maps

---

## Google Maps URL

```
https://www.google.com/maps/search/?api=1&query=The%20Village%20Shopping%20Fun%201%20Ahmet%20Kaciku%20Ferizaj%2070000
```

Konstante: `VisitStoreBanner.mapsUrl`

Hapet me:

```dart
await launchUrl(uri, mode: LaunchMode.externalApplication);
```

- **iOS:** Google Maps app (nëse instaluar) ose Safari/browser
- **Android:** Google Maps app ose browser

---

## Error handling

Nëse `launchUrl` kthen `false` ose hedh exception:

```
SnackBar: "Nuk mund të hapet Maps."
```

Stil: burgundy background, floating, rounded.

---

## Teste

| Test | Verifikon |
|------|-----------|
| `shows Ferizaj store address` | Teksti i ri, jo adresa e vjetër |
| `tap opens maps confirmation dialog` | Dialog me title/message/buttons |
| `cancel dismisses maps dialog` | Cancel mbyll dialogun |
| `mapsUrl points to Google Maps search` | URL format i saktë |

---

## Rezultatet

```
flutter analyze
flutter test
```

---

## Përmbledhje

Store Visit Card tregon adresën e re në Ferizaj dhe hap lokacionin në Google Maps pas konfirmimit nga përdoruesi, pa ndryshuar dizajnin ekzistues të card-it.
