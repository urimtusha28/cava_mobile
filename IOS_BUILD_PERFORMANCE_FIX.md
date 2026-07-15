# IOS_BUILD_PERFORMANCE_FIX

**Projekti:** `cava_ecommerce`  
**Data:** 16 korrik 2026  
**Qëllimi:** redukto kohën e `flutter run` (iOS Simulator, Apple Silicon) duke ndaluar kompilimin dual-arch të panevojshëm në Debug për CocoaPods.

---

## Shkaku i problemit

Në konfigurimin **Debug**, target-et native të CocoaPods (sidomos `gRPC-Core`, `BoringSSL-GRPC`, `FirebaseFirestoreInternal`, `abseil`) kompilohshin për **`arm64` dhe `x86_64`**, edhe kur:

- host është **Apple M3 (arm64)**;
- simulatori aktiv është **arm64**.

Kjo dyfishonte punën e kompiliimit C/C++ të stack-ut Firebase Firestore. Analiza e mëparshme (`FLUTTER_RUN_PERFORMANCE_REPORT.md`) matri një rebuild të plotë Debug **~29.5 min**, me `ONLY_ACTIVE_ARCH = NO` në shumicën e Pods.

---

## Skedari dhe rreshtat e ndryshuar

| Skedar | Ndryshimi |
|---|---|
| `ios/Podfile` | U shtua logjikë Debug-only brenda `post_install` (rreshtat **44–48**) |

**Asnjë** skedar Dart/UI/Firebase app config / GoRouter / DI / Clean Architecture **nuk u prek**.

### Para

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

### Pas

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      # Debug-only: compile the active arch (arm64 on Apple Silicon) to avoid
      # doubling Firebase/gRPC native compile time for unused x86_64 simulator.
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
end
```

### Çfarë u ruajt (me qëllim)

- `flutter_additional_ios_build_settings(target)`
- `IPHONEOS_DEPLOYMENT_TARGET = '15.0'`
- `use_frameworks!` (pa static linkage)
- Platforma `ios, '15.0'`
- i gjithë setup-i tjetër Flutter/CocoaPods

### Çfarë **nuk** u implementua

- `EXCLUDED_ARCHS[sdk=iphonesimulator*] = x86_64` — **nuk u vendos**, sepse `ONLY_ACTIVE_ARCH = YES` u verifikua si i mjaftueshëm në settings efektive.
- Ndryshimi i `use_frameworks!` në `:linkage => :static`
- `flutter clean`, fshirje DerivedData/Pods/Podfile.lock, përditësim dependencies/Firebase

---

## Konfigurimi para dhe pas

### Para (`xcodebuild -showBuildSettings`, target `gRPC-Core`, sdk `iphonesimulator`)

| Configuration | `ONLY_ACTIVE_ARCH` | `ARCHS` |
|---|---|---|
| Debug | **NO** | `arm64 x86_64` |
| Release | **NO** | `arm64 x86_64` |

Numërimi në `Pods.xcodeproj` përpara regenerimit: **`ONLY_ACTIVE_ARCH = YES` × 1**, **`NO` × 53**.

### Pas (`pod install` + verifikim)

| Target | Debug | Release | Profile |
|---|---|---|---|
| `gRPC-Core` | **YES** | **NO** | **NO** |
| `BoringSSL-GRPC` | **YES** | **NO** | — (Release NO) |
| `FirebaseFirestoreInternal` | **YES** | **NO** | — |
| `abseil` | **YES** | **NO** | — |

Numërimi në `Pods.xcodeproj` pas regenerimit:

- **Debug:** `ONLY_ACTIVE_ARCH = YES` × **54**
- **Release / Profile:** çelësi nuk është forcuar në YES (mungon në pbxproj); settings efektive mbeten **`ONLY_ACTIVE_ARCH = NO`**

`ARCHS` mbetet `arm64 x86_64` si listë e mundshme — kjo është e pritur. Me `ONLY_ACTIVE_ARCH=YES`, Xcode kompilon **vetëm arkitekturën aktive** (`arm64` në M3 + simulator arm64), jo të dyja.

---

## Pse ndryshimi është i sigurt

1. **Scope i kufizuar:** vetëm `config.name == 'Debug'`.
2. **Release / Profile / Archive** vazhdojnë me `ONLY_ACTIVE_ARCH = NO` (verifikuar me `xcodebuild`).
3. **Nuk ndryshon** kod Flutter, queries Firestore, Firebase plist, routing, DI, modele, repositories.
4. **Nuk përjashton** `x86_64` me `EXCLUDED_ARCHS` — më pak agresiv; lejon Rosetta/x86 sim nëse dikush e hap me arch jo-aktive (ndërsa Debug tipik arm64 përfiton).
5. **Nuk prek** `use_frameworks!` / versionet e pods — vetëm flag build setting.
6. Flag është standard Xcode / CocoaPods; nuk ndryshon ABI të Firebase në runtime kur build-i është për arch-in e duhur.

### Çfarë nuk është prekur

- UI / widget-e
- Logjika e biznesit
- Firestore / Auth / Storage / Cloud Functions (kod + config)
- GoRouter
- get_it / Clean Architecture
- Release & Archive architecture support
- Physical iPhone builds (Release/Profile path; Debug device arm64 është arch aktive)
- Firebase versions / `Podfile.lock` dependency set (vetëm regenerim projekti Pods)

---

## Komandat e ekzekutuara

```bash
# 1. Baseline (para ndryshimit)
xcodebuild -project ios/Pods/Pods.xcodeproj -target gRPC-Core \
  -configuration Debug -sdk iphonesimulator -showBuildSettings

