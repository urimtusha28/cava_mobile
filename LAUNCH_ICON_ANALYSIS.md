# Launch Icon Analysis

**Data:** 16 korrik 2026  
**Qëllimi:** Verifikim vetëm (pa ndryshime në kod, assets, ose konfigurim)  
**Asseti i synuar:** `launch_icon_cava.png`

---

## Përmbledhje

Projekti **është tashmë i konfiguruar** që `flutter_launcher_icons` të përdorë `assets/images/launch_icon_cava.png` si burim për ikonën e launcher-it në Android dhe iOS. Ikonat e gjeneruara në platformë përputhen vizualisht dhe teknikisht me këtë burim (ngjyra `#7F001E` / `rgb(127,0,30)`, formë e rrumbullakosur me alpha, “C” si prerje transparente).

Një asset i vjetër alternativ (`assets/icons/launch_icon.png`) ekziston, por **nuk** është i lidhur me konfigurimin aktual të launcher icon.

---

## 1. A ekziston `launch_icon_cava.png`?

| Pyetje | Përgjigje |
|--------|-----------|
| Ekziston? | **Po** |
| Vendndodhja | `assets/images/launch_icon_cava.png` |
| Formati | PNG RGBA |
| Dimensionet | **77 × 76** px |
| Madhësia e skedarit | ~1.2 KB |
| Profili | sRGB (eksportuar nga Figma) |
| Në listën `flutter: assets:`? | Jo (nuk nevojitet për runtime; përdoret vetëm nga gjeneruesi i ikonave) |

### Karakteristikat e assetit

Analiza e pikselëve tregon:

- Fusha e dukshme është pothuajse tërësisht burgundy solid `rgb(127, 0, 30)`.
- Quartet e qosheve janë transparente (`alpha = 0`) — forma squircle/e rrumbullakosur është **e pjekur brenda assetit**.
- Forma “C” **nuk** është e mbushur me ngjyrë të zezë; është **prerje transparente (alpha cutout)**. Në sfond të zi duket si “C” e zezë; në home screen duket sfondi i Wallpaper-it përmes prerjes.

---

## 2. A referohet nga `flutter_launcher_icons`?

**Po.** Nuk ka skedar të veçantë `flutter_launcher_icons.yaml`. E gjithë konfigurimi është në `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/images/launch_icon_cava.png
```

Versioni i instaluar (sipas `pubspec.lock`): **0.14.4**.

### Çfarë mungon qëllimisht në konfigurim (mirë për “pa modifikime vizuale”)

Nuk janë vendosur opsione që do të ndryshonin dizajnin:

- `adaptive_icon_background` — **jo**
- `adaptive_icon_foreground` — **jo**
- `background_color` / `adaptive_icon_background` color — **jo**
- `padding` / `min_sdk_android` adaptive extras — **jo**
- `image_path_android` / `image_path_ios` të ndryshme — **jo** (i njëjti burim për të dyja)

Pra konfigurimi aktual është minimal: merr imazhin dhe gjeneron ikona legacy për Android/iOS.

### Historiku i shkurtër

Në commit-in `811e1e7` (“launch icon”, 2026-07-13):

- `image_path` u ndryshua nga `assets/icons/asd.png` → `assets/images/launch_icon_cava.png`
- U hoq `remove_alpha_ios: true`
- U përditësuan ikonat e gjeneruara në Android `mipmap-*` dhe iOS `AppIcon.appiconset`

---

## 3. Cila ikonë përdoret aktualisht?

### Burimi i konfiguruar (source of truth për gjenerim)

| Rol | Skedar | Status |
|-----|--------|--------|
| **Aktiv për launcher** | `assets/images/launch_icon_cava.png` | I referuar në `pubspec.yaml` |
| I vjetër / alternativ | `assets/icons/launch_icon.png` (1024×1024) | Ekziston, **nuk** referohet nga `flutter_launcher_icons` |
| Burim i mëparshëm | `assets/icons/asd.png` (114×114) | I mëparshëm; ende në listën e assets runtime, jo për launcher |

