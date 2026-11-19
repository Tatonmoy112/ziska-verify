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

Request access, Scanner mode, Serial stack and the History → Sessions view will show "not found" errors until you import the new collection (`docs\protectb-api\ProtectB-mobile-app.postman_collection.json`) into the Postman mock server named in `config\mock.json`. Login, Verify, the Checks list and Profile work now.


/d/flutter/bin/flutter build apk --release --flavor mock --dart-define-from-file=config/mock.json 2>&1 | tail -3