# 2. Kontroll sintakse
ruby -c ios/Podfile   # => Syntax OK

# 3. Riaplikim minimal CocoaPods (pa clean)
cd ios && pod install

# 4. Verifikim pas
xcodebuild -project Pods/Pods.xcodeproj -target gRPC-Core \
  -configuration Debug|Release|Profile -sdk iphonesimulator -showBuildSettings
# + po ashtu për BoringSSL-GRPC, FirebaseFirestoreInternal, abseil
```

**Nuk u ekzekutuan:** `flutter clean`, fshirje DerivedData/Pods/cache, `pod update`, ndryshim versionesh.

`pod install` përfundoi me sukses (~95 s): *10 dependencies / 32 pods installed*. Warning-e ekzistuese të CocoaPods/Flutter Profile xcconfig dhe deprecation FirebaseCore CocoaPods u shfaqën — **jo të shkaktuara nga ky ndryshim**.

---

## Rezultatet e verifikimit

| Kontroll | Rezultat |
|---|---|
| Sintaksa `Podfile` (`ruby -c`) | **OK** |
| `pod install` | **exit 0** |
| Debug `ONLY_ACTIVE_ARCH` (gRPC / BoringSSL / FirestoreInternal / abseil) | **YES** |
| Release `ONLY_ACTIVE_ARCH` (po ato target-e) | **NO** |
| Profile `ONLY_ACTIVE_ARCH` (`gRPC-Core`) | **NO** |
| `EXCLUDED_ARCHS` i ri | **nuk u shtua** (nuk ishte i nevojshëm) |
| `use_frameworks!` | **i pandryshuar** |

---

## Rreziqet e mbetura

| Rrezik | Nivel | Shënim |
|---|---|---|
| Incremental build i parë pas ndryshimit mund të rikompilojë disa targets Debug | Mesatar / i pritur | Setting-u ndryshoi; **jo** clean global. Mund të ketë rrikompilim partial, jo detyrimisht 30 min full clean. |
| Simulator x86_64 / Rosetta në Debug | I ulët | Me `ONLY_ACTIVE_ARCH=YES`, Xcode ndjek arch aktive. Nëse dikush forcon destination x86_64, kompilohet ajo arch (jo të dyja). |
| Disk ~97% full | I lartë (jashtë këtij fix) | Vazhdon të amplifikojë I/O; nuk u adresua këtu me qëllim. |
| Firestore/gRPC ende të rënda në clean total | I njohur | Fix ul dual-arch; nuk eliminon koston e gRPC në rebuild të plotë. |
| `use_frameworks!` dinamik | I pandryshuar | Optimizim i mëtejshëm i shtyrë me qëllim. |

---

## Mënyra e rikthimit

Hiq bllokun Debug-only nga `ios/Podfile` `post_install` (rreshtat e `if config.name == 'Debug'`) dhe riapliko:

```bash
cd ios && pod install
```

Ose restore me git:

```bash
git checkout -- ios/Podfile
cd ios && pod install
```

---

## Rekomandim për matjen e build-it të ardhshëm

**Mos bëj `flutter clean` / fshirje DerivedData** për matjen e përfitimit tipik të ditës — kjo do të rikthente skenarin e rebuild-it të gjatë.

Matje e rekomanduar:

1. Sigurohu që simulatori arm64 është booted (`iPhone 16 Pro` ose i ngjashëm).
2. Ekzekuto:
   ```bash
   flutter run -d "iPhone 16 Pro" -v
   ```
   ose build Xcode me timing:
   ```bash
   xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
     -configuration Debug -sdk iphonesimulator \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
     -showBuildTimingSummary
   ```
3. Krahaso me baseline: clean ~**29.5 min**, incremental ~**4.5 min**.
4. **Pritje reale pas këtij fix (pa clean):**
   - incremental / dirty: më afër **1–3 min** (nëse cache e vlefshme);
   - nëse Xcode rikompilon pods Debug për arch change: një herë mesatare, pastaj më e shpejtë;
   - clean i plotë (nëse dikush e bën): ende minuta (gRPC), por duhet të jetë **qartë më shkurt** se ~29.5 min (~faktor ~1.5–2× më pak native work).

Nëse matjet tregojnë se `ONLY_ACTIVE_ARCH=YES` **nuk** mjafton (p.sh. ende shihen `.o` për `x86_64` në DerivedData gjatë Debug arm64), atëherë vlerëso veçmas `EXCLUDED_ARCHS[sdk=iphonesimulator*]=x86_64` — me risk dokumentuar, jo si pjesë e këtij fix-i.

---

## Përmbledhje

Ndryshim minimal dhe i verifikuar: **Debug-only `ONLY_ACTIVE_ARCH=YES`** në `ios/Podfile` `post_install`, i riaplikuar me `pod install`, i konfirmuar me `xcodebuild -showBuildSettings` për target-et e rënda Firebase/gRPC. Release/Profile mbeten multi-arch (`ONLY_ACTIVE_ARCH=NO`). Asnjë ndryshim në app logic, Firebase versions, apo Clean Architecture.