### Output i platformës (ikonat e instalueshme)

| Platformë | Si lidhet | Output aktual | Në sink me `launch_icon_cava.png`? |
|-----------|-----------|---------------|-------------------------------------|
| **Android** | `AndroidManifest.xml` → `@mipmap/ic_launcher` | `android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` | **Po** (e njëjta ngjyrë, alpha corners, C transparente) |
| **iOS** | `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` | `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` | **Po** (përfshirë `Icon-App-1024x1024@1x.png`) |
| **Web** | `web/manifest.json` + `web/icons/` | Ikonat default Flutter (mar. 2025 / qer. 2025) | **Jo** — nuk mbulohen nga `flutter_launcher_icons` |
| **macOS** | `AppIcon.appiconset` | Ikonat default Flutter | **Jo** — nuk mbulohen (`macos: true` mungon) |

**Nuk ka** `mipmap-anydpi-v26` / adaptive icon XML — Android përdor vetëm PNG legacy `ic_launcher`, pra nuk ka layer të veçantë background/foreground nga sistemi.

### Splash vs launcher

`flutter_native_splash` aktualisht është vetëm ngjyrë (`#6B1D2A`), pa `image`. Nuk përdor `launch_icon_cava.png`. Kjo është e ndarë nga launcher icon dhe nuk ndikon në këtë analizë.

### Skripta të personalizuara

Nuk u gjet asnjë skript custom (`.sh`, Makefile, task CI) që gjeneron launcher icons. Procesi i synuar është standard:

```bash
dart run flutter_launcher_icons
```

---

## 4. A është e sigurt zëvendësimi me `launch_icon_cava.png`?

### Statusi aktual

Zëvendësimi i burimit **në konfigurim është bërë tashmë**. Në praktikë, hapi i mbetur nuk është “lidhja” e assetit, por:

1. konfirmimi që asseti final i designer-it është ai që duhet (cilësi / dimensionet), dhe
2. ri-gjenerimi i pastër **vetëm** nëse asseti zëvendësohet me një version më të mirë.

### Ndikimi në funksionalitet

Ri-gjenerimi i ikonave të launcher-it **nuk prek** logjikën e aplikacionit, API-të, navigimin, Firebase, etj. Prek vetëm assets vizuale të ikonës së app-it në home screen / App Store listing (Android/iOS).

### Kufizimet e rëndësishme (pa ndryshime vizuale)

Kur të bëhet zëvendësimi/ri-gjenerimi eventual:

| Mos bëj | Arsyeja |
|---------|---------|
| Mos shto `adaptive_icon_background` / ngjyrë background | Do të shtonte një layer që nuk është në dizajn |
| Mos shto padding | “C” dhe bleed-i janë të qëllimshëm në asset |
| Mos rrumbullako / mos masko ekstra | Qoshet e rrumbullakosura janë tashmë në PNG |
| Mos shto hije / efekte / graphics ekstra | Nuk janë në burim |
| Mos mbush alpha me ngjyrë arbitrarily (p.sh. white) | “C” është transparente; mbushja e gabuar e shkatërron dizajnin |
| Mos ridizajno assetin | Designer ka dhënë versionin final |

Konfigurimi aktual (vetëm `image_path`) është i përshtatshëm për këto kërkesa, sepse nuk aplikon background, padding, apo adaptive layers.

### Rreziqe / vërejtje teknike (jo bllokuese për “safety”, por kritike për cilësinë)

1. **Rezolucioni i burimit është shumë i ulët (77×76).**  
   Gjenerimi i `1024×1024` për iOS është upscale i fortë → humbje cilësie / softimi. Rekomandohet që designer-i të japë të njëjtin dizajn në **të paktën 1024×1024** (idealisht exact square), pa ndryshuar kompozimin.

