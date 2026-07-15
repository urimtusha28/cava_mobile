# FLUTTER_RUN_PERFORMANCE_REPORT

**Projekti:** `cava_ecommerce`  
**Data e analizës:** 15 korrik 2026  
**Platforma e matur:** iOS Simulator (`iPhone 16 Pro`, runtime iOS 18.2)  
**Metoda:** analizë jo-destruktive (pa `flutter clean`, pa fshirje cache, pa ndryshime kodi/konfigurimi)

---

## Executive Summary

| | |
|---|---|
| **Problemi kryesor** | `flutter run` (debug → iOS Simulator) mbetet te “Running Xcode build…” për ~30 minuta në rebuild të plotë. |
| **Shkaku më i mundshëm** | Kompilimi i plotë native i stack-ut **Firebase Firestore → gRPC-Core / BoringSSL-GRPC / abseil**, i **dyfishuar për `arm64` + `x86_64`**, sepse në Pods `ONLY_ACTIVE_ARCH = NO` (53 raste vs 1 `YES`). Amplifikues: disku **~97% i plotë** (~7.6–8.1 GB të lirë). |
| **Niveli i ndikimit** | **Kritik** për produktivitetin e zhvillimit. Hot reload nuk është shkaku; bllokimi është faza Xcode/native. |

**Prova kryesore e kohës (Xcode `LogStoreManifest.plist`):**

| Ngjarja | Fillimi | Mbarimi | Kohëzgjatja |
|---|---|---|---|
| Clean workspace Runner (Debug) | 17:41:42 | 17:42:05 | **~23 s** |
| Build workspace Runner (Debug) *pas clean* | 17:42:05 | 18:11:35 | **1770.2 s ≈ 29.5 min** |
| Build Debug më herët (jo pas clean të plotë) | 16:53:58 | 16:58:29 | **271.6 s ≈ 4.5 min** |

Kjo përputhet me ankesën “mbi 30 minuta”.

---

## Root Cause

### Pse build merr ~30 minuta

1. **Trigger:** menjëherë para build-it të gjatë u ekzekutua **Clean** i workspace Runner (log `FB95AE98…`). Clean fshin artifact-et → kompilohet nga e para i gjithë grafik i Pods.
2. **Komponenti përgjegjës:** jo Dart/Flutter app code, por **Xcode native Pods**, dominuar nga Firestore:
   - `gRPC-Core` **1904** file `.o` (**2.0 GB** intermediates) — **952 arm64 + 952 x86_64**
   - `BoringSSL-GRPC` **558** `.o` (279 + 279)
   - `FirebaseFirestoreInternal` **393** `.o`
   - `abseil` **288** `.o`
   - plus `gRPC-C++`, `FirebaseAuth`, etj.
3. **Dyfishimi i punës:** në logun e build-it `1A680CE8…` u numëruan **`normal arm64` ≈ 5568** dhe **`normal x86_64` ≈ 5740** referenca; në DerivedData, Pods të rëndë kanë `Objects-normal/{arm64,x86_64}`. Në `Pods.xcodeproj`: **`ONLY_ACTIVE_ARCH = NO` × 53**, **`YES` × 1**. Runner Debug ka `ONLY_ACTIVE_ARCH = YES`, por **nuk trashëgohet tek target-et e Pods**. Në Mac **Apple M3 (arm64)**, kompiliimi i `x86_64` për simulator është punë e panevojshme për device-in aktiv dhe gati e dyfishon kohën e C/C++.
4. **Amplifikues disku/RAM:** Data volume **96.7% used**, ~**8.1 GB** të palokuar në APFS. DerivedData e projektit **~6.3 GB** (`Pods.build` Debug **2.6 GB**). Memory compressor ~**4+ GB**. Build i rëndë + disk i ngushtë → I/O dhe kompresim memorie, që shpjegojnë pse koha është ekstremisht e lartë edhe për M3.

### Sa kohë humbet sipas fazave (rebuild i plotë ~29.5 min)

Vlerësim i bazuar në numrin e `.o` × kosto relative e C/C++ (heuristikë e kalibruar ndaj 29.5 min të matura):

