# iOS Launch Icon Fix — App Store / TestFlight Compatible

**Data:** 16 korrik 2026  
**Scope:** Vetëm launcher icon (+ splash branding i kërkuar)  
**Burimi:** `assets/images/launch_icon_cava.png` (path/emër të pandryshuar)

---

## Problemi

Ikona e gjeneruar për iOS (`AppIcon.appiconset`) përmbante **alpha channel**:

- Qoshet e rrumbullakosura ishin transparente.
- Forma “C” ishte **prerje transparente** (jo e mbushur me ngjyrë), prandaj në sfond të zi dukej e zezë.
- Apple **nuk lejon** ikona me alpha në App Store / TestFlight (marketing icon 1024×1024 dhe AppIcon set).
- Opsioni default `remove_alpha_ios` i `flutter_launcher_icons` mbush alpha me **të bardhë** — kjo do ta shkatërronte dizajnin.

Burimi origjinal ishte 77×76 RGBA; upscale i verbër për 1024 pa sheshim alpha do të dështonte validimin e Apple.

---

## Çfarë u ndryshua

| Skedar | Ndryshimi |
|--------|-----------|
| `assets/images/launch_icon_cava.png` | I njëjti path; përmbajtja u zëvendësua me version **RGB 1024×1024 pa alpha**, me pamje të ruajtur |
| `pubspec.yaml` (`flutter_launcher_icons`) | U shtua `remove_alpha_ios: true` + `background_color_ios: "#000000"` si **safety net** (jo e bardhë) |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` | Ri-gjeneruar nga burimi i ri |
| `android/.../mipmap-*/ic_launcher.png` | Ri-gjeneruar nga i njëjti burim (konsistencë) |
| `lib/features/splash/.../splash_screen.dart` | Logo `assets/icons/logo.svg` + teksti **Cava Premium** |

**Nuk u prekën:** Firebase, routing, UI tjetër, `assets/icons/launch_icon.png`.

---

## Si u eliminua alpha channel

1. U lexua burimi origjinal RGBA nga git (`launch_icon_cava.png`).
2. Pikselët e errët (burgundy Opaque `rgb(127,0,30)`) u ruajtën.
3. Transparenca e **kornizës së jashtme** (qoshet) u mbush me **burgundy** `#7F001E` — e njëjta ngjyrë e dizajnit, që Apple mask ta trajtojë si full-bleed square.
4. Transparenca e brendshme e **“C”** u mbush me **të zezë** `#000000` — e njëjta pamje që jepte alpha mbi sfond të errët.
5. Imazhi u eksportua si **PNG RGB** 1024×1024 (pa kanal alpha).
6. U ekzekutua `dart run flutter_launcher_icons`.

`background_color_ios: "#000000"` **nuk** përdoret për ridizajnim: burimi tashmë është RGB. Shërben vetëm nëse ndonjë alpha i mbetur rrjedh — kurrë `#ffffff`.

---

## Si u ruajt dizajni origjinal

- I njëjti asset path: `assets/images/launch_icon_cava.png`.
- Pa padding, shadow, border, gradient, crop të kompozimit, apo ridizajnim.
- “C” mbetet e zezë; fusha mbetet burgundy e ngurtë.
- Qoshet e jashtme janë burgundy (jo të bardha), që me maskën e iOS të duken si ikona e plotë e designer-it, jo si kornizë arbitrare.

---

## Verifikimi

Të **21** skedarët PNG në `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:

- Mode: **RGB**
- Alpha channel: **asnjë**
- Shembull `Icon-App-1024x1024@1x.png`: qoshe burgundy, “C” e zezë, qendër burgundy

Komanda e përdorur:

```bash
dart run flutter_launcher_icons
```

---

## Splash screen

Në `SplashScreen` u shtua:

- `SvgPicture.asset('assets/icons/logo.svg')`
- Teksti `Cava Premium` poshtë logos (ngjyrë `#F1EAE2`, font `DMSans`)

Native splash (`flutter_native_splash`) mbetet me ngjyrën burgundy `#6B1D2A` — e njëjta paletë; branding-u me logo+tekst shfaqet në splash-in Flutter (pas `FlutterNativeSplash.remove()`).

---

## Konfirmim TestFlight / App Store

| Kërkesë Apple | Status |
|---------------|--------|
| Pa alpha channel në AppIcon | ✅ |
| Marketing icon 1024×1024 opaque | ✅ |
| Pa mbushje me të bardhë / ngjyrë arbitrare | ✅ (burgundy + black nga dizajni) |
| Burimi `launch_icon_cava.png` | ✅ |

**Ikona është e gatshme për build/archive drejt TestFlight dhe App Store Connect** përsa i përket alpha channel. Pas archive, verifiko lokalisht në Organizer / Transporter që nuk shfaqet warning për “alpha channel in app icon”.
