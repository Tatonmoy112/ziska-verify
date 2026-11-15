# Track & Trace — Manual Test Checklist

The 122 test cases of [`docs/test-cases/`](test-cases/README.md) that a person runs (121 marked ✋, and TC-PROF-006, blocked), 9 exploratory charters, and the 52 blocked cases to run once their feature is built. Everything else is automated (`flutter test`). Tick one box per case and write a note for anything that is not a Pass. Report each failure with the bug template in `test-plan.md` §11.2.

| Session | When | Cases |
|---|---|---|
| A. Phone + mock build | Now | 75 |
| B. Release build | Before a release | 4 |
| C. Test server | When the backend sends the test server | 43 |
| D. Exploratory charters | After A, and again after C | 9 |

Tester: ______________ Date: ____________ Build: ____________ Phone / Android: ______________________

---

## Run Kit

How a session is prepared, run, recorded, and retested. The plan behind it: [remaining-work-test-plan.md §6](remaining-work-test-plan.md#6-item-4--manual-runs).

### Schedule

| Session | Runs | Time (about) | Who | Order |
|---|---|---|---|---|
| A. Phone + mock | Now | 7 h in two sittings: A1–A7 (23 cases), then A8–A19 (52, with the 12 Figma comparisons) | Tester | First |
| B. Release build | Now, and before every release | 1 h | Tester or developer (needs adb and a decompiler) | After A |
| C. Test server | When the backend sends the test server and its test sheet | 5 h in two sittings: C1–C5 (29 cases), then C6–C10 (14) | Tester; the client's admin for the portal cases | After A |
| D. Exploratory charters | After A on the mock; again after C on the test server | 45–60 min per charter, about 8 h | Tester; CH-06 needs someone new to the app | Last |
| Blocked | When each feature is built | Per feature | Tester | Its MOCK and DEVICE cases join Session A |

### Equipment

| Item | For |
|---|---|
| Main test phone, Android 13 or newer, USB debugging on | Almost every case |
| A small or older phone (Android 8–10, 5.5″ or less) | NFR-001, -009, the layout cases |
| A phone on the newest Android | NFR-010 |
| A tablet without calling | AUTH-084, NFR-011 on a device |
| A second phone (calls and two-phone cases) | NFR-022, E2E-010, -011, -016 |
| Four phones or installs with one login | AUTH-058 (test server) |
| The QR sheet `docs/test-qr-sheet.pdf` (Q1–Q5) and a printed copy with a corner covered | Scanning cases, LOOK-064 |
| 50 different product QR codes, made with `tool/make_test_qr_sheet.dart` | BULK-036 |
| Photos in the gallery: a normal one, a 50 MP one, a PNG, a WebP, a HEIC | REP-011, -030, -032, -033 |
| A release APK, `adb logcat`, Android Studio "Analyze APK" or a decompiler | Session B |
| A debuggable build (for `run-as`) | SEC-003, -010 |
| A proxy (mitmproxy or HTTP Toolkit) without its certificate installed | ERR-033 |
| Wi-Fi with no internet (a phone hotspot with its own data off) | ERR-032 |
| The client portal login (an admin) | Session C: role, block, password, and switch-off cases |

### Pre-flight (tick before starting)

**Every session**
- [ ] The build and flavor written on the Tester line (`v… · build …`, from Profile → App version)
- [ ] Phone charged; screen lock off or long; Do Not Disturb on (except NFR-022)
- [ ] Font size, display size, and dark mode at the phone's defaults (cases that change them say so, and put them back)
- [ ] Screen recording ready for any failure

**Session A (mock)**
- [ ] `flutter run --flavor mock --dart-define-from-file=config/mock.json` started; login works with any email and code
- [ ] The Postman mock reachable (the address in `config/mock.json`)
- [ ] Roles: a case that names R1–R8 needs that profile. In Postman, open the example **"200 The profile"** of `GET me`, paste the profile from `docs/USER.md`, save, and log out and in again on the phone. Put the Field inspector (R2) back at the end
- [ ] The QR sheet open on the computer screen

**Session B (release)**
- [ ] `flutter build apk --release --flavor mock --dart-define-from-file=config/mock.json --obfuscate --split-debug-info=build/symbols` built and installed
- [ ] `adb logcat` running into a file for SEC-008

**Session C (test server)**
- [ ] The test server address and slug in `config/staging.json`; `flutter run --flavor staging --dart-define-from-file=config/staging.json`
- [ ] The backend's test sheet at hand: 10 logins (inspectors, supervisors, a trainee, retail users, one forced change, one blocked), an item for every result and reason
- [ ] The mail page for emailed codes open
- [ ] The portal open, logged in as the client's admin
- [ ] Never a live client: every check is kept for good (`test-plan.md` §4.2)

**Session D (charters)**
- [ ] The build of the session it follows (mock after A, staging after C)
- [ ] A timer for each charter; notes taken as you go

### During a Session

- Run the cases in the order of the checklist; each sub-section (A1, A2, …) starts from its own set-up line.
- Tick **Pass** only when every part of Expected is met. Anything else is **Fail**, with a note of what happened.
- **Blocked:** the case cannot be run (no equipment, the feature is missing, a step before it failed). Write why.
- For every Fail: stop the recording, keep the time, and copy the "Reference: …" from the screen if one is shown.
- A spec gap or a doubt about Expected is not a Fail: note it and add it to the [decision sheet](decision-sheet.md).

### Recording

1. **The boxes** in this checklist, with notes.
2. **The Summary** at the end of this file: Pass, Fail, and Blocked per session.
3. **The Run log** in [test-plan §11.1](test-plan.md#111-run-log): one line per session (date, build, environment, phone, counts, tester).
4. **Each failure** as a bug with the [§11.2 template](test-plan.md#112-bug-report), titled with the case ID (for example "TC-LOOK-017: two results for one QR"), with the recording and the reference attached.

### Triage and Retest

| Severity (§11.2) | Meaning | Release |
|---|---|---|
| Crash | The app closes or freezes | Blocks |
| Wrong data | A wrong result, check, report, or person shown or recorded | Blocks |
| Blocks a flow | A task cannot be finished | Blocks when the case is P1 |
| Minor | A task is finished with trouble | Does not block |
| Cosmetic | Look only | Does not block |

- A fixed bug is retested on its case and on the other cases of the same sub-section (for example all of A3 after a photo fix), on the same kind of build.
- A failure that a test on the computer can show (a screen, a message, a request) also gets an automated test in `test/flow/`, so it cannot come back unseen.
- A retest is a new line in the Run log, marked "retest".

### Exit

The manual part is done when, together with [test-plan §11.3](test-plan.md#113-exit-criteria-release):

- every **P1** manual case passed on its target (MOCK, STAGE, or DEVICE);
- no open Crash or Wrong data bug, and no open "Blocks a flow" bug on a P1 case;
- every charter run at least once after Session A and once after Session C, with its bugs filed;
- the blocked cases of every feature built for the release passed.

---

## Setup

1. **Phone:** Settings → About phone → tap **Build number** 7 times → Developer options → turn on **USB debugging**. Connect by USB and tap **Allow** on the phone.
2. **Install and start the mock build** from the project folder:
   ```
   flutter run --flavor mock --dart-define-from-file=config/mock.json
   ```
3. **Log in on the mock:** any email (for example `official@example.com`), any password, then any 6 digits as the code.
4. **QR codes:** open `docs/test-qr-sheet.pdf` on the computer screen (or print it). It has:

   | Code | Content | The app must |
   |---|---|---|
   | Q1 | `https://www.ziskaverify.com/q/Q8F2KD91XA7M` | Look it up |
   | Q2 | `https://other-client.example/q/A1B2C3D4E5F6` | Look it up (any host) |
   | Q3 | `https://www.ziskaverify.com/q/Z9Y8X7W6V5U4` | Look it up |
   | Q4 | `https://www.google.com` | Refuse it; open no browser |
   | Q5 | `https://www.ziskaverify.com/q/abc` | Refuse it |

5. **The mock always answers the same** (`test-plan.md` §4.1): every lookup is "Genuine product"; bulk needs exactly 3 items.

---

## Session A — Phone + Mock Build

### A1. Request access (log out first)

#### TC-AUTH-023 · Email the office · P2
1. Login → **Contact us to request access** → **Email the office**.

Expected: the mail app opens to `office@example.com`, subject "Access request", and the body lists Full name, Phone number, Organization, Email address, Job title, Reason for access.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-024 · Call the office · P3
1. Same screen → **Call the office**.

Expected: the dialler opens with `+8800000000000` (the mock's office number). Nothing is dialled automatically.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-025 · No mail app · P3
1. Disable the mail app (Settings → Apps → Gmail → Disable), or use a phone without one.
2. Tap **Email the office**.

Expected: "No email app found. Write to office@example.com." Re-enable the mail app afterwards.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A2. QR scanning (log in)

#### TC-LOOK-015 · Scan a product QR · P1
1. Verify tab → **Scan QR code**. Allow the camera.
2. Point at **Q1**.

Expected: "Verifying…", then the result screen "Genuine product" with reference `MA-2026-000123`.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SEC-005 · A QR link is never opened · P1
1. **Scan QR code** → point at **Q4** (google.com), then at **Q5**.

Expected: for both, "This QR code is not a product code of this company." No browser opens. The camera keeps scanning.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-017 · The same QR held in front of the camera · P2
1. **Scan QR code** → hold **Q1** steadily in view for 5 seconds.

Expected: exactly one result screen opens (the camera stops while the result is shown); pressing back once returns to the camera, not to a second result.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-018 · Camera refused · P2
1. Settings → Apps → Track & Trace Mock → Permissions → Camera → **Don't allow**.
2. Verify tab → **Scan QR code**.

Expected: "Camera access is off. Allow it in Settings to scan QR codes." with **Open settings**, which opens the app's settings page. Allow the camera again afterwards.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-019 · Torch · P3
1. **Scan QR code** → tap the torch button (bottom right) twice.

Expected: the torch turns on, then off.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-BULK-013 · Scan many QR codes · P2
1. Verify tab → MORE → **Bulk lookup** → **Scan QR codes**.
2. Scan **Q1**, **Q2**, **Q3**, then **Q1** again.
3. **Check 3 items**.

Expected: each of the first three shows "Added …" with a short vibration; the fourth shows "This item is already in the list."; the list shows 3 items; the results show a summary and rows 1–3.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A3. Reports and photos

#### TC-REP-012 · Camera and gallery · P1
1. Verify tab → MORE → **Report incident** → **Add photo** → **Take a photo** → take one.
2. **Add photo** → **Choose from gallery** → choose one.

Expected: two thumbnails. Then type a note → **File report** → "Report 1042 filed." and both photos show "Photo 1" (the mock always answers photo 1).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-011 · HEIC photo · P2
1. Put a `.heic` photo in the gallery (from an iPhone, or a phone camera set to HEIF).
2. **Report incident** → **Add photo** → **Choose from gallery** → choose it.

Expected: the thumbnail appears (converted to JPEG); no "could not be read" message.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-015 · Filing on a lost connection · P1
1. **Report incident** → type a note.
2. Turn on **Airplane mode** → **File report**.

Expected: "The connection dropped. The report may have been filed: check My reports before filing it again." The form stays editable. Turn Airplane mode off.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A4. Profile

#### TC-PROF-002 · Support contact · P2
1. Profile tab → **Support contact**.

Expected: the mail app opens to `help@ziska.example`.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-PROF-006 · Language · P2
**Blocked: the language switch is not built yet** (`final.md` 13.8 lists it on Profile). Re-test when it is added.

- [ ] Pass - [ ] Fail - [x] Blocked — Notes: not built

### A5. Start without a connection

#### TC-SESS-010 · Profile fails at start · P2
1. Be logged in. Close the app fully (swipe it away).
2. Turn on **Airplane mode** → open the app.
3. Turn Airplane mode off → tap **Try again**.

Expected: step 2: the start screen shows "No connection. Check the internet and try again." with **Try again**. Step 3: the Verify tab opens.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-010 · Splash on the phone · P2
The splash shows for a moment when the app opens while logged in (and right after login). To keep it on screen, use the error state of TC-SESS-010 (Airplane mode).
1. Normal font size: close the app fully, open it, watch the splash.
2. Airplane mode on, open the app: the error splash stays on screen.
3. Settings → Display → **Font size** and **Display size** to the largest; open the app again (still in Airplane mode).
4. Rotate the phone to landscape.
5. Airplane mode off → scroll if needed → **Try again**.

Expected: in every step the logo, "Track & Trace", and the progress circle or error message are centred on the screen, not on the left; the logo is the same size at every font size and "ZISKA" stays on one line; no yellow-and-black stripes; **Try again** can be reached and opens the Verify tab. Put the font and display size back afterwards.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A6. Devices, accessibility, performance

#### TC-NFR-001 · Small screen · P2
On a phone with a screen of 5.5″ or less, open: Login, code screen, Verify, a result, Bulk lookup with 3 results, History, Report incident, My reports, Profile.

Expected: no yellow-and-black stripes; nothing cut off; every button reachable by scrolling.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-002 · Large text · P2
Settings → Display → **Font size** and **Display size** to the largest. Repeat the screens of NFR-001.

Expected: text wraps; no stripes; buttons still usable.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-003 · Screen reader · P2
Settings → Accessibility → **TalkBack** on. Swipe through Login, the Verify tab, and a result.

Expected: every button and field is read with a clear name (for example "Email", "Show password", "Verify product", "Scan QR code"); the result title is read first. Turn TalkBack off afterwards.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-005 · Slow network · P2
Use a slow connection (weak mobile signal, or Developer options → network speed, or a phone hotspot limited to 2G/3G). Do a lookup and a 3-item bulk lookup; tap the buttons twice quickly.

Expected: a loading indicator; one result each; no duplicate check (the second tap does nothing).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-007 · Long bulk list · P3
Bulk lookup → type serials `1` to `30` (Add after each) and scroll the list.

Expected: scrolling stays smooth; the counter shows "30 / 500 items". (Sending shows an error on the mock, which always answers 3 results; that error is correct.)

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-008 · Rotation and resume · P3
On Verify, a result, Bulk lookup with items, and Report incident with a note: rotate the phone; press Home and come back after 1 minute.

Expected: the screen keeps what was typed; nothing is lost or duplicated. If the phone closed the app in the background, the result screen returns to the Verify tab (by design).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A7. Security on the phone

#### TC-SEC-003 · Passes in secure storage · P1
Needs a debug build and adb:
```
adb shell run-as com.ziskapharma.trackandtrace.mock ls -R
adb shell run-as com.ziskapharma.trackandtrace.mock cat shared_prefs/FlutterSharedPreferences.xml
```
Expected: no `access_token`, `refresh_token`, or phone ID in plain text. The secure storage file holds only encrypted values.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A8. Login (added 2026-11-14)

#### TC-AUTH-043 · Back pressed while logging in · P3
*Needs:* Real phone; slow network.

Tap **Login securely**, then Android back at once; open the app again.

Expected: Home when the login finished (passes stored), Login otherwise; one login only, never a half session.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-084 · Phone without a dialler · P3
*Needs:* Tablet without calling.

Request access; **Call the office**.

Expected: Spec gap 7. No crash.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A9. Session (added 2026-11-14)

#### TC-SESS-031 · Phone clock wrong · P2
*Needs:* Real phone, mock or staging.

Set the phone clock 2 days ahead, then 2 days behind; use the app 30 minutes each.

Expected: The app works; a renewal happens only when the server answers `token_expired`; no extra Login.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SESS-032 · Session survives an app update · P2
*Needs:* Real phone; two builds.

Logged in; install a newer build over the old one; open; log out and log in.

Expected: Home without logging in; the next login needs no code (phone ID kept).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A10. Roles and navigation (added 2026-11-14)

#### TC-NAV-009 · Deep links do not open the app · P2
*Needs:* Real phone.

`adb shell am start -a android.intent.action.VIEW -d "https://www.ziskaverify.com/q/Q8F2KD91XA7M"`; then a link with the app's package scheme.

Expected: The app is not offered or opened for either; the browser handles the website link.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A11. Lookup and camera (added 2026-11-14)

#### TC-LOOK-062 · Camera permanently denied · P2
*Needs:* Real phone.

Deny the camera with "Don't ask again"; **Scan QR code**; **Open settings**; allow; return.

Expected: "Camera access is off. Allow it in Settings to scan QR codes."; settings open; the camera works after returning.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-063 · Phone without a camera · P3
*Needs:* Device or emulator without a camera.

**Scan QR code**.

Expected: "This phone cannot scan QR codes. Type the serial instead.".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-064 · Damaged QR · P3
*Needs:* Real phone; a printed QR with a corner covered.

Point the camera at it.

Expected: Nothing sent until the code reads; never a wrong value.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-065 · Two QR codes in view · P3
*Needs:* Real phone; two product QR codes side by side.

Point the camera at both.

Expected: One lookup; one result screen.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-066 · Scan while offline · P2
*Needs:* Real phone; airplane mode.

Scan a product QR.

Expected: "Unable to verify. Check the connection and try again.".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-067 · Leave the scanner and return · P3
*Needs:* Real phone.

Open Scan; press back; open Scan again; switch to another app and back.

Expected: The camera starts each time; no leftover lookup.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A12. Bulk lookup (added 2026-11-14)

#### TC-BULK-021 · Same QR scanned twice · P2
*Needs:* Real phone.

**Scan QR codes**; scan one QR twice.

Expected: "This item is already in the list."; one row.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-BULK-022 · Non-product QR while building · P2
*Needs:* Real phone.

**Scan QR codes**; scan a website QR.

Expected: "This QR code is not a product code of this company."; not added.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-BULK-025 · Back pressed or app closed while sending · P2
*Needs:* Real phone; slow network.

Send a list of 50; press back (then, another time, close the app).

Expected: Spec gap 10. Never sent twice without the official asking.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-BULK-036 · Fast scanning · P3
*Needs:* Real phone; 50 different product QR codes.

Scan all 50 one after another.

Expected: Each added once with "Added …" and a vibration; no freeze.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A13. Reports and photos (added 2026-11-14)

#### TC-REP-028 · App closed after filing, before the photos · P1
*Needs:* Real phone; mock or staging.

Add 2 photos; File report; close the app as soon as "Report N filed." shows; open it; open My reports.

Expected: The report is listed once, with the photos that arrived; nothing is sent by itself (nothing is queued on the phone).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-030 · PNG photo · P2
*Needs:* Real phone.

Choose a PNG from the gallery; file.

Expected: Sent and counted on the report.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-032 · WebP photo · P3
*Needs:* Real phone.

Choose a WebP image from the gallery.

Expected: Sent as a JPEG (the server refuses WebP).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-033 · Very large photo · P2
*Needs:* Real phone; a 50 MP photo.

Add it; file.

Expected: Shrunk to 2048 px on the longer side and at most 1 MB; no crash; the screen stays usable.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-040 · Camera or gallery permission denied · P2
*Needs:* Real phone.

Deny camera, then gallery access; **Add photo**.

Expected: Spec gap 11. No crash; the report can still be filed without photos.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A14. Retail users (added 2026-11-14)

#### TC-RTL-030 · First password not restored after the system closes the app · P2
*Needs:* Real phone; "Don't keep activities" on.

Add with the switch off; leave the app; return.

Expected: The password is not shown again.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A15. Errors and network (added 2026-11-14)

#### TC-ERR-030 · Countdown while in the background · P3
*Needs:* Real phone.

`429` with `Retry-After: 60`; put the app in the background 70 s; return.

Expected: The countdown has ended; a retry is possible.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-ERR-032 · Unknown host or no internet behind Wi-Fi · P2
*Needs:* Real phone; Wi-Fi with no internet.

Log in; open History; look up.

Expected: The connection message each time.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-ERR-033 · Untrusted certificate · P1
*Needs:* Real phone; a proxy with a certificate the phone does not trust.

Use the app through the proxy.

Expected: Every request fails with the connection message; nothing readable in the proxy.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-ERR-035 · Back online · P2
*Needs:* Real phone.

Airplane mode; open History (error); airplane mode off; **Try again**.

Expected: Loads without restarting the app.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A16. Security (added 2026-11-14)

#### TC-SEC-010 · Nothing about items or checks on disk · P1
*Needs:* Real phone; debuggable build (`run-as`).

After lookups, a bulk, and History, list the app's files and caches.

Expected: No item or check data, no queued scans, no cached answers.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SEC-011 · Backup holds no secret · P1
*Needs:* Real phone; a backup of the app.

Back up the app data; read it.

Expected: No pass and no phone ID in a readable form.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SEC-012 · App switcher and screenshots · P3
*Needs:* Real phone.

Open the recent apps on a result and on "… was added" with the first password shown; take a screenshot.

Expected: Spec gap 14.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A17. Devices, accessibility, performance (added 2026-11-14)

#### TC-NFR-009 · Oldest supported Android · P2
*Needs:* A phone on the build's minimum Android version (Android 8 if available).

Install; log in; look up; scan a QR; file a report with a photo; log out.

Expected: Everything works as on the main phone.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-010 · Newest Android · P2
*Needs:* A phone on the newest Android.

Repeat NFR-009; look at the top and bottom edges of every main screen.

Expected: Everything works; nothing hidden under the status bar or the navigation bar.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-012 · Split screen · P3
*Needs:* Real phone.

Put the app in half of a split screen; use Verify, History, Report incident.

Expected: Everything reachable by scrolling; no overflow.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-018 · TalkBack on every screen · P2
*Needs:* Real phone; TalkBack on.

Swipe through History, Bulk lookup, Report incident, My reports, Retail users, Profile; cause one error on each.

Expected: Every item read with a clear name; errors read when they appear.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-020 · System dark mode · P3
*Needs:* Real phone.

Turn on the phone's dark mode; open every main screen.

Expected: Spec gap 15. Every text readable.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-021 · Process death on every screen · P2
*Needs:* Real phone; Developer options → "Don't keep activities" on.

On each main screen, press Home and return.

Expected: No crash; a screen whose `extra` is gone returns to its parent; no hidden code or password restored.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-022 · Incoming call during a request · P3
*Needs:* Two phones.

Call the test phone during a lookup, a bulk send, and a report filing; return after the call.

Expected: One result, one bulk answer, one report; nothing lost or doubled.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-023 · Battery and data saver · P3
*Needs:* Real phone.

Turn on battery saver and data saver; log in, look up, open History.

Expected: Everything works.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-026 · Almost no free storage · P3
*Needs:* Real phone with under 100 MB free.

Add a large photo to a report; file.

Expected: No crash; the photo is sent, or a photo message is shown.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-027 · Keyboard never hides the field · P2
*Needs:* A small phone.

Type in every field of Login, Set a new password, Report incident, Add retail user.

Expected: The field in use and its button can be seen above the keyboard (by scrolling).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-012 · Look matches the design · P3
*Needs:* Real phone; `figma/`.

Compare Login, Verify, a result, History, Profile with the designs.

Expected: Colours, type, and spacing as designed; where they differ, the behaviour of final.md wins.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A18. Journeys (added 2026-11-14)

#### TC-E2E-013 · Connection lost along a journey · P2
*Needs:* Real phone; mock build.

Bulk lookup → History → report; turn airplane mode on and off at each step.

Expected: Each step shows its connection message and works again online; no check or report doubled.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A19. Figma by eye (added 2026-11-14)

Open each Figma image from `figma/` on the computer, and the same screen on the phone. Note every difference; Figma is a reference for the look, so a difference is a note, not a Fail, unless a colour, text, or control is missing.

#### TC-UI-147 · Figma by eye: the splash · P3
*Needs:* Real phone, mock build; `figma/Landing Page.png` on the computer.

Open the splash beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-148 · Figma by eye: Login · P3
*Needs:* Real phone, mock build; `figma/Login.png` on the computer.

Open Login beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-149 · Figma by eye: the Verify tab · P3
*Needs:* Real phone, mock build; `figma/Home page.png` on the computer.

Open the Verify tab beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-150 · Figma by eye: Request access · P3
*Needs:* Real phone, mock build; `figma/Request for id.png` on the computer.

Open Request access beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-151 · Figma by eye: the scanner · P3
*Needs:* Real phone, mock build; `figma/scan by barcode.png` on the computer.

Open the scanner beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-152 · Figma by eye: a lookup in progress · P3
*Needs:* Real phone, mock build; `figma/verification loader.png` on the computer.

Open a lookup in progress beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-153 · Figma by eye: a genuine result · P3
*Needs:* Real phone, mock build; `figma/verified product.png` on the computer.

Open a genuine result beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-154 · Figma by eye: a result checked before · P3
*Needs:* Real phone, mock build; `figma/already verified product.png` on the computer.

Open a result checked before beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-155 · Figma by eye: a not-found result · P3
*Needs:* Real phone, mock build; `figma/invalid product.png` on the computer.

Open a not-found result beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-156 · Figma by eye: the item details · P3
*Needs:* Real phone, mock build; `figma/batch details by id.png` on the computer.

Open the item details beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-157 · Figma by eye: item tracking in History · P3
*Needs:* Real phone, mock build; `figma/product history.png` on the computer.

Open item tracking in History beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-158 · Figma by eye: Profile · P3
*Needs:* Real phone, mock build; `figma/11 _ Profile 1.png` on the computer.

Open Profile beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

---

## Session B — Release Build

```
flutter build apk --release --flavor live --dart-define-from-file=config/live.json --obfuscate --split-debug-info=build/symbols
```
(`config/live.json` needs real values first; a mock release build can be made the same way with `--flavor mock` and `config/mock.json`.)

#### TC-SEC-006 · Release build is obfuscated · P2
Open the APK in Android Studio (Build → Analyze APK) → `lib/arm64-v8a/libapp.so`, or run `strings` on it.

Expected: Dart class names such as `ReportIncidentBloc` do not appear.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-006 · Start time · P3
Release build, logged in; close the app fully; time from tapping the icon until the Verify tab shows. Repeat 3 times.

Expected: under 3 seconds on the main test phone.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes: times: ____ ____ ____

### B1. Security (added 2026-11-14)

#### TC-SEC-008 · Release build log · P1
*Needs:* Real phone; release build; `adb logcat`.

Log in with a code; look up by hidden code; change the password; add a retail user; watch `adb logcat` the whole time.

Expected: no pass, password, emailed code, hidden code, or phone ID in logcat.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SEC-022 · No secret inside the release app · P1
*Needs:* Release APK.

Search the APK's strings and decompiled code.

Expected: No pass, password, or key; only the base URL and the client slug.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

---

## Session C — Test Server (when available)

```
flutter run --flavor staging --dart-define-from-file=config/staging.json
```
Use the logins and items of the backend's test sheet; read emailed codes on its mail page.

#### TC-AUTH-012 · A trusted phone logs in without a code · P1
Log in once with a code; log out; log in again.

Expected: the second login has no code screen.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SESS-007 · The next login after logout needs no code · P1
Profile → Log out → log in again on the same phone.

Expected: no code screen.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-026 · Login rate limit · P2
Enter a wrong password repeatedly until the app shows a wait message.

Expected: "Too many attempts. Try again in N s." counting down; no crash. (After 5 wrong passwords the account is also locked for 15 minutes; the message stays "Email or password is incorrect.")

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NAV-007 · Role changed while logged in · P2
Ask the client's admin (portal) to remove `history:own` from the test role; in the app open History.

Expected: the History tab disappears (after the next request or a restart).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-HIST-010 · Date range · P2
History → Filters → choose today only → Apply. Do a lookup between 00:00 and 06:00 Bangladesh time if possible.

Expected: only today's checks. Record whether a check made after midnight Bangladesh time appears under today (this answers the backend question in `final.md` 20.2).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-HIST-012 · Times in Bangladesh time · P1
Set the phone's time zone to another country (Settings → System → Date & time). Open History and a result with "Checked before".

Expected: the times shown are Bangladesh time, not the phone's.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-010 · Photo is shrunk and has no metadata · P1
Turn on the camera's location tag; take a photo in a report; file it. In the client portal (or with an HTTPS proxy such as HTTP Toolkit) download the stored photo and check it with an EXIF viewer.

Expected: JPEG; the longer side 2048 px or less; 1 MB or less; no EXIF (no location, time, or phone model); the image is upright.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-RTL-010 · Own password already set · P2
As a supervisor, "Email a new first password" for a retail user who has already changed their password.

Expected: "… has set their own password. Only your office can change it now."

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-RTL-011 · Hourly limit · P3
Add retail users or email first passwords more than 30 times in an hour.

Expected: a wait message with seconds; no crash.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-PROF-005 · Voluntary password change · P2
Profile → Change password → current password, a new one (`abcd1234` style) twice → Save.

Expected: "Your password was changed."; back on Profile; another phone logged in with the same account is logged out.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C1. Login (added 2026-11-14)

#### TC-AUTH-028 · Email in capitals · P3
*Needs:* Staging build, backend test sheet.

Log in with a test login, its email typed in capitals.

Expected: Spec gap 4 (whether the backend matches emails without case).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-037 · Blocked official · P1
*Needs:* Staging build, backend test sheet.

Log in with the blocked login, right password.

Expected: "Email or password is incorrect.".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-038 · Lockout after 5 wrong passwords · P1
*Needs:* Staging build, backend test sheet.

Wrong password 5 times; then the right password; 15 minutes later the right password again.

Expected: Attempts 1–6: "Email or password is incorrect." (the lock is not revealed); after 15 minutes: logged in.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-049 · Expired code · P1
*Needs:* Staging build, backend test sheet.

Log in; wait 6 minutes; enter the emailed code.

Expected: "The code is wrong or has expired. Check the latest email, or log in again for a new code."; still on the code screen.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-050 · Old code after a resend · P2
*Needs:* Staging build, backend test sheet.

Log in; **Send the code again**; enter the first code.

Expected: "The code is wrong or has expired. Check the latest email, or log in again for a new code."; the second code works.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-051 · Sixth try · P2
*Needs:* Staging build, backend test sheet.

Enter 5 wrong codes, then the right one; then **Back to login** and log in again.

Expected: The 6th try: "The code is wrong or has expired. Check the latest email, or log in again for a new code."; the new login emails a new code that works.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-052 · 10 wrong codes in an hour · P2
*Needs:* Staging build, backend test sheet.

Enter 10 wrong codes within an hour (logging in again as needed); then log in with the right password.

Expected: The login answers "Email or password is incorrect." for 15 minutes; afterwards it works.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-058 · A 4th trusted phone forgets the oldest · P2
*Needs:* Staging; 4 phones (or 4 installs), one login.

Log in with codes on phones A, B, C, D in that order; log out on A; log in on A.

Expected: A asks for an emailed code again.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-059 · Clearing app data makes a new phone · P2
*Needs:* Staging; a phone that logged in before.

Clear the app data (or reinstall); log in.

Expected: A new phone ID: the code screen opens.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-063 · New password the same as the current one · P3
*Needs:* Staging build, backend test sheet.

On Set a new password, type the current password as the new one.

Expected: Spec gap 6.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-080 · A reset ends every login · P1
*Needs:* Staging; phones A and B, one login.

Logged in on B; reset the password on A; use B; then log in on B.

Expected: B goes to Login at its next request; B's next login asks for an emailed code (trusted phones forgotten).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-082 · More than 5 codes in 15 minutes · P3
*Needs:* Staging build, backend test sheet.

Forgot password; **Send code** 6 times within 15 minutes.

Expected: Every answer: "If the address has an account, a code was sent."; the 6th mail never arrives.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C2. Session (added 2026-11-14)

#### TC-SESS-021 · Back after 20 minutes in the background · P2
*Needs:* Staging; real phone.

Log in; put the app in the background 20 minutes; return and open History.

Expected: Data loads after a silent renewal; no Login screen.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SESS-022 · App killed during a renewal · P3
*Needs:* Staging; real phone.

Let the access pass expire; open History and kill the app at once; open it.

Expected: Home (the new passes were stored) or Login (the used refresh pass ended the login); never a crash or an endless loading.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SESS-027 · Admin changes the role or sets a new password · P2
*Needs:* Staging; portal access.

Logged in; in the portal change the role, use the app; log in again; in the portal set a new password, use the app.

Expected: Each time the next request lands on Login.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C3. Roles and navigation (added 2026-11-14)

#### TC-ROLE-019 · Permission gained · P2
*Needs:* Staging; portal access.

In the portal add `item:bulk_lookup` to the role; wait a minute; restart the app.

Expected: The Bulk lookup tile appears (the profile loads at start, after login, and after a `403`).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C4. Lookup and camera (added 2026-11-14)

#### TC-LOOK-025 · New formats after the next login · P3
*Needs:* Staging; the backend changes a format.

Log out and log in; type a value of the new format.

Expected: Accepted under the new format.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-053 · Expiry on the day itself · P2
*Needs:* Staging; a batch expiring today (Bangladesh date).

Look the item up today; again tomorrow.

Expected: Today: no "Expired"; tomorrow: "Expired".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-116 · A real picture on a phone · P1
*Needs:* Staging; a test-sheet product with a 5 MB picture.

Look the item up on Wi-Fi, then on slow 3G (developer options or a throttled hotspot); tap the picture and zoom; rotate the phone.

Expected: The picture loads over HTTPS (a skeleton first on 3G), zooms sharp, and the app stays smooth.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C5. Bulk lookup (added 2026-11-14)

#### TC-BULK-035 · 3 000 items a minute · P3
*Needs:* Staging build, backend test sheet.

Send 500-item lists one after another for a minute.

Expected: `429` with a countdown; after the wait the same list goes through.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C6. History (added 2026-11-14)

#### TC-HIST-041 · Long scroll · P3
*Needs:* Staging; an official with 1 000+ checks; real phone.

Scroll through 20+ pages.

Expected: Smooth scrolling; no row twice; memory steady.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-PROF-040 · The check counts on Profile · P3
*Needs:* Staging; an official with checks; real phone.

1. Open **Profile**; note **Checks**, **Valid**, **Not verified**.
2. Open **History**; compare with the **All**, **Valid**, **Not found** and **Not in a batch** chips.
3. Check one item on the Verify tab; open **Profile** again.
4. Pull the Profile down.

Expected: step 2: Checks = All, Valid = Valid, Not verified = Not found + Not in a batch. Step 3: **Checks** is one more. Step 4: the counts are asked for again, nothing jumps.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C7. Reports and photos (added 2026-11-14)

#### TC-REP-037 · A photo sent twice counts once · P1
*Needs:* Staging; real phone.

Airplane mode the moment a photo starts sending; back online; tap the failed photo.

Expected: My reports shows the true number of photos (not one extra).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-048 · 50 reports an hour · P3
*Needs:* Staging build, backend test sheet.

File 51 reports within an hour.

Expected: The 51st: a countdown; no crash.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-REP-049 · Photo after the hour on the server · P3
*Needs:* Staging build, backend test sheet.

File a report; add a photo 61 minutes later.

Expected: "Photos can be added only within an hour of the report.".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C8. Retail users (added 2026-11-14)

#### TC-RTL-015 · Email in other capitals already used · P3
*Needs:* Staging build, backend test sheet.

Add `Rahim.Store@Gmail.com` when `rahim.store@gmail.com` exists.

Expected: Spec gap 4.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-RTL-031 · A new retail user can be picked at once · P2
*Needs:* Staging build, backend test sheet.

Add a retail user; Report incident → Choose a retail user; search the name.

Expected: The new retail user is listed.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-RTL-036 · The old first password stops working · P2
*Needs:* Staging build, backend test sheet.

Email a new first password; log in as that retail user with the old one.

Expected: "Email or password is incorrect.".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C9. Devices, accessibility, performance (added 2026-11-14)

#### TC-NFR-024 · 500 bulk results · P2
*Needs:* Staging; real phone; 500 items from the test sheet.

Send 500 items; scroll the results; open 10 rows; turn the switch on and off.

Expected: No crash; smooth scrolling; rows open at once.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-025 · One-hour session · P2
*Needs:* Staging; real phone.

Use the app for an hour (at least 4 renewals): lookups, History, reports.

Expected: No Login screen; no slowdown; memory steady.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### C10. Journeys (added 2026-11-14)

#### TC-E2E-009 · A suspect item reported · P1
*Needs:* Staging; an inspector login; the test sheet's `not_found` item.

Look the item up; **Report incident** with 2 photos; open My reports; ask the office to open the report in the portal.

Expected: My reports lists it with 2 photos and the reference; the office sees the same report and photos.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-E2E-010 · A new retail user's first day · P1
*Needs:* Staging; a supervisor login; a second phone.

Supervisor adds a retail user (switch on); on the second phone the retail user logs in with the emailed first password; code; new password; looks up an item; opens History.

Expected: Code screen, then the forced change, then Home; History lists that check only.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-E2E-011 · Password handed over in person · P2
*Needs:* Staging; a supervisor login; a second phone.

Add a retail user with the switch off; give the shown password; the retail user logs in with it.

Expected: No mail sent; the login works; the forced change follows.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-E2E-015 · Blocked in the middle of the day · P2
*Needs:* Staging; portal access.

Logged in; the admin blocks the official; use the app; try to log in.

Expected: Login at the next request; then "Email or password is incorrect.".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-E2E-016 · Two phones, one official · P2
*Needs:* Staging; phones A and B.

Logged in on both; change the password on A; use B; log in on B with the new password.

Expected: A stays logged in; B goes to Login; B logs in with the new password.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

---

## Session D — Exploratory Charters

Time-boxed sessions. Explore freely inside the mission and report every problem with the bug template.

### D1. Exploratory charters (added 2026-11-14)

#### CH-01 · Odd input everywhere · P2
*Setup:* Mock build; 60 minutes.

**Mission:** Break every text field. Paste emoji, Arabic and Bangla text, 10 000 characters, zero-width spaces, spaces around values, line breaks.

**Note:** Crashes, overflow, text changed without telling, anything sent that should have been refused.

- [ ] Done — Bugs found:

#### CH-02 · Fast and repeated taps · P2
*Setup:* Mock build; 45 minutes.

**Mission:** Make the app send twice. Double and triple taps, taps while loading, tab switches during requests.

**Note:** Any request sent twice (a check, a report, a retail user), stuck loading, a frozen screen.

- [ ] Done — Bugs found:

#### CH-03 · Flaky network · P2
*Setup:* Real phone; mock or staging; 60 minutes.

**Mission:** Lose the connection at the worst moment. Airplane mode at random points of every flow; a walk through weak signal.

**Note:** Wrong or missing messages, no recovery, doubled checks or reports, logouts that should not happen.

- [ ] Done — Bugs found:

#### CH-04 · Interruptions · P3
*Setup:* Real phone; 45 minutes.

**Mission:** Interrupt every flow. Calls, notifications, app switching, screen lock, rotation, low-battery warnings.

**Note:** Lost input, lost state, crashes.

- [ ] Done — Bugs found:

#### CH-05 · Admin changes during use · P2
*Setup:* Staging; portal access; 60 minutes.

**Mission:** Change the official in the portal while they work. Role, permissions, block, new password, client switched off.

**Note:** What the official sees within a minute, and anything still shown that the role no longer allows.

- [ ] Done — Bugs found:

#### CH-06 · A first-time user · P3
*Setup:* Mock build; someone who has not used the app; 45 minutes.

**Mission:** The main tasks without help: log in, look up, scan, report, find a check in History.

**Note:** Where they hesitate, texts they misread, steps they cannot find.

- [ ] Done — Bugs found:

#### CH-07 · Accessibility walk · P2
*Setup:* Real phone; TalkBack, font 3×; 45 minutes.

**Mission:** Do every main task with TalkBack, then with the largest font, then with one hand.

**Note:** Controls that cannot be reached or are not read.

- [ ] Done — Bugs found:

#### CH-08 · A long shift · P3
*Setup:* Staging; real phone; 60 minutes.

**Mission:** A normal hour of work across several renewals.

**Note:** Slowdowns, memory growth, unexpected Login screens.

- [ ] Done — Bugs found:

#### CH-09 · Time and dates · P2
*Setup:* Staging; real phone; 45 minutes.

**Mission:** Confuse the clock. Other time zones, 12- and 24-hour settings, a wrong date, around midnight Bangladesh time.

**Note:** Wrong times, History date filters that miss checks, wrong expiry warnings.

- [ ] Done — Bugs found:

---

## Blocked: Not Built Yet

These cases wait for a feature in the spec that is not built ([remaining-work-test-plan.md §4](remaining-work-test-plan.md#4-item-2--blocked-features)). When it is built, the AUTO ones are automated and the MOCK and DEVICE ones move into Session A.

### Certificate (21)

| Case | Title | Run on | Spec |
|---|---|---|---|
| TC-LOOK-068 | Certificate from a valid result | MOCK | §13.3 |
| TC-LOOK-069 | Certificate from a warning lists its reasons | AUTO | §13.3 |
| TC-LOOK-070 | No certificate for not found or not in a batch | AUTO | §13.3 |
| TC-LOOK-071 | Certificate time with its offset | AUTO | §13.3, §18.3 Time display |
| TC-LOOK-072 | Certificate file removed after sharing | DEVICE | §13.3 |
| TC-LOOK-073 | Certificate restored without its result | AUTO | §9.5 Missing extra |
| TC-LOOK-074 | The official's name on the certificate | AUTO | §13.3 |
| TC-LOOK-075 | Check time on a phone in another time zone | AUTO | §13.3, §16 |
| TC-LOOK-076 | Optional fields missing | AUTO | §13.1.4, §13.3 |
| TC-LOOK-077 | Long names wrap on the page | AUTO | §13.3 |
| TC-LOOK-078 | Bangla and symbols print | AUTO | §2.2, §13.3 |
| TC-LOOK-079 | Only the masked code | AUTO | §12.1 Hidden code protection, §13.3 |
| TC-LOOK-080 | Every reason, and an unknown one | AUTO | §13.1.5, §13.3 |
| TC-LOOK-081 | Reference printed exactly | AUTO | §13.3 |
| TC-LOOK-082 | Share cancelled | AUTO + DEVICE | §13.3 |
| TC-LOOK-083 | The PDF cannot be made | AUTO | §13.3 |
| TC-LOOK-084 | Certificate needs `item:lookup` | AUTO | §9.3, §9.4 |
| TC-LOOK-085 | One press, one certificate | AUTO | §8.3 |
| TC-LOOK-086 | Opens and prints on a phone | DEVICE | §13.3 |
| TC-LOOK-087 | The client's layout | MOCK | §13.3, §20.3 |
| TC-LOOK-088 | Certificate language | AUTO | §13.3, §16 |

### Language switch (20)

| Case | Title | Run on | Spec |
|---|---|---|---|
| TC-HIST-044 | Times in Bangla digits | AUTO | §16 |
| TC-PROF-006 | Language | MOCK | §16 |
| TC-PROF-018 | Switch to Bangla | MOCK | §16 |
| TC-PROF-019 | Language kept after a restart | AUTO | §12.1 Local data, §16 |
| TC-PROF-020 | Every English text has a Bangla text | AUTO | §16, §20.3 |
| TC-PROF-021 | Placeholders kept in Bangla | AUTO | §16 |
| TC-PROF-022 | The switch on Profile | AUTO | §13.8 |
| TC-PROF-023 | The switch applies at once | AUTO | §13.8, §16 |
| TC-PROF-024 | Reference line in Bangla | AUTO | §16 |
| TC-PROF-025 | Messages chosen by error code in Bangla | AUTO | §16 |
| TC-PROF-026 | Unknown code: the server text stays | AUTO | §16 |
| TC-PROF-027 | Times in Bangla digits outside History | AUTO | §16 |
| TC-PROF-028 | Date picker in Bangla | AUTO | §10.2, §16 |
| TC-PROF-029 | Kept after logout | AUTO | §6.5, §12.1 |
| TC-PROF-030 | Language at the first start | AUTO | §16 |
| TC-PROF-031 | Bangla at large fonts | AUTO | §14, §16 |
| TC-PROF-032 | TalkBack in Bangla | DEVICE | §14, §16 |
| TC-PROF-033 | Password rules in Bangla | AUTO | §6.6, §16 |
| TC-PROF-034 | A Bangla reader checks the texts | DEVICE | §16 |
| TC-PROF-035 | Bangla digits typed into a serial | AUTO | §13.1.2, §16 |

### Offline banner (11)

| Case | Title | Run on | Spec |
|---|---|---|---|
| TC-ERR-036 | Offline banner | DEVICE | §14.2 |
| TC-ERR-037 | The banner on every main screen | AUTO | §14.2 |
| TC-ERR-038 | The banner goes when back online | AUTO | §14.2 |
| TC-ERR-039 | The banner on the login screens | AUTO | §14.2 |
| TC-ERR-040 | The banner never blocks | AUTO | §13.1.6, §14.2 |
| TC-ERR-041 | Back online sends nothing by itself | AUTO | §12.1 API protection |
| TC-ERR-042 | Wi-Fi without internet | AUTO | §14.2 |
| TC-ERR-043 | A flapping connection | AUTO | §14.2 |
| TC-ERR-044 | Read by TalkBack | AUTO + DEVICE | §14 |
| TC-ERR-045 | Fits at 3× font and 320 px | AUTO | §14 |
| TC-ERR-046 | The banner in Bangla | AUTO | §14.2, §16 |

## Summary

| Session | Pass | Fail | Blocked |
|---|---|---|---|
| A. Phone + mock | | | |
| B. Release build | | | |
| C. Test server | | | |
| D. Exploratory charters | Done: | Bugs: | |