| Faza / komponenti | Vlerësim | Bazë prove |
|---|---|---|
| **Clean** | ~0.4 min | LogStoreManifest |
| **Kompilim `gRPC-Core` (dy arkitektura)** | **~15–19 min** | 1904 `.o`, 2.0 GB, mentions dominante në activity log |
| **`BoringSSL-GRPC`** | **~3–5 min** | 558 `.o` |
| **`FirebaseFirestoreInternal` + `abseil` + `gRPC-C++`** | **~4–6 min** | 393+288+104 `.o` |
| **Pods të tjerë Firebase/plugins + link/embed** | **~2–4 min** | Auth/Storage/Functions + `[CP] Embed Pods Frameworks` |
| **Flutter `xcode_backend.sh` (Run Script / Thin Binary)** | sekonda–pak minuta | skriptet standarde Flutter; jo shkaku i 30 min |
| **Dart compile / asset bundle** | sekonda | assets totale **3.6 MB** |
| **Nisje simulator / install** | sekonda–1 min | simulator tashmë booted |

**Përfundim:** ~**85–95%** e kohës së rebuild-it të plotë shkon te **kompilimi native i Firestore/gRPC (përfshi dual-arch)**. Dart, GoRouter, get_it, assetet nuk shpjegojnë 30 minuta.

---

## Environment (verifikuar)

### Flutter / Dart

| Item | Vlera |
|---|---|
| Flutter | **3.41.9** (stable), revision `00b0c91f06` |
| Dart | **3.11.5** |
| Channel | stable |
| Host | macOS 15.6.1, **darwin-arm64**, Apple **M3**, **8** cores, **16 GB** RAM |
| `flutter doctor -v` | **No issues found** |
| CocoaPods (doctor) | **1.16.2** |

Nuk u gjet version mismatch kritike Flutter↔Dart (`pubspec` `sdk: ^3.11.5` përputhet me Dart 3.11.5).

### Xcode / Simulator

| Item | Vlera |
|---|---|
| Xcode | **26.0.1** (Build 17A400) |
| iOS Simulator SDK | **26.0** |
| Device i përdorur | iPhone 16 Pro (`482638A0-…`) **Booted**, runtime **iOS 18.2** |
| Runtime alternativ | iOS 26.0.1 i instaluar por jo ai i device-it aktiv |

Shënim: Xcode 26 + simulator iOS 18.2 është kombinim i pranueshëm, por toolchain i ri + dependency C++ të rënda shton ngarkesë; **nuk është shkaku kryesor** krahasuar me dual-arch + gRPC.

### Disk / Cache

| Location | Madhësia / gjendja |
|---|---|
| `/System/Volumes/Data` | **~97%**, ~**7.6 GB** free (kritike) |
| DerivedData total | **7.9 GB** |
| `Runner-hikkfocp…` | **6.3 GB** (Build **5.0 GB**, Index **1.2 GB**) |
| `Pods.build/Debug-iphonesimulator` | **2.6 GB** |
| Flutter bin/cache | **3.2 GB** |
| `~/.pub-cache` | **901 MB** |
| CoreSimulator Devices | **5.9 GB** |
| `build/` i projektit | **556 MB** |

Nuk u konstatua korrupsion i qartë i Flutter/pub cache; `flutter doctor` OK. Cache e vjetër `cloud_firestore-5.6.12` / `firebase_core-3.15.2` ekziston në pub-cache, por projekti resolve **6.6.0 / 4.11.0** — mbeturina, jo shkak kryesor.

---

## Findings

### F1 — Rebuild i plotë i Pods Firestore/gRPC (~29.5 min) — **P0**

- **Përshkrim:** Pas clean, Xcode kompilon ~**51** native targets; graph “53 targets”. Dominon `gRPC-Core`.
- **Prova:** LogStoreManifest 29.5 min; 1904 `.o` në `gRPC-Core.build`; source files: gRPC-Core **~950**, BoringSSL **~277**, abseil **~142**, FirestoreInternal **~256**.
- **Ndikim:** shpjegon pothuajse tërë kohën “Running Xcode build…”.
- **Prioritet:** **P0**

### F2 — Dual architecture (`arm64` + `x86_64`) te Pods — **P0**

- **Përshkrim:** `ONLY_ACTIVE_ARCH = NO` në shumicën e konfigurimeve të Pods → kompilohet edhe `x86_64` edhe kur simulatori aktiv është arm64 (M3).
- **Prova:** `Objects-normal/arm64` dhe `x86_64` me numra të barabartë për gRPC/BoringSSL/abseil; counts `normal arm64`/`x86_64` në activity log; 53× `NO` vs 1× `YES` në `Pods.xcodeproj`.
- **Ndikim:** ~**~1.8–2×** kohë kompilationi për Pods C/C++; potencialisht **~10–15 min** të tepruara në clean build.
- **Prioritet:** **P0**

