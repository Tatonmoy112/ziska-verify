# Track & Trace — Manual Test Checklist

> **2026-11-16 contract migration:** final.md v2.0 and [the migration acceptance cases](test-cases/16-mobile-migration.md) supersede conflicting requirements below. Hidden-code submission, the 500-item bulk endpoint, everyone scope, retail administration and certificates are retired. Old counts/status tables are historical, not current completion evidence. Use [the release backlog](release-backlog.md) for unrelated unfinished work.


The 103 test cases of [`docs/test-cases/`](test-cases/README.md) that a person runs (102 marked ✋, and TC-PROF-006, blocked), 9 exploratory charters, and the 31 blocked cases to run once their feature is built. Everything else is automated (`flutter test`). Tick one box per case and write a note for anything that is not a Pass. Report each failure with the bug template in `test-plan.md` §11.2.

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

5. **The mock answers by the value's last digit** (`docs/postman-mock-setup.md`; the mock must be made from the 2026-11-17 collection):
   - a typed serial ending in 1 is Genuine, 2 needs attention, 3 not found, 4 not in a batch, anything else Genuine;
   - in Scanner mode a QR ending in 3 is not found, any other the "first scan" example;
   - a stack of serials always answers the collection's three-serial example;
   - the login asks for a code, and any 6 digits are accepted; the code `111111` logs in to a forced password change (to try **Not now**);
   - photos are numbered 1, 2, 3 per report.

---

## Session A — Phone + Mock Build

### A1. Sign up (log out first)

#### TC-AUTH-023 · Email the office · P2
1. Login → **Contact us to request access** → **Email the office**.

Expected: the mail app opens to `office@example.com`, subject "Access request", and the body lists Full name, Phone number, Organization, Email address, Job title, Reason for access.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-024 · Call the office · P3
1. Same screen → **Call the office**.

