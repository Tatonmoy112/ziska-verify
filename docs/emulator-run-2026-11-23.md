# Emulator run on the real test server, read only (2026-11-23)

**Build:** the staging flavour (`config/staging.json`), installed on the `Pixel_7` emulator, against `https://testapp.protecb.com`, client `ziska-test`, with the user's own login.

**Rules of the run:**
- **Read only.** Nothing that records data is sent: no check, scan, stack, report, photo, access request, reset email or password change.
- **One area at a time.** The tester reports after each area and waits for the go-ahead.
- **Wrong logins use a made-up address,** so the user's account never gets a lockout count.
- **The emailed login code** is given by the user.
- **No credential, code or email address** is written here.

**Types:** **N** normal, **E** edge, **W** worst case.

**Results:** ✅ pass · ❌ fail (with what was seen) · ⛔ blocked (why) · — not run yet.

**Recorded on the server by mistake during this run:** one check, MA-2026-000046 (EMU-12). Nothing else.

The source column points to the backend's guide (`docs/protectb-api/app-api-guide.md`, the copy of ProtectB-DOCS e163a52) or to `final.md`.

---

## 1. Start and login

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-01 | N | Install and open the app (logged out) | Splash, then Login: "Login to Track & Trace", Email, Password, **Login securely**, **Forgot password?**, **Request access**; the copyright footer | final.md §13.9 | ✅ All parts shown, the version "0.1.0 (1)" in the footer |
| EMU-02 | E | Tap **Login securely** with both fields empty, then with an email that has no `@` | Field errors under the fields; nothing sent | guide §3.1; final.md §13.9 | ✅ "Enter a valid email address" and "Required"; with no `@` the email error stays; no request sent (app log) |
| EMU-03 | W | Log in with a made-up address at `example.com` and any password | "Email or password is incorrect." The same text as for a real address with a wrong password, so it never says whether an account exists | guide §3.1 | ✅ `POST auth/login` → 401; "Email or password is incorrect." with the reference |
| EMU-04 | N | Log in with the user's email (typed with capitals and a space before it) and password | Accepted: the email is matched in any case, spaces removed. This is a new phone, so the code screen shows ("We sent a code to …") | guide §3.1, §3.2 | ✅ `POST auth/login` → 200 with capitals and a leading space; "Check your email … We sent a 6-digit code to …"; **Send again** counts down from 60 s |
| EMU-05 | E | On the code screen, type 5 digits | **Verify** stays off until 6 digits | guide §3.2 | ✅ **Continue** off (not enabled) with 5 digits |
| EMU-06 | W | Type one wrong 6-digit code | "The code is wrong or has expired. Check the latest email, or send the code again."; the screen stays | guide §3.2 | ✅ `POST auth/verify-phone` → 401; "The code is wrong or has expired. Check the latest email, or send the code again." with the reference; the screen stays |
| EMU-07 | N | Type the emailed code (from the user) | Logged in: the Check tab with the bottom bar (Check, History, Profile, as the permissions allow) | guide §3.2, §3.8 | ✅ `verify-phone` → 200, `GET me` → 200, `GET formats` → 200; Android asked for the camera (allowed while using the app); the Check tab with Check, History, Profile; "Welcome back, Trendsbird", "Ziska-test"; the serial field says "Up to 19 digits" (the server's `max_digits`) |
| EMU-08 | W | Kill the app (`am force-stop`) and open it again | Still logged in, straight to the Check tab; no code asked | final.md §6 | ✅ After a force-stop: `GET me` → 200 and the Check tab; no code asked |

## 2. The Check tab (one check), nothing sent

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-09 | N | Look at the Check tab | The camera area (the emulator's camera), the serial field, and the tools the role allows (Scanner mode, Serial stack, Report incident); no "Request access" or admin tools | final.md §7, §13.1 | ✅ More: Scanner mode, Serial stack, Report incident, My reports; no admin tool |
| EMU-10 | E | Tap **Check** with an empty serial | **Check** is off while the field is empty; nothing sent | final.md §13.1 | ✅ **Check** is off (not enabled) while the field is empty, so nothing can be sent (stricter than the expected message, which never shows) |
| EMU-11 | E | Type `12AB34` key by key | The letters do not enter: the field shows `1234` (a typed character other than a digit, space or `-` is dropped; a paste is kept and refused by the input check instead) | guide §4 "Reading a serial"; `SerialInputFormatter` | ✅ Typed key by key, the field shows `1234` |
| EMU-12 | W | Type 41 digits | Refused before sending: "A serial has digits only, up to N digits." | guide §4.1 | ✅ Rerun with the 41 digits typed in pieces and read back first: "A serial has digits only, up to 19 digits." under the field; 0 `POST lookups`. (The first try recorded check MA-2026-000046 by mistake: adb typed only 11 digits, a valid serial, and the tester tapped **Check** without confirming) |
| EMU-13 | E | Type a serial in Bangla digits (`১২৩`) with a Bangla keyboard | Shown as `123`, the app's own choice; **not sent**. adb cannot type Bangla, so this may be ⛔ on the emulator (covered by TC-PROF-035 in the automated tests) | final.md §16 | ⛔ adb cannot type Bangla characters (`input text` throws). Covered by TC-PROF-035 in the automated tests; for the manual check with a Bangla keyboard |
| EMU-14 | N | Open the camera, wait 10 s, then switch to History and back | The camera runs only while the Check tab shows; no QR is read (the emulator shows no product QR) | final.md §13.1 | ✅ `dumpsys media.camera` active clients: Check tab 1, History 0, Profile 0, back on Check 1 |

## 3. Scanner mode, nothing scanned

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-15 | N | Tap **Scanner mode** | The camera with its frame, counters at 0, **Finish** off until a scan is answered | guide §4.3; final.md §13.2 | ✅ Camera on (1 active client), the frame, all five counters at 0, **Finish** greyed out; no request on opening |
| EMU-16 | E | Tap **Finish** while it is off | Nothing happens | final.md §13.2 | ✅ Screen unchanged; no request |
| EMU-17 | N | Press Android Back | Back on the Check tab at once. The app sends one `…/end` for the unused session, which records nothing | guide §4.4 | ✅ after the F-2 fix (rerun 16:36 and 16:37): Android Back and the back arrow both return to the Check tab with its camera running (1 active client, "Looking for a QR code · hold steady"); one `POST lookups/sessions/{id}/end` → **404**, shown to nobody (as documented: phase-8 doc, "404 unknown", since no scan ever named the session). First run: ⚠️ the Check tab showed "The camera could not start." (finding F-2) |
| EMU-18 | W | Open Scanner mode, put the app in the background for 5 s, then bring it back | The camera starts again; nothing is sent; no error | final.md §13.2 | ✅ Camera clients: 1 open, 0 in the background, 1 on return; counters still 0; no request |

## 4. Serial stack, nothing sent

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-19 | N | Open **Serial stack** | The hint "Type or paste up to 50 serials, separated by spaces, commas, or new lines. Repeated serials are checked once." | guide §4.7 | ✅ The hint exactly; the box empty; no count |
| EMU-20 | N | Type `1000001 1000002, 1000003` | "3 of 50 serials" | guide §4.7 | ✅ "3 of 50 serials" |
| EMU-21 | E | Type `1000001 1000001 0001000001` | The repeats counted once, leading zeros included (the server drops them): "1 of 50 serials · 2 repeated, sent once" | guide §4.1, §4.7 | ✅ "1 of 50 serials · 2 repeated, sent once" |
| EMU-22 | E | Type `1000001 12AB 1000003` and tap **Check serials** | "Serial 2 (12AB) is not a serial: digits only, up to N digits."; **nothing sent** | guide §4.7 | ✅ The box read back first (`1000001 12AB 1000003`); "Serial 2 (12AB) is not a serial: digits only, up to 19 digits."; no request |
| EMU-23 | W | Paste 51 different serials and tap **Check serials** | "Enter 1 to 50 different serials. Submit another stack for additional items."; **nothing sent** | guide §4.7 | ✅ Typed one serial at a time, then read back: exactly 1000001 … 1000051 (51 different). The count "51 of 50 serials" in red; on **Check serials**: "Enter 1 to 50 different serials. Submit another stack for additional items."; no request |
| EMU-24 | E | Tap **Clear** | The box is empty and the count gone | — | ✅ after the F-3 fix (rerun 16:56): with no error showing and after an error, **Clear** empties the box and takes away the count (and the error); no request. First run: ⚠️ after an error (EMU-22, -23): the box, the count and the error all go. With no error on screen (after EMU-20, -21, and a clean repeat with three serials): the box empties but **the count stays** ("3 of 50 serials") (finding F-3). Also: **Check serials** with the box empty: "Enter 1 to 50 different serials…"; no request |

## 5. History and Sessions

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-25 | N | Open **History** | The Checks/Sessions switch on Checks; this login has no checks: "No checks" with the empty text; no error | guide §5 | ✅ (expected text corrected: this login has **46 checks**, from the checker runs of 22 Nov and EMU-12's MA-2026-000046, not none). Checks/Sessions switch on Checks; All 46, Valid 1, Warning 12, Not found 20; newest first; no error. A Not-found row is titled with its reference, as the guide says `serial` is `null` for `not_found` (§5) |
| EMU-26 | N | Filters → choose today → **Apply** | The request asks `from` = yesterday and `to` = today (the UTC days a Bangladesh day overlaps), seen in the app log; still "No checks", with the "no match" text | guide §5; final.md §10 | ✅ by result (the request log has no query, on purpose: a search can hold a serial). Today only: 1 check (MA-2026-000046, Not found 1), **Reset** shown; yesterday only: 45 checks, today's left out. ⛔ the UTC-day shift (`from` = the day before) is not provable here: no check on the server falls between 00:00 and 06:00 Dhaka; covered by the automated tests |
| EMU-27 | E | Filters → a range across a month end (for example 30 Oct to 2 Nov) | `from` = 29 Oct, `to` = 2 Nov in the request; no error | guide §5 | ✅ 30 Oct to 2 Nov (typed in the picker's input mode, read back): "No checks / No check matches these filters.", counts 0, `GET checks → 200` |
| EMU-28 | E | Search `MA-2026`, then `0001000001`; and `১২৩` if a Bangla keyboard can type it (adb cannot) | No crash; "No checks" | guide §5 | ⚠️ A whole reference (`MA-2026-000046`, also in lower case): 1 check. `0001000001`: the 7 checks of 1000001 as a tracking log. **`MA-2026` (part of a reference): `GET checks → 400`, "Something went wrong. Try again."** (finding F-4). Bangla digits: ⛔ adb cannot type them (automated tests cover them) |
| EMU-29 | N | Switch to **Sessions** | "Showing the last 7 days"; none for this login | guide §4.5 | ✅ (expected text corrected: sessions exist from 22 Nov) "Showing the last 7 days"; All / Open / Ended; yesterday's Scanner mode and stacks, all Ended, with counts; today's empty Scanner mode sessions are not there (the server never saw them) |
| EMU-30 | E | Sessions → status **Ended** → a date | The request has `status=ended` and the UTC days; no crash | guide §4.5 | ✅ Ended, then 22 Nov to 22 Nov: the three sessions, **Clear** shown, `GET lookups/sessions → 200` each time. A session opened: its summary and its one check (MA-2026-000043, QR code, session 0BD992D6) match. The **emulator** crashed (exit 139) twice around Session checks (opening, then leaving); the app made no camera use there and every request answered 200; same as 2026-11-22 (see below) |
| EMU-31 | W | Pull to refresh 3 times quickly | One list, no doubled rows, no error | guide §5 | ✅ Three pulls in a row: one `GET checks → 200` (the others ignored while it ran); the list scrolled to the end: 46 references, MA-2026-000001 … 000046, each once |

## 6. Reports, nothing filed

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-32 | N | Open **Report incident** | "What did you find?", the 0/1000 counter, the note about warnings, **File report** off while the note is empty | guide §6.1 | ✅ The note about warnings; "What did you find?"; 0/1000; Link one of your checks, Choose a retail user (both optional); photos up to 3; **File report** off |
| EMU-33 | E | Type `  ` (spaces only) | The counter stays 0; **File report** stays off | guide §6.1 (the note is trimmed) | ✅ The field holds three spaces (read back); 0/1000; **File report** off |
| EMU-34 | E | Type an emoji and 3 letters | The counter says 4 (an emoji counts 1) | guide §1, §6.1 | ⛔ adb cannot type an emoji (automated tests cover it). With letters: `   abc` counts 3/1000 (trimmed); **File report** on, not tapped |
| EMU-35 | N | **Choose a retail user** → search `a` | The server's retail users (masked emails) or "none", from `GET retail-users`; read only | guide §7.1 | ✅ `GET retail-users → 200`, then `a`: `GET retail-users → 200`; this client has no retail users: "No retail user found". Also the check picker: the checks listed; `MA-2026`: no request, "Not a serial or a reference number" (the F-4 fix on the real server) |
| EMU-36 | W | Clear the note, press Back | Leaves at once (nothing waiting, nothing filed) | guide §6.2; audit 8.1 | ✅ Note empty: Back leaves at once. With `   abc` typed: Back also leaves at once, the note lost without asking (finding F-5). `POST incidents`: none in the whole run |
| EMU-37 | N | Open **My reports** | Report #5 (the length check of 2026-11-23) with its date; no photos | guide §6.3 | ✅ (expected text corrected: this login has 5 reports, #1–#4 from the checker on 22 Nov) `GET incidents → 200`; #5 … #1 newest first, each with its date, note, photo count and linked check |
| EMU-38 | E | Open report #5 | Its note, date, no retail user, no photos; Back returns | guide §6.3 | ⚠️ #5: the whole note (an emoji and 999 letters), its date, "No photos"; Back returns. #4: "1 photo" and MA-2026-000031, no image (by design: guide §6.3, the photos are for the office). **A short report opens in a narrow sheet**, only as wide as its text (finding F-6) |

## 7. Profile

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-39 | N | Open **Profile** | Name, email, role, organisation and support as the server sends them; **What you can do** lists the permissions by their SRS names; **no password reminder** (no "Not now") | guide §3.8; D65 | — |
| EMU-40 | N | Pull to refresh | The same, reloaded; no error | guide §3.8 | — |
| EMU-41 | N | **Language** → বাংলা | Every screen in Bangla at once: the tabs, Profile, the Check tab ("অ্যাকাউন্টের আবেদন" when logged out) | final.md §16 | — |
| EMU-42 | E | In Bangla, open History → Filters → a date | The calendar in Bangla; the dates sent stay `YYYY-MM-DD` in Latin digits | final.md §16 | — |
| EMU-43 | N | **Language** → English | English again; the choice is kept after a restart | final.md §16 | — |
| EMU-44 | N | **Change password** | "Choose a new password. Your other phones will be logged out."; the rule ticks (8 characters, a letter, a number); **Save** off until they are met; **not submitted** | guide §3.6 | — |
| EMU-45 | E | Type a new password of 7 letters, then 8 with no number | The ticks follow; **Save** stays off | guide §3.6 | — |
| EMU-46 | N | Back, then **Log out** → confirm | "Log out?", "This phone stays trusted, so the next login needs no emailed code."; Login shows | guide §3.5 | — |
| EMU-47 | N | Log in again with the user's email and password | Straight in, no code (the phone is trusted) | guide §3.2, §3.5 | — |

## 8. Logged out: Request access and Forgot password, nothing sent

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-48 | N | Log out; tap **Request access** | "Request access", "Ask for an account. Your office checks the request and emails you its answer."; Name, Role, Choose a password, Email, **Send code** | guide §3.9 | — |
| EMU-49 | N | Open the role list | The server's requestable roles (for example Distributor, Retail seller), from `GET roles/requestable` | guide §3.9 | — |
| EMU-50 | E | Fill the name with 100 letters, then type one more | The field stops at 100 | guide §3.9 | — |
| EMU-51 | E | A password of 7 characters | The rule ticks show what is missing; **Send code** off | guide §3.6, §3.9 | — |
| EMU-52 | W | Press Back after filling the form | Back to Login; **nothing sent** | — | — |
| EMU-53 | N | **Forgot password?** | The forgot screen with the email field; **not sent** | guide §3.7 | — |

## 9. Worst cases: offline, Back, large text, restart

| ID | Type | Steps | Expected | Source | Result |
|---|---|---|---|---|---|
| EMU-54 | W | Airplane mode on | "No internet connection. Checks need a connection." at the top of every screen | final.md §14.2 | — |
| EMU-55 | W | Offline: open History, pull to refresh | An error with **Try again**; no crash; nothing queued | guide §1 | — |
| EMU-56 | W | Airplane mode off; wait 20 s; **Try again** | The banner goes; History loads | final.md §14.2 | — |
| EMU-57 | W | Offline: type a serial and tap **Check** | "Unable to check. Check the connection and try again." (never sent: not the "may already be recorded" text) | final.md §13.10; audit 4.2 | — |
| EMU-58 | W | Android Back on every tab and pushed screen | Pushed screens close; on a tab Back leaves the app, never to a logged-out screen | final.md §9 | — |
| EMU-59 | W | Font size 1.3, then 2.0 (`settings put system font_scale`): Login, Check, History, Profile, Request access | No text cut off or overlapping; everything reachable by scrolling | final.md §14 | — |
| EMU-60 | W | Rotate to landscape on the Check tab and History | The app stays usable; no crash | final.md §14 | — |

---

## Findings

| # | Seen in | Finding | Severity |
|---|---|---|---|
| F-1 | EMU-13 | After a serial is refused ("A serial has digits only, up to 19 digits."), the error stays under the field when the field is emptied with the delete key; it goes at the next **Check** | Minor (the text is stale, not wrong). **Fixed:** the refused message goes as soon as the text changes (a failure after sending, such as "may already be recorded", stays until the next **Check**); test TC-LOOK-132; rerun on the emulator (17:10): 41 digits read back, refused with no request, the message gone at the first deleted digit and with the field emptied |
| F-2 | EMU-17 | After leaving Scanner mode (Android Back or the app's Back arrow), the Check tab shows **"The camera could not start."** It happens every time (seen twice). Switching to another tab and back brings the camera back. Cause: the Check tab starts its camera as soon as Scanner mode's route pops, while Scanner mode's camera still holds the one native camera, so the start is refused (`AlreadyStarted`); Scanner mode then disposes the native camera about 3 s later and nothing starts it again (mobile_scanner 7.5.0, one native camera per activity) | Major (QR checking on the main tab is gone until the user switches tabs). **Fixed:** Scanner mode now stops its camera before it leaves, by every way out; test TC-LOOK-131; rerun on the emulator passes (EMU-17), EMU-18 rerun still passes |
| F-3 | EMU-24 | On **Serial stack**, **Clear** empties the box but leaves the count ("3 of 50 serials") when no error is showing. The count is drawn from the box's text, but **Clear** redraws the screen only through the screen's state, and resetting a state with no error changes nothing, so nothing is redrawn (`serial_stack_screen.dart`, the Clear button). After an error it works, as the reset removes the error | Minor (stale count; an empty box is still refused, nothing is sent). **Fixed:** the count follows the box itself; test TC-MIG-073; rerun on the emulator passes (EMU-24) |
| F-4 | EMU-28 | History search sends any text. Part of a reference (`MA-2026`) is neither a serial nor a reference number, so the server answers 400 as the guide says (§5: `search` is "a serial or a reference number"; "a malformed value of any query parameter is 400"), and the app shows "Something went wrong. Try again." with a reference, as if the server had failed | Minor (the user cannot tell what to change; whole references and serials work). **Fixed:** a search that is not a whole serial (digits, Bangla digits read as 0–9, up to 64 characters) or a whole reference (`MA-<year>-<6+ digits>`, any case, sent in capitals) is not sent, by a search, a filter or a refresh; the list says "Not a serial or a reference number" and what to type; the same in the report's check picker. Tests TC-HIST-056, -057, TC-REP-067 (TC-HIST-026 changed: 200 digits are no longer sent). Rerun on the emulator (17:43): `MA-2026`: no request and the message; completed to `MA-2026-000046`: one `GET checks → 200`, the one check |
| F-5 | EMU-36 | **Report incident**: Back with a note typed (or photos added) leaves at once and drops them, without asking. The Back guard (audit 8.1) covers only a report being filed and its photos uploading. No document asks for a question here, so this is a suggestion: ask "Discard this report?" when something was typed or added | Minor (suggestion; an accidental Back loses a long note) |
| F-6 | EMU-38 | **My reports**: a report with a short note opens in a sheet only as wide as its text (centred, narrow); a long note fills the width. The sheet's column takes its widest line's width (`my_reports_screen.dart`, `_showReport`) | Minor (visual) |

## Observations (not app bugs)

- **The server's clock** seems about 1.5 minutes ahead: MA-2026-000046 shows 4:03 PM, but the app's log has its answer at 16:01:38 (the emulator's clock is within 20 s of the PC's). Worth a word to the backend; not the app.
- **The emulator crashes (exit 139) around Session checks** (twice on 22 Nov opening it; twice on 23 Nov, opening and leaving). Android shows no camera use, and every request answers 200: it looks like the emulator's software graphics (SwiftShader). Open Session checks on a real phone in the manual check.

## Not covered here (read only, or the test server lacks the data)

For the user's check by hand, on a phone or once the backend adds the test data:
- a real check, genuine and each warning;
- a QR scan, a lowercase QR included (the server has no QR values yet);
- Scanner mode with scans, Finish and its summary;
- a stack sent, and a lost stack answer;
- a report filed, with photos;
- a request access sent;
- a reset email;
- a forced password change (needs an account with "must change password" ticked);
- a 429 wait.