2. **Transparenca në ikonën iOS.**  
   Ikona aktuale `Icon-App-1024x1024@1x.png` ka qoshe transparente dhe “C” transparente. App Store historikisht kërkon ikona **pa alpha**. Më parë ekzistonte `remove_alpha_ios: true`, që u hoq. Riaktivizimi i tij do të plotësonte alpha me të bardhë (default i package-it) dhe **do ta ndryshonte** pamjen — në kundërshtim me “pa modifikime vizuale”, nëse nuk bilohet ngjyra e mbushjes me designer-in.

3. **Web / macOS** nuk përditësohen nga konfigurimi aktual. Nëse synohen edhe ato platforma, duhet vendim i veçantë (jashtë scope-it të Android/iOS launcher).

4. **`assets/icons/launch_icon.png`** është dizajn tjetër (1024×1024, “C” e bardhë e mbushur) dhe mund të ngatërrojë — nuk duhet përdorur si burim nëse finali është `launch_icon_cava.png`.

---

## 5. Çfarë do të duhej të ndryshonte (vetëm kur të kërkohet implementimi)

Nëse asseti final `launch_icon_cava.png` mbetet i njëjti skedar/path:

| Hapi | Nevoja |
|------|--------|
| Ndryshim `pubspec.yaml` `image_path` | **Jo** — tashmë korrekt |
| Shtim `flutter_launcher_icons.yaml` | **Jo** — jo e nevojshme |
| Zëvendësim i skedarit PNG (nëse vjen version 1024×1024) | **Po**, nëse designer dërgon version me rezolucion më të lartë, mbaj path-in e njëjtë |
| Ri-ekzekutim `dart run flutter_launcher_icons` | **Po**, pas zëvendësimit të PNG |
| Ndryshime në `AndroidManifest.xml` / Xcode AppIcon name | **Jo** — emrat `ic_launcher` / `AppIcon` janë të sakta |
| Opsione vizuale (background, padding, adaptive, shadows) | **Jo** — nuk duhet shtuar asnjë |

Nëse qëllimi është vetëm të konfirmohet status quo: **asgjë nuk duhet ndryshuar** përsa i përket lidhjes së burimit.

---

## 6. Konfirmim: pa modifikime vizuale

Për çdo hap të ardhshëm të implementimit:

- Mos shto ngjyrë background.
- Mos prito/crop ndryshe nga burimi.
- Mos rrumbullako ekstra.
- Mos shto padding.
- Mos shto shadows / glow / border.
- Mos gjenero grafika ekstra.
- Mos ridizajno.

Launcher icon duhet të gjenerohet **saktësisht** nga imazhi i dhënë, me konfigurimin minimal ekzistues (`android: true`, `ios: true`, `image_path` vetëm).

---

## 7. Rekomandimi për hapin e radhës

1. **Mos ndrysho konfigurimin tani** — `image_path` tashmë pika te `launch_icon_cava.png`, dhe ikonat Android/iOS janë tashmë të gjeneruara nga ai burim.
2. **Kërko nga designer-i një eksport 1024×1024** të së njëjtës kompozitë (burgundy + “C” transparente + qoshe siç janë), pa hije/padding ekstra — për të shmangur upscale nga 77×76.
3. Kur të merret versioni me rezolucion të mjaftueshëm: zëvendëso skedarin në `assets/images/launch_icon_cava.png` (mbaj emrin), pastaj ekzekuto `dart run flutter_launcher_icons` **pa** shtuar opsione vizuale.
4. Para submit-it në App Store, verifiko politikën e alpha për marketing icon; nëse App Store refuzon transparencën, diskuto me designer-in mbushjen e alpha (p.sh. me të zezë që të ruajë pamjen e “C”), **jo** me background arbitrar.

**Vendimi:** `launch_icon_cava.png` **është** ikona e konfiguruar dhe e përdorur aktualisht për Android/iOS launcher. Nuk nevojitet ndryshim konfigurimi për ta “aktivizuar”; hapi i ardhshëm i vlefshëm është përmirësimi i cilësisë së burimit (rezolucioni) dhe ri-gjenerimi i pastër pa modifikime vizuale.