### F3 — Disk nganjëse i plotë (~97%) — **P0** (amplifikues)

- **Përshkrim:** Vetëm ~8 GB të lirë në disk 245 GB; build shkruan GB të intermediates.
- **Prova:** `df` / `diskutil apfs list` (96.7% in use); DerivedData 6.3 GB + Pods intermediates 2.6 GB.
- **Ndikim:** ngadalëson I/O, rrit memory pressure/swap; mund të bëjë rebuild-e “të ngjitura” mbi 30 min.
- **Prioritet:** **P0**

### F4 — `cloud_firestore` + transitive gRPC si kosto e pashmangshme e feature-it — **P1**

- **Përshkrim:** `cloud_firestore 6.6.0` → Firebase iOS **12.15.0** → `gRPC-Core 1.69.0`, `BoringSSL-GRPC 0.0.37`. Auth/Storage/Functions janë shumë më të lehta.
- **Prova:** `Podfile.lock` DEPENDENCIES + madhësitë në `ios/Pods/` (gRPC-Core 29 MB source, BoringSSL 19 MB, gRPC-C++ 18 MB).
- **Ndikim:** edhe me `ONLY_ACTIVE_ARCH=YES`, clean build i Firestore mbetet i rëndë (zakonisht minuta, jo sekonda).
- **Prioritet:** **P1**

### F5 — `use_frameworks!` (dinamik) në Podfile — **P2**

- **Përshkrim:** `use_frameworks!` pa `:linkage => :static` rrit punën e embed/link për shumë framework-e Firebase.
- **Prova:** `ios/Podfile` rreshti `use_frameworks!`; build phase `[CP] Embed Pods Frameworks`.
- **Ndikim:** minuta në fund të build-it; jo shkaku kryesor krahasuar me kompiliimin e gRPC.
- **Prioritet:** **P2**

### F6 — Flutter script phases me `alwaysOutOfDate = 1` — **P3**

| Script | Çfarë bën | Ndikimi | Duhet gjithmonë? |
|---|---|---|---|
| `[CP] Check Pods Manifest.lock` | Krahason `Podfile.lock` vs `Manifest.lock` | neglizhueshme | Po (guard) |
| `[CP] Embed Pods Frameworks` | Embed framework-et e Pods | i moderuar me shumë pods | Po për `use_frameworks` |
| `Run Script` (`xcode_backend.sh build`) | Build Flutter/Dart side | sekonda–pak min | Po për Flutter; `alwaysOutOfDate=1` është default Flutter |
| `Thin Binary` (`embed_and_thin`) | Embed/thin Flutter engine | sekonda | Po; `alwaysOutOfDate=1` default |

- **Prova:** `project.pbxproj` Shell Script phases.
- **Ndikim:** ekzekutohen çdo build, por **nuk** shpjegojnë 30 min.
- **Prioritet:** **P3**

### F7 — Debug: `GCC_OPTIMIZATION_LEVEL = 0` — **P3**

- **Përshkrim:** kompiliim pa optimizim → objekte më të mëdha/më të ngadalta për C++.
- **Prova:** `project.pbxproj` Debug configuration.
- **Ndikim:** i pritur për debug; kontribuon pak te koha e gRPC.
- **Prioritet:** **P3** (mos e “rregullo” verbërisht — prish debuggability)

### F8 — Assets — **Jo problem**

- **Përshkrim:** assets **3.6 MB**; më i madhi `store_location.jpg` / `cava2.png` ~1.5 MB.
- **Ndikim:** neglizhueshëm për kohën e `flutter run`.
- **Prioritet:** — 

### F9 — Package / konflikte Dart — **Jo shkak i 30 min**

- Direct deps: Firebase×5, `go_router`, `get_it`, UI helpers. **Nuk ka Riverpod.**
- Nuk u gjet conflict resolution që të detyrojë dyfishim absurd të native pods.
- `l10n.yaml`: `synthetic-package: false` — warning deprecation, pa ndikim të matur në build time.
- `firebase_messaging` / `firebase_analytics` / `firebase_app_check`: **nuk janë** në projekt (nuk kontribuojnë).

### F10 — Incremental vs first/clean — **P1 (sjellje)**