Expected: the dialler opens with `+8800000000000` (the mock's office number). Nothing is dialled automatically.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A2. QR scanning (log in)

#### TC-LOOK-015 · Scan a product QR · P1
1. Open the Check tab: the camera starts at once. Allow the camera.
2. Point at **Q1**.

Expected: "Checking…", then the result screen "Genuine product" with reference `MA-2026-000123`.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-SEC-005 · A QR link is never opened · P1
1. On the Check tab, point the camera at **Q4** (google.com), then at **Q5**.

Expected: for both, "This QR code is not a product code of this company." No browser opens. The camera keeps scanning.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-017 · The same QR held in front of the camera · P2
1. On the Check tab, hold **Q1** steadily in view for 5 seconds.

Expected: exactly one result screen opens (the camera stops while the result is shown); pressing back once returns to the camera, not to a second result.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-018 · Camera refused · P2
1. Settings → Apps → Track & Trace Mock → Permissions → Camera → **Don't allow**.
2. Open the Check tab (the camera starts by itself).

Expected: "Camera access is off. Allow it in Settings to scan QR codes." with **Open settings**, which opens the app's settings page. Allow the camera again afterwards.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-019 · Torch · P3
1. On the Check tab, tap the torch button (top right of the camera) twice.

Expected: the torch turns on, then off.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-MIG-055 · Scanner mode on a phone with the test sheet · P1
Open `docs/test-qr-sheet.pdf` page 2 ("Scanner mode: 8 products") on the PC screen.
1. Check tab → **Scanner mode**. **Finish** is off.
2. Scan S1 to S8 one after another, without waiting for each answer.
3. Scan S1 again.
4. Tap **Finish**, then a row, then Back; then **Done**.

Expected: each result shows on the camera as it comes, in its colour, with a vibration, and joins the list below; "Checking… N more" while answers are on their way; nothing is skipped. S1 again: "Already scanned", the counts unchanged. Finish: "Session finished", "8 products scanned" (4 genuine, 2 needing attention, 1 not found, 1 not in a batch), every product with its result; a row opens its full result; Done returns to the Check tab. **Scan more** (try once) starts again with an empty list.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A3. Reports and photos

#### TC-REP-012 · Camera and gallery · P1
1. Check tab → MORE → **Report incident** → **Add photo** → **Take a photo** → take one.
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
1. Profile tab → **Language** (under ACCOUNT). It says "English".
2. The sheet offers **English** (ticked) and **বাংলা**. Tap **বাংলা**.

Expected: the screen turns to Bangla at once, with no restart; the row now reads "ভাষা" with "বাংলা" under it; the tabs read যাচাই, ইতিহাস, প্রোফাইল.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-PROF-018 · Switch to Bangla, every screen · P2
With the app in Bangla (TC-PROF-006):
1. Visit every screen: Check, a result (serial `1000001`), Scanner mode, Serial stack, Report incident, My reports, History (Checks and Sessions), Profile, Change password.
2. Look up `1000003` (not found) and read the reference line.
3. Log out: Login, Forgot password and Sign up.

Expected: every app text in Bangla, Bangla letters drawn properly (no boxes); "রেফারেন্স: …" with the reference itself unchanged; times with Bangla digits. Product names, serials and references stay as sent. Switch back to English at the end.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A5. Start without a connection

#### TC-UI-010 · Splash on the phone · P2
The splash shows for a moment when the app opens while logged in (and right after login). To keep it on screen, use the error state of TC-SESS-010 (Airplane mode).
1. Normal font size: close the app fully, open it, watch the splash.
2. Airplane mode on, open the app: the error splash stays on screen.
3. Settings → Display → **Font size** and **Display size** to the largest; open the app again (still in Airplane mode).
4. Rotate the phone to landscape.
5. Airplane mode off → scroll if needed → **Try again**.

Expected: in every step the logo, "Track & Trace", and the progress circle or error message are centred on the screen, not on the left; the logo is the same size at every font size and "ZISKA" stays on one line; no yellow-and-black stripes; **Try again** can be reached and opens the Check tab. Put the font and display size back afterwards.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A6. Devices, accessibility, performance

#### TC-NFR-001 · Small screen · P2
On a phone with a screen of 5.5″ or less, open: Login, code screen, Check, a result, Bulk lookup with 3 results, History, Report incident, My reports, Profile.

Expected: no yellow-and-black stripes; nothing cut off; every button reachable by scrolling.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-002 · Large text · P2
Settings → Display → **Font size** and **Display size** to the largest. Repeat the screens of NFR-001.

Expected: text wraps; no stripes; buttons still usable.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-NFR-003 · Screen reader · P2
Settings → Accessibility → **TalkBack** on. Swipe through Login, the Check tab, and a result.

Expected: every button and field is read with a clear name (for example "Email", "Show password", "Check", "Torch"); the result title is read first. Turn TalkBack off afterwards.

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
On Check, a result, Bulk lookup with items, and Report incident with a note: rotate the phone; press Home and come back after 1 minute.

Expected: the screen keeps what was typed; nothing is lost or duplicated. If the phone closed the app in the background, the result screen returns to the Check tab (by design).

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

### A9. Session (added 2026-11-14)

#### TC-SESS-041 · Kill during a renewal; a wrong clock · P3
*Needs:* Staging; real phone.

1. Leave the app 20 minutes; open **History** and kill the app at once (recent apps, swipe away); open it.
2. Set the phone clock 2 days ahead; use the app 30 minutes; then 2 days behind; 30 minutes.

Expected: step 1: the app opens logged in, or on Login — never stuck. Step 2: everything works; no logout from the clock alone.

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

Deny the camera with "Don't ask again"; open the Check tab; **Open settings**; allow; return.

Expected: "Camera access is off. Allow it in Settings to scan QR codes."; settings open; the camera works after returning.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-063 · Phone without a camera · P3
*Needs:* Device or emulator without a camera.

Open the Check tab.

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

Expected: "Unable to check. Check the connection and try again.".

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-LOOK-067 · Leave the scanner and return · P3
*Needs:* Real phone.

Open Scan; press back; open Scan again; switch to another app and back.

Expected: The camera starts each time; no leftover lookup.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

### A12. Bulk lookup (added 2026-11-14)

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

Put the app in half of a split screen; use Check, History, Report incident.

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

Compare Login, Check, a result, History, Profile with the designs.

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

#### TC-UI-149 · Figma by eye: the Check tab · P3
*Needs:* Real phone, mock build; `figma/Home page.png` on the computer.

Open the Check tab beside the Figma image.

Expected: Colours, type sizes, spacing, and icons look like the design; every difference written down (Figma is a reference: a difference is a note, not a failure).

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-UI-150 · Figma by eye: Sign up · P3
*Needs:* Real phone, mock build; `figma/Request for id.png` on the computer.

Open Sign up beside the Figma image.

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
Release build, logged in; close the app fully; time from tapping the icon until the Check tab shows. Repeat 3 times.

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

## Session C — Test Server

The backend's test server is ready (2026-11-22): `https://testapp.protecb.com`, client `ziska-test` (already in `config/staging.json`). The test login is given by the project owner, never written down in the repo. The emailed codes reach that login's inbox.
```
flutter build apk --release --flavor staging --dart-define-from-file=config/staging.json --split-per-abi
```
The staging app installs next to the mock app (its own name, "Track & Trace Staging"). Progress, step by step: [staging-integration-2026-11-22.md](staging-integration-2026-11-22.md).

#### TC-STG-014 · Login, restart, logout, login again · P1
1. Log in with the test login; enter the code from its email.
2. Close the app fully and open it again.
3. Profile → **Log out** → **Log out**.
4. Log in again.

Expected: in after the code (the account's name and organisation shown); still in after the restart; Login after logging out; the second login needs no code.

- [x] Pass - [ ] Fail - [ ] Blocked — Notes: 2026-11-22, emulator (staging release build). The first login attempt showed "No connection" while the emulator's network was dropping packets; the retry worked. Name "Trendsbird", organisation "Ziska-test", Supervisor with all four permissions, support "Not set by your office".

#### TC-STG-018 · Profile and tools on a phone · P1
1. Logged in with the test login, open Profile.
2. Open Check and scroll to the tools.

Expected: the server's name, role (Supervisor), organisation and email; the counts (0 for a new account); the four permissions; support "Not set by your office". Check offers the serial field, Scanner mode, Serial stack, Report incident and My reports.

- [x] Pass - [ ] Fail - [ ] Blocked — Notes: 2026-11-22, emulator (staging release build): all shown as listed; counts 0, 0, 0.

#### TC-STG-025 · One check of each result · P1
On the Check tab, check each serial in turn: `1`, `1000001`, `1234567890`.

Expected: `1` is genuine at its first check, and "Genuine, needs attention · Checked before" after that, with the check number and the last time in Bangladesh time; `1000001` is "Not in a batch"; `1234567890` is "Not found" with hints. Each shows the server's reference, and "Checking the item…" while it waits.

- [x] Pass - [ ] Fail - [ ] Blocked — Notes: 2026-11-22, emulator (staging release build). `1` was check 3 (the checker had checked it twice): checked before, last check 12:30 PM; all product fields from the server. `1000001` not in a batch; `1234567890` not found with hints for up to 19 digits.

#### TC-STG-030 · History on a phone · P1
1. Open History.
2. Tap **Valid**.
3. Tap **Sessions**.

Expected: the server's checks newest first, with the counts on the chips, the time in Bangladesh time and "Checked by …"; Valid shows only the genuine checks; Sessions shows the sessions of the last 7 days ("No sessions found." before any).

- [x] Pass - [ ] Fail - [ ] Blocked — Notes: 2026-11-22, emulator (staging release build): All 13, Valid 1, Warning 2; the newest "Today · 12:36 PM"; Valid showed the one genuine check (serial 1, 12:30 PM); no sessions yet.

#### TC-STG-007 · The staging app reaches the server · P1
1. Open the staging app: Login shows.
2. Tap **Sign up**, open the role list.

Expected: the roles come from the server: Distributor, Retail seller.

- [x] Pass - [ ] Fail - [ ] Blocked — Notes: 2026-11-22, emulator (Pixel 7, staging release build): Login shows; the role list shows Distributor and Retail seller.

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

#### TC-AUTH-114 · The server's login limits · P1
*Needs:* Staging; the backend test sheet (a blocked login); the mail page.

1. Log in with the blocked login and its right password.
2. Log in with a wrong password 5 times, then the right one; again 15 minutes later.
3. Log in; wait 6 minutes; enter the emailed code.
4. Log in; **Send the code again**; enter the first code, then the second.
5. Log in; enter 5 wrong codes, then the right one.

Expected: step 1 and the 5 wrong tries: "Email or password is incorrect."; the right password works only after 15 minutes. Step 3 and the first code in step 4: "The code is wrong or has expired…"; the second code logs in. Step 5: the right code is refused after 5 wrong ones; a new login gets a new code.

- [ ] Pass - [ ] Fail - [ ] Blocked — Notes:

#### TC-AUTH-095 · Not now on the test server · P1
**Blocked: needs `POST me/password/later` on the test server** (`docs/backend-requests/password-change-later.md`).
*Needs:* Staging; an account with a first password; real phone.

1. Log in with the first password (and the emailed code on a new phone).
2. On **Set a new password**, tap **Not now**.
3. Check an item on the Check tab.
4. Open **Profile**.
5. Log out, then log in again.

Expected: step 2: the Check tab opens. Step 3: the item is checked. Step 4: the reminder card with **Change password**. Step 5: the choice screen comes back.

- [ ] Pass - [ ] Fail - [x] Blocked — Notes: waiting for the backend route

### C2. Session (added 2026-11-14)

#### TC-SESS-021 · Back after 20 minutes in the background · P2
*Needs:* Staging; real phone.

Log in; put the app in the background 20 minutes; return and open History.

Expected: Data loads after a silent renewal; no Login screen.

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
3. Check one item on the Check tab; open **Profile** again.
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

## Built Since the Plan (2026-11-19)

The language switch and the offline banner waited for features that are now built ([remaining-work-test-plan.md §4](remaining-work-test-plan.md#4-item-2--blocked-features)). Their AUTO cases are automated (`flow/language_flow_test`, `flow/offline_banner_flow_test`, `l10n/arb_completeness_test`, the Bangla tours of `flow/device_a11y_flow_test` and the `bn_*` goldens). The phone cases:

| Case | Title | Run on | Spec |
|---|---|---|---|
| TC-PROF-032 | TalkBack in Bangla: swipe through Login, Check and a result | DEVICE | §14, §16 |
| TC-PROF-034 | A Bangla reader checks every screen and error, with [bangla-drafts-for-review.md](bangla-drafts-for-review.md) | DEVICE | §16 |
| TC-ERR-036 | Offline banner: airplane mode on any screen, then off; also listen to TalkBack read it | DEVICE | §14.2, §14 |

TC-PROF-006 and -018 are in Session A (A4).

## Summary

| Session | Pass | Fail | Blocked |
|---|---|---|---|
| A. Phone + mock | | | |
| B. Release build | | | |
| C. Test server | | | |
| D. Exploratory charters | Done: | Bugs: | |
