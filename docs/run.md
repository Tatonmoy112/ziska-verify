Run these in PowerShell from `D:\Project\ziska-verify`.

**1. Start the emulator** (in its own terminal; leave it open):
```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_7 -gpu swiftshader_indirect -no-snapshot-load
```
`-gpu swiftshader_indirect` uses software graphics. Your PC's graphics driver crashed the emulator with the default setting, so keep this flag.

**2. In a second terminal, wait until the emulator has started:**
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb wait-for-device
while ((& $adb shell getprop sys.boot_completed).Trim() -ne "1") { Start-Sleep 3 }
"ready"
```

**3. Remove the old app** (this also deletes its saved login and phone ID):
```powershell
& $adb uninstall com.ziskapharma.trackandtrace.mock
```
If it says "Unknown package", the app wasn't installed, which is fine.

**4. Clean and rebuild:**
```powershell
D:\flutter\bin\flutter clean
D:\flutter\bin\flutter pub get
```

**5. Build, install and start the new app:**
```powershell
D:\flutter\bin\flutter run --release --flavor mock --dart-define-from-file=config/mock.json -d emulator-5554
```
Use `--release`: the debug build crashed the emulator twice on this PC. The first build takes about 3–7 minutes.

If you'd rather build and install without `flutter run`:
```powershell
D:\flutter\bin\flutter build apk --release --flavor mock --dart-define-from-file=config/mock.json
& $adb install -r build\app\outputs\flutter-apk\app-mock-release.apk
& $adb shell monkey -p com.ziskapharma.trackandtrace.mock -c android.intent.category.LAUNCHER 1
```

The mock server named in `config\mock.json` serves the current collection; how it was set up, and the test logins: `docs\postman-mock-setup.md`.

**Release APKs for real phones** (one per phone type; most phones take `arm64-v8a`):
```powershell
D:\flutter\bin\flutter build apk --release --flavor mock --dart-define-from-file=config/mock.json --split-per-abi
```
The APKs are in `build\app\outputs\flutter-apk\` (`app-arm64-v8a-mock-release.apk`, `app-armeabi-v7a-mock-release.apk`, `app-x86_64-mock-release.apk`).

## Release signing

Without a key the release build is signed with the debug key: it installs on any phone for testing, but a store refuses it. The upload key is made once the client has decided who owns it (`docs/release-backlog.md`):

1. Make the keystore, outside the project, and keep it and its passwords in the owner's password manager:
   ```powershell
   keytool -genkey -v -keystore D:\keys\ziska-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Write `android\key.properties` (git-ignored, never committed):
   ```properties
   storeFile=D:/keys/ziska-upload.jks
   storePassword=<the keystore password>
   keyAlias=upload
   keyPassword=<the key password>
   ```
3. Build as above. `android\app\build.gradle.kts` uses the key whenever `key.properties` names a `storeFile`, and the debug key otherwise. Check the signer with `apksigner verify --print-certs <apk>`: the debug key shows `CN=Android Debug`.

CI builds only the debug mock APK, so it needs no key.