| Lloji | Kohë e matur / e pritshme | Shënim |
|---|---|---|
| Clean / first native rebuild | **~29.5 min** (matur) | F1+F2+F3 |
| Incremental Xcode (pods të ndërtuar) | **~4.5 min** (matur) | ende e lartë; disk + scripts |
| Hot Reload | sekonda (kur app është up) | nuk kalon rinisim të plotë pods |
| Hot Restart | sekonda–dhjetëra s | pa rebuild të plotë gRPC nëse binaries ekzistojnë |

**Përfundim:** problemi ekstrem është **rebuild i parë / pas clean / pas invalidimit të DerivedData**, jo çdo keystroke.

### F11 — Simulator — **P2 (sekondar)**

- Simulator booted OK; cache Devices 5.9 GB.
- Runtime 18.2 me Xcode 26: i pranueshëm; mund të kontribuojë lehtë, jo 30 min.
- Nuk u gjet proof se simulator “hang” është shkaku kryesor; bottleneck është `xcodebuild`/compile.

### F12 — CPU/RAM — **P2 (amplifikues)**

- 16 GB RAM, compressor i lartë gjatë sesioneve build.
- Nuk duket se CPU është “i ngadaltë”; M3 është i mjaftueshëm. Problemi është **sasia e punës së kompilit** + **disk**.

### F13 — Signing — **Jo problem i identifikuar**

- `DEVELOPMENT_TEAM = 8Z5QL7VLPR`, Automatic signing, bundle `com.binisoft.cavaEcommerce`.
- Nuk ka prova që signing të bllokojë 30 min në simulator.

---

## Recommendations

> Vetëm propozime. **Asgjë nuk u implementua** në këtë fazë.

### R1 — Liro diskun (≥20–40 GB free) — **menjëherë, jashtë kodit**

- Fshi manualisht mbeturina të mëdha (`Application Support`, Android SDK të panevojshëm, simulatorë të vjetër, DerivedData të projekteve të tjera) **duke zgjedhur me kujdes**.
- Mos fshi DerivedData të këtij projekti derisa të kesh hapësirë: rebuild i plotë do të rikthejë skenarin 30 min.

### R2 — Siguro `ONLY_ACTIVE_ARCH=YES` për Pods në Debug (simulator)

- Në `post_install` të Podfile (propozim tipik):
  - për konfigurimin Debug: `ONLY_ACTIVE_ARCH = YES`
  - opsionale: `EXCLUDED_ARCHS[sdk=iphonesimulator*] = x86_64` në Apple Silicon
- **Efekt i pritur:** gati gjysma e punës C/C++ e tepruar some.

### R3 — Shmang `flutter clean` / clean Xcode pa nevojë

- Clean detyron F1. Përdor clean vetëm kur ke error të vërtetë të cache.

### R4 — Konsidero `use_frameworks! :linkage => :static`

- Shpesh rekomanduar për Firebase + Flutter; mund të ulë kohën e embed dhe të stabilizojë linking.
- Testo mirë në simulator + device.

### R5 — Strategji Firestore për dev speed (nëse pranohet trade-off)

- Opsione (me risk funksional):
  - profil/dev pa Firestore native (mock/`fake_cloud_firestore` në disa targets) — kompleks
  - mos invalidoni pods në çdo experiment
  - CI: cache DerivedData/Pods artifacts
- **Mos hiq Firestore** pa vendim produkti; është dependency e qëllimshme.

### R6 — Build incremental: mbaj DerivedData të shëndetshëm pasi disk u lirua

- Pas R1+R2, mat përsëri me:
  - `flutter run -v` (timing fazash)
  - ose `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination '...' -showBuildTimingSummary`

### R7 — Mos prek scripts Flutter `alwaysOutOfDate` pa arsye

- Janë default të Flutter toolchains; “optimizimi” këtu rrezikon build të thyer.

### R8 — Opsionale: simulator me runtime që përputhet me Xcode 26

- Provo iOS 26 runtime për të eliminuar friction toolchain; mat para/pas.

---

## Risk Assessment

