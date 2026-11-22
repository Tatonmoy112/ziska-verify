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

## The test server

The staging build talks to the backend's test server (`https://testapp.protecb.com`, client `ziska-test`, in `config\staging.json`). It installs next to the mock app as "Track & Trace Staging". The test login comes from the project owner; never put it in a file.

**Build and install:**
```powershell
D:\flutter\bin\flutter build apk --release --flavor staging --dart-define-from-file=config/staging.json --split-per-abi
& $adb install -r build\app\outputs\flutter-apk\app-x86_64-staging-release.apk
& $adb shell monkey -p com.ziskapharma.trackandtrace.staging -c android.intent.category.LAUNCHER 1
```
The first login on a phone asks for a 6-digit code emailed to the login's inbox (valid 5 minutes). Check the build's exit status, not just its last line: a build that failed leaves the old APK in place.

**The checker** asks the server what the app asks, through the app's own services and parsers, and saves every answer as a JSON file:
```powershell
$env:STAGING_EMAIL = "<the test login>"; $env:STAGING_PASSWORD = "<its password>"
D:\flutter\bin\dart run tool/staging_check/staging_check.dart <step> --out <folder> --state <folder>\state.json
```

| Step | Asks |
|---|---|
| `connect` | the public roles; a route without a login |
| `login`, then `verify <code>` | a login on a new phone, then its emailed code |
| `session` | renewal, logout, a used refresh pass |
| `profile` | `me` and a route per permission |
| `lookup`, `history`, `stack`, `scan`, `report` | one check; History; a stack of serials; a scanner session; a report with photos |
| `lengths` | how the server counts characters |
| `signup-probe`, `signup-code`, `signup <code>` | sign-up checks with an `example.com` address; a real sign-up (`STAGING_SIGNUP_EMAIL`) |
| `password-probe` | what the server refuses without changing the password |

- **Where to keep things:** the state file (the phone ID, and the passes while logged in) and the answers belong outside the repo.
- **Writes:** `lookup`, `stack`, `scan` and `report` record checks and reports on the server; `signup` files a sign-up request.
- **Fixtures:** answers kept as fixtures go to `test/fixtures/staging/` with the passes, emails, names and request IDs removed.
- **Codes after a reset:** a password reset forgets every trusted phone, the checker's too. Its next login asks for a code (`login`, then `verify <code>`).
- **Limits:** a sign-up allows 10 requests an hour from one network address; an address gets at most 5 emailed codes in 15 minutes.

**The emulator on this PC:**
- **Start it without a window:** add `-no-window -memory 3072` to the start command; the window crashes on this PC.
- **Drive it with adb:** `input tap`, `input text` (a space is `%s`), and `screencap` to see the screen.
- **Free memory first:** stop the Gradle daemon after a build (`android\gradlew.bat -p android --stop`) before using it. A build beside it ran it out of memory ("System UI isn't responding").
- **Crashes:** it crashed twice while opening a session's checks (exit 139); the app was not at fault.

Step-by-step results: `docs\staging-integration-2026-11-22.md`.

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