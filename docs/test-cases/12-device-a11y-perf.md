# NFR and UI: Device, Accessibility, Performance, Start Screen

> **2026-11-16 baseline:** [16-mobile-migration.md](16-mobile-migration.md) replaces conflicting cases for hidden-code input, bulk submission, everyone scope, retail administration, certificates, and email-only access requests. Historical IDs/counts below remain for traceability; do not execute retired cases as release requirements. Current architecture: ../../final.md.


| Field | Value |
|---|---|
| Spec | final.md §9.4, §14, §16 |
| API | — |
| Automated in | `test/flow/profile_a11y_flow_test.dart`, `splash_screen_test`, `app_logo_test` |
| Format | [Case format and type tags](README.md#3-case-format) |

## NFR — Device, Accessibility, Performance

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-NFR-001 | Small screen | COMPAT | P2 | DEVICE | ✋ | Real phone | All main screens on a ≤ 5.5″ phone | Nothing cut off; everything reachable by scrolling | §14 |
| TC-NFR-002 | Large text | A11Y | P2 | DEVICE | ✋ | Real phone | System font size largest | Text wraps; no overflow stripes | §14 |
| TC-NFR-003 | Screen reader | A11Y | P2 | DEVICE | ✋ | Real phone | TalkBack on Login, Check, Result | Every button and field read with a label | §14 |
| TC-NFR-004 | Contrast and tap targets | A11Y | P2 | AUTO | ✅ `flow/profile_a11y_flow_test` | Fake backend | Flutter accessibility guidelines on main screens | Text contrast and 48 px tap targets pass | §14 |
| TC-NFR-005 | Slow network | PERF | P2 | DEVICE | ✋ | Real phone | 3G or throttled network; lookup and bulk | Loading shown; no duplicate checks | §8.3 |
| TC-NFR-006 | Start time | PERF | P3 | DEVICE | ✋ | Real phone | Cold start, logged in | Home within 3 s on the main device | — |
| TC-NFR-007 | Long bulk list | PERF | P3 | DEVICE | ✋ | Real phone | 500 items in bulk; scroll; send | Smooth scrolling; results shown | §13.2 |
| TC-NFR-008 | Rotation and resume | COMPAT | P3 | DEVICE | ✋ | Real phone | Rotate, background and return on each screen | State kept; a missing `extra` returns to the parent screen | §9.5 |
| TC-NFR-009 | Oldest supported Android | COMPAT | P2 | DEVICE | ✋ | A phone on the build's minimum Android version (Android 8 if available) | Install; log in; look up; scan a QR; file a report with a photo; log out | Everything works as on the main phone | §14 |
| TC-NFR-010 | Newest Android | COMPAT | P2 | DEVICE | ✋ | A phone on the newest Android | Repeat NFR-009; look at the top and bottom edges of every main screen | Everything works; nothing hidden under the status bar or the navigation bar | §14 |
| TC-NFR-011 | Tablet width | COMPAT | P3 | AUTO + DEVICE | ✅ `flow/device_a11y_flow_test` | Fake backend at 1280 × 800; a tablet | Open Login, Check your email, Check, a result, Bulk lookup with results, History, Report incident, My reports, Retail users, Add retail user, Profile, Change password | No overflow; text readable; no button stretched across the whole screen | §14 |
| TC-NFR-012 | Split screen | COMPAT | P3 | DEVICE | ✋ | Real phone | Put the app in half of a split screen; use Check, History, Report incident | Everything reachable by scrolling; no overflow | §14 |
| TC-NFR-013 | Landscape on every main screen | COMPAT | P3 | AUTO | ✅ `flow/device_a11y_flow_test` | Fake backend at 844 × 390 | Open Login, Check your email, Check, a result, Bulk lookup with results, History, Report incident, My reports, Retail users, Add retail user, Profile, Change password | No overflow; every button reachable by scrolling | §14 |
| TC-NFR-014 | Font size 2× and 3× on every main screen | A11Y | P2 | AUTO | ✅ `flow/device_a11y_flow_test` | Fake backend; text scale 2.0, then 3.0 | Open Login, Check your email, Check, a result, Bulk lookup with results, History, Report incident, My reports, Retail users, Add retail user, Profile, Change password | No overflow; text wraps; every button reachable by scrolling | §14 |
| TC-NFR-015 | Smallest phone width | COMPAT | P2 | AUTO | ✅ `flow/device_a11y_flow_test` | Fake backend at 320 × 568 | Open Login, Check your email, Check, a result, Bulk lookup with results, History, Report incident, My reports, Retail users, Add retail user, Profile, Change password | No overflow; every button reachable by scrolling | §14 |
| TC-NFR-016 | Contrast and tap targets on every screen | A11Y | P2 | AUTO | ✅ `flow/device_a11y_flow_test` | Fake backend | Run the text contrast and tap target guidelines on Login, Check your email, Check, a result, Bulk lookup with results, History, Report incident, My reports, Retail users, Add retail user, Profile, Change password | All pass (NFR-004 covers the first screens) | §14 |
| TC-NFR-017 | Every control has a label | A11Y | P2 | AUTO | ✅ `flow/device_a11y_flow_test` | Fake backend | Run the labelled tap target guideline on Login, Check your email, Check, a result, Bulk lookup with results, History, Report incident, My reports, Retail users, Add retail user, Profile, Change password | Every button, icon button, and field has a label | §14 |
| TC-NFR-018 | TalkBack on every screen | A11Y | P2 | DEVICE | ✋ | Real phone; TalkBack on | Swipe through History, Bulk lookup, Report incident, My reports, Retail users, Profile; cause one error on each | Every item read with a clear name; errors read when they appear | §14 |
| TC-NFR-019 | Results are not told by colour alone | A11Y | P2 | AUTO | ✅ `flow/device_a11y_flow_test` | Fake backend | A result of each kind; History rows of each kind | Each has its own text and icon as well as its colour | §13.1.4, §14 |
| TC-NFR-020 | System dark mode | COMPAT | P3 | DEVICE | ✋ | Real phone | Turn on the phone's dark mode; open every main screen | Spec gap 15. Every text readable | §12.1 Local data, §14 |
| TC-NFR-021 | Process death on every screen | WORST | P2 | DEVICE | ✋ | Real phone; Developer options → "Don't keep activities" on | On each main screen, press Home and return | No crash; a screen whose `extra` is gone returns to its parent; no hidden code or password restored | §9.5 |
| TC-NFR-022 | Incoming call during a request | WORST | P3 | DEVICE | ✋ | Two phones | Call the test phone during a lookup, a bulk send, and a report filing; return after the call | One result, one bulk answer, one report; nothing lost or doubled | §8.3 |
| TC-NFR-023 | Battery and data saver | COMPAT | P3 | DEVICE | ✋ | Real phone | Turn on battery saver and data saver; log in, look up, open History | Everything works | §14 |
| TC-NFR-024 | 500 bulk results | PERF | P2 | STAGE + DEVICE | ✋ | Staging; real phone; 500 items from the test sheet | Send 500 items; scroll the results; open 10 rows; turn the switch on and off | No crash; smooth scrolling; rows open at once | §13.2 |
| TC-NFR-025 | One-hour session | PERF | P2 | STAGE + DEVICE | ✋ | Staging; real phone | Use the app for an hour (at least 4 renewals): lookups, History, reports | No Login screen; no slowdown; memory steady | §6.4 |
| TC-NFR-026 | Almost no free storage | WORST | P3 | DEVICE | ✋ | Real phone with under 100 MB free | Add a large photo to a report; file | No crash; the photo is sent, or a photo message is shown | §13.5.2 |
| TC-NFR-027 | Keyboard never hides the field | UI | P2 | DEVICE | ✋ | A small phone | Type in every field of Login, Set a new password, Report incident, Add retail user | The field in use and its button can be seen above the keyboard (by scrolling) | §14 |

UI cases (the start screen, the logo, components, screens): [15-ui.md](15-ui.md).

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 15 (dark mode).