| Zgjidhja | Rreziku | Ndikimi në build | Prek UI? | Logjikë? | Firebase? | GoRouter? | Riverpod? | Clean Architecture? |
|---|---|---|---|---|---|---|---|---|
| R1 Liro diskun | I ulët (nëse nuk fshihet gabimisht) | I lartë (stabilitet + shpejtësi I/O) | Jo | Jo | Jo | Jo | N/A (nuk përdoret) | Jo |
| R2 `ONLY_ACTIVE_ARCH` për Pods Debug | I ulët–mesatar (edge case Rosetta/x86 sim) | I lartë (~1.5–2× më pak native compile) | Jo | Jo | Vetëm build native | Jo | N/A | Jo |
| R3 Shmang clean | I ulët | I lartë (shmang 30 min) | Jo | Jo | Jo | Jo | N/A | Jo |
| R4 `linkage => :static` | Mesatar (pod install / link errors) | Mesatar | Jo | Jo | Po (linking) | Jo | N/A | Jo |
| R5 Mock / heqje Firestore | I lartë funksional | I lartë | Mund të prekë features data | Po | **Po** | Jo | N/A | Mund të prekë data layer |
| R7 Ndryshim Flutter scripts | I lartë | I ulët | Jo | Jo | Jo | Jo | N/A | Jo |
| R8 Ndryshim simulator runtime | I ulët | I ulët–mesatar | Jo | Jo | Jo | Jo | N/A | Jo |

---

## Expected Improvement

| Skenari | Kohë |
|---|---|
| **Aktual — clean Debug (matur)** | **~29.5 min** |
| **Aktual — incremental (matur)** | **~4.5 min** |
| **Pas R1 (disk) + R3 (pa clean të panevojshëm)** | Incremental më i qëndrueshëm; clean ende i rëndë por më pak “i ngjirë” |
| **Pas R1 + R2 (single-arch Pods Debug)** | Clean i vlerësuar **~12–18 min** (ende Firestore/gRPC) |
| **Pas R1 + R2 + R4 + disiplinë dirty-build** | Incremental tipik **~1–3 min**; clean **~10–15 min** (rend i madhësisë së pritshme për Firestore në iOS) |
| **Koha e kursyer në clean** | **~10–18 min** për build (nga dual-arch + disk), plus shmangie e përsëritur e clean-eve |

> Shënim: nuk mund të pretendohet “flutter run në 30 sekonda” sa kohë `cloud_firestore` kompilon gRPC nga e para. Objektivi realist: **eliminimi i skenarit 30+ min** dhe **incremental i qëndrueshëm**.

---

## Evidence Appendix

### A. Kohëzgjatjet nga `LogStoreManifest.plist`

```
Build 1A680CE8… : 805830125.652 → 805831895.865 = 1770.2 s (29.5 min)
Build 395630C6… : 805827238.158 → 805827509.753 = 271.6 s (4.5 min)
Clean FB95AE98… : 22.8 s, menjëherë para build-it 29.5 min
```

### B. Object files (DerivedData `Pods.build/Debug-iphonesimulator`)

```
gRPC-Core.build                 1904 .o   (952 arm64 + 952 x86_64)   2.0G
BoringSSL-GRPC.build             558 .o   (279 + 279)
FirebaseFirestoreInternal.build    393 .o
abseil.build                     288 .o
FirebaseAuth.build               286 .o
gRPC-C++.build                   104 .o
```

### C. `pubspec.yaml` Firebase (direct)

- `firebase_core: ^4.11.0` → 4.11.0  
- `cloud_firestore: ^6.6.0` → 6.6.0  
- `firebase_auth: ^6.5.4` → 6.5.4  
- `firebase_storage: ^13.4.3` → 13.4.3  
- `cloud_functions: ^6.3.3` → 6.3.3  

### D. Pods Firebase iOS

- Firebase* **12.15.0**, `gRPC-Core` **1.69.0**, CocoaPods **1.16.2**

### E. Kufizimet e kësaj faze

- Nuk u ndryshua kod, Podfile, dependencies, cache, apo konfigurime.
- Nuk u ekzekutua `flutter clean` / fshirje DerivedData.
- Nuk u nis një rebuild i ri 30-minutësh; u analizuan loget e fundit të Xcode dhe artefaktet ekzistuese.

---

## Verdict

**Shkaku real:** rebuild i plotë Xcode i **Firebase Firestore native (gRPC/BoringSSL/abseil)**, i **kompiluar për dy arkitektura**, i amplifikuar nga **diskun gati të plotë** — zakonisht i nisur pas **Clean**.  

**Nuk është:** Dart app i “keq”, assets të mëdha, GoRouter, get_it, Riverpod (nuk ekziston), apo skriptet standarde Flutter si shkak primar i 30 minutave.
