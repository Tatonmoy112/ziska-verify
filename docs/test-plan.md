# Track & Trace — Test Plan

> **2026-11-16 contract migration:** final.md v2.0 and [the migration acceptance cases](test-cases/16-mobile-migration.md) supersede conflicting requirements below. Hidden-code submission, the 500-item bulk endpoint, everyone scope, retail administration and certificates are retired. Old counts/status tables are historical, not current completion evidence. Use [the release backlog](release-backlog.md) for unrelated unfinished work.


| Field | Value |
|---|---|
| App | Track & Trace (Ziska Pharma), Flutter, Android and iOS |
| Spec | `final.md` (v1.6 and later), Sections 6–18 |
| Backend contract | `docs/protectb-api/app-api-guide.md`, `app-build-guide.md`, Postman collection |
| Version | 2.0 — 2026-11-14: 543 cases in `docs/test-cases/` (positive, negative, boundary, edge, worst case, network, security, device, journeys, charters) |
| Status | `flutter analyze` clean; 1336 automated tests passing; 767 of 895 cases automated (Section 12) |

---

## 1. Purpose and Scope

This plan lists every test needed before the app is released, says **where** each one runs, and links each one to the rule it proves. The cases themselves are in [`docs/test-cases/`](test-cases/README.md), one file per area (Section 8). What is left before a release (the dependency scan, the blocked features, the open questions, and the manual runs) is planned in [`remaining-work-test-plan.md`](remaining-work-test-plan.md).

In scope: the 8 build steps of the backend build guide (login, session, lookup, bulk, history, reports and photos, retail users), navigation and permissions, errors, security rules, and the device checks a person must do.

Out of scope: the backend itself, the client portal, and the future features of `final.md` Section 20.4 (dashboard, product list, access request form).

## 2. Sources of Truth

Every test case names its source. Expected results come only from these:

| Source | Used for |
|---|---|
| `final.md` §18.3 Acceptance Checks | The main list; every row is covered (Section 10) |
| `final.md` §6–13 | Screen behaviour, rules, messages |
| `app-build-guide.md` §5 | The backend team's checklist per build step |
| `app-api-guide.md` | Status codes, error codes, permissions |
| `docs/USER.md` | The 8 role profiles for permission tests |
| `figma/` | Look and feel only (colours, layout). Never behaviour. |

## 3. Test Levels

Each test case has one **Run on** value:

| Run on | Meaning | Who |
|---|---|---|
| **AUTO** | An automated test in `test/` (unit, widget, BLoC, or API contract against the Postman examples). Runs with `flutter test`. | Claude / CI |
| **FLOW** | An automated full-app flow on the computer (`test/flow/`): the real router, screens, and BLoCs against a fake backend answering with the Postman examples. Runs with `flutter test`. | Claude / CI |
| **MOCK** | By hand, `mock` build against the Postman mock server | Tester |
| **STAGE** | By hand, `staging` build against the backend test server (not available yet) | Tester |
| **DEVICE** | By hand, on a real phone (camera, gallery, mail app, dialler, sizes, performance) | Tester |

Automation status in the **Auto** column:

| Mark | Meaning |
|---|---|
| ✅ | Covered by an existing automated test (file named) |
| ⏳ | To be automated (steps 7 and 8) |
| ✋ | Manual only |
| ⛔ | Blocked: the feature is not built yet |

## 4. Environments and Test Data

### 4.1 Mock (available now)

| Item | Value |
|---|---|
| Build | `flutter run --flavor mock --dart-define-from-file=config/mock.json` |
| Server | Postman mock `https://6df9cc6e-…mock.pstmn.io`, client `ziska` |
| Login | Any email and password; any 6-digit code |

Default answers of the mock (checked 2026-11-11). The app cannot ask for another example, so mock tests use these:

| Route | Answer | Effect on testing |
|---|---|---|
| `POST auth/login` | `code_sent` | Every login goes through the code screen |
| `GET me` | Field inspector (`history:own`, `incident:report`, `item:bulk_lookup`, `item:lookup`) | Other roles: replace the body of the Postman example "200 The profile" with a profile from `docs/USER.md` |
| `GET formats` | Hidden code 12 digits; serial up to 19 digits; QR 12 of `A–Z 0–9` | |
| `POST lookups` | `valid`, `MA-2026-000123` | Other results are tested by AUTO and STAGE |
| `POST lookups/bulk` | Always 3 results | Send exactly 3 items; any other count must show an error (count mismatch) |
| `GET checks` | Empty page | History shows its empty state |
| `GET incidents` | One report (#1042) | |
| `GET retail-users` | One retail user (Rahim Store) | |
| `GET retail-roles` | Empty | Add retail user shows "no retail role yet" |

### 4.2 Staging (when the backend sends it)

| Item | Value |
|---|---|
| Build | `flutter run --flavor staging --dart-define-from-file=config/staging.json` |
| Server | Backend test server, client `demo-pharma` |
| Data | The backend's test sheet: 10 logins (inspectors, supervisors, a trainee, retail users, one with a forced password change, one blocked), a serial, QR value, and hidden code for every result and reason; the mail page for emailed codes |
| Rule | Never test on a live client: every check is kept for good |

### 4.3 Devices

| Device | Purpose |
|---|---|
| A recent Android phone (Android 13+) | Main device: camera, gallery, mail, dialler |
| An older or small Android phone (Android 8–10, ≤ 5.5″) | Layout, HEIC fallback, performance |
| An iPhone | When the iOS flavors are set up on a Mac (`final.md` 20.3) |

## 5. Priorities

| Priority | Meaning | When run |
|---|---|---|
| **P1** | Release blocker: login and session, lookup results, permissions, never-duplicate rules, security | Every build |
| **P2** | Main features: bulk, history, reports, retail users, profile | Before each release |
| **P3** | Look and feel, small UX details | Before each release |

## 6. Test Case Format

Each case has: **ID**, **Title**, **Type**, **Priority**, **Run on**, **Auto**, **Pre-conditions / Data**, **Steps**, **Expected**, **Source**. The type tags and the test design techniques are in [`test-cases/README.md`](test-cases/README.md). Rules:

- One behaviour per case.
- The expected result is checkable: an exact text, a screen, or a request.
- Steps can be followed by someone who did not write them.
- A case that needs a specific role names it (Section 4.1, `docs/USER.md`).

## 7. Roles

| Role (`docs/USER.md`) | Permissions | Expected |
|---|---|---|
| R1 Supervisor | all six | Tabs Check, History, Profile; tiles Bulk lookup, Report incident, My reports, Retail users; History filter "Everyone's checks" |
| R2 Field inspector | `history:own`, `incident:report`, `item:bulk_lookup`, `item:lookup` | Tabs Check, History, Profile; tiles Bulk lookup, Report incident, My reports; no "Everyone's checks" |
| R3 Head office auditor | `history:all`, `history:own`, `item:lookup` | Tabs Check, History, Profile; no MORE section; "Everyone's checks"; no Report button on a result |
| R4 Senior seller | `history:own`, `item:bulk_lookup`, `item:lookup` | Tabs Check, History, Profile; tile Bulk lookup only; History shows own checks only |
| R5 Retail seller | `history:own`, `item:lookup` (the portal's default for a retail role, backend D53) | Tabs Check, History, Profile; lookup form and Scan QR only; History shows own checks only |
| R6 Incident reporter | `incident:report` | Tabs Check, Profile; no lookup form; tiles Report incident, My reports |
| R7 Trainee | none | Tabs Check, Profile; "No features yet" |
| R8 Retail seller, history off | `item:lookup` | Tabs Check, Profile; lookup form and Scan QR only |

---

## 8. Test Cases

The cases live in one file per area in [`docs/test-cases/`](test-cases/README.md). The README there has the case format, the type tags, the test design techniques, the coverage matrix, and the open questions.

| Area | File | Cases | P1 | P2 | P3 | ✅ Auto | ⏳ To automate | ✋ Manual | ⛔ Blocked |
|---|---|---|---|---|---|---|---|---|---|
| AUTH | [01-auth.md](test-cases/01-auth.md) | 112 | 39 | 52 | 21 | 99 | 0 | 13 | 0 |
| SESS | [02-session.md](test-cases/02-session.md) | 48 | 21 | 21 | 6 | 43 | 0 | 5 | 0 |
| ROLE and NAV | [03-roles-nav.md](test-cases/03-roles-nav.md) | 47 | 17 | 24 | 6 | 44 | 0 | 3 | 0 |
| LOOK | [04-lookup.md](test-cases/04-lookup.md) | 102 | 42 | 43 | 17 | 89 | 0 | 13 | 0 |
| BULK | [05-bulk.md](test-cases/05-bulk.md) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| HIST | [06-history.md](test-cases/06-history.md) | 57 | 17 | 30 | 10 | 54 | 0 | 3 | 0 |
| REP | [07-reports.md](test-cases/07-reports.md) | 74 | 19 | 42 | 13 | 62 | 0 | 12 | 0 |
| RTL | [08-retail-users.md](test-cases/08-retail-users.md) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| PROF | [09-profile.md](test-cases/09-profile.md) | 53 | 3 | 31 | 19 | 46 | 0 | 7 | 0 |
| ERR | [10-errors-network.md](test-cases/10-errors-network.md) | 54 | 10 | 30 | 14 | 49 | 0 | 5 | 0 |
| SEC | [11-security.md](test-cases/11-security.md) | 39 | 21 | 16 | 2 | 32 | 0 | 7 | 0 |
| NFR | [12-device-a11y-perf.md](test-cases/12-device-a11y-perf.md) | 27 | 0 | 17 | 10 | 8 | 0 | 19 | 0 |
| E2E | [13-e2e-journeys.md](test-cases/13-e2e-journeys.md) | 16 | 7 | 9 | 0 | 10 | 0 | 6 | 0 |
| Exploratory | [14-exploratory-charters.md](test-cases/14-exploratory-charters.md) | 9 | 0 | 6 | 3 | 0 | 0 | 9 | 0 |
| UI | [15-ui.md](test-cases/15-ui.md) | 183 | 29 | 99 | 55 | 169 | 0 | 14 | 0 |
| MIG | [16-mobile-migration.md](test-cases/16-mobile-migration.md) | 76 | 46 | 28 | 2 | 75 | 0 | 1 | 0 |
| STG | [17-test-server.md](test-cases/17-test-server.md) | 58 | 44 | 11 | 3 | 47 | 0 | 11 | 0 |
| ARCH | [18-architecture.md](test-cases/18-architecture.md) | 34 | 0 | 11 | 23 | 34 | 0 | 0 | 0 |
| **Total** | | **989** | 315 | 470 | 204 | 861 | 0 | 128 | 0 |

---

## 9. Build Guide Checklist Coverage

The backend team's checklist (`app-build-guide.md` §5) mapped to test cases. **State**: how many cases, and how many are automated (✅), manual (✋), blocked (⛔), or still to automate (⏳).

| Build step | Checklist items | Test cases | State |
|---|---|---|---|
| 1. API client and secure store | Phone ID once; typed errors; one renewal; 429 `Retry-After` | SESS-001, -004, -011 … -022, -025, ERR-001, -004, -007 … -030 | 41: 38 ✅, 3 ✋ |
| 2. Logging in | New phone → code; resend once a minute; forced change → Home; same failed message; forgot password; password rule ticks; weak passwords stopped | AUTH-001 … -084 | 84: 65 ✅, 19 ✋ |
| 3. Staying logged in | Silent renewal; logout keeps phone ID; `401` → Login; Home shows only permitted features | SESS-002 … -010, -023 … -032, ROLE-001 … -020, NAV-001 … -015 | 54: 46 ✅, 8 ✋ |
| 4. Single lookup | QR sends value after `/q/`; formats checked; every result and reason; `app_preparing`; hidden without `item:lookup` | LOOK-001 … -003, -006 … -012, -014 … -022, -024 … -032, -037 … -067, SEC-016, -017 | 61: 49 ✅, 12 ✋ |
| 4a. Result screen and product picture | One screen for every path; the loader after 300 ms with honest steps; what was entered (hidden code masked) and hints from the formats; the picture card in each state; HTTPS only, no access pass, memory only | LOOK-089 … -094, -096 … -117, SEC-027, -028 | 30: 29 ✅, 1 ✋ |
| 5. Checking many items | Scanner sessions: a UUID, QR only, each scan answered at once, `repeat`, `session_full`/`session_ended` start a new session and resend, `session_not_yours`, back ends without waiting, crash resume; every read kept and answered live; Finish shows every scan together; serial stacks of 1 to 50, all or nothing, a `503` sent again once; hidden without `item:bulk_lookup` | MIG-012 … -028, -046 … -049, -053 … -056 | 25: 24 ✅, 1 ✋ |
| 6. History | Filters; paging until `null`; totals; `scope=all` only with `history:all` | HIST-001 … -046 | 46: 43 ✅, 3 ✋ |
| 7. Reports and photos | `check_ref` from a result; photos shrunk, raw, retried, never duplicated; never re-filed; My reports | REP-001 … -049 | 49: 37 ✅, 12 ✋ |
| 8. Retail users | Picker only: search by name or whole email, masked emails, cursor paging; hidden without `incident:report`; adding withdrawn (404) | REP-013, MIG-002, -030 | 3: 3 ✅ |

## 10. Traceability: final.md §18.3 Acceptance Checks

Every acceptance check has test cases. Two need a real phone or the test server by nature: photo metadata (REP-010) and Bangladesh time on a phone set to another zone (HIST-012). Certificates are withdrawn by the backend (SRS v1.2 FR-LKP-13).

| Acceptance check | Test cases | State |
|---|---|---|
| Phone ID | SESS-001, -025, -032, AUTH-058, -059, SESS-034 | 6: 3 ✅, 3 ✋ |
| Errors | ERR-001, -002, -007 … -024 | 20: 20 ✅ |
| Renewal | SESS-003, -004, -011 … -022, SESS-033, -036 … -038, -040, -041 | 20: 18 ✅, 2 ✋ |
| Rate limits | ERR-004, -013, -025 … -030, AUTH-007, -039, -054, -077, LOOK-057, HIST-032, REP-026, AUTH-105 | 16: 15 ✅, 1 ✋ |
| Login | AUTH-003, -005, -012, -034 … -036, -044, -097 … -101, -103 … -105, -108, -110, -113, -114, AUTH-106 | 20: 18 ✅, 2 ✋ |
| Resend code | AUTH-006 … -008, -056, -057 | 5: 5 ✅ |
| Forced change | AUTH-013, -014, -055, -060 … -062, E2E-014, AUTH-102, AUTH-115, AUTH-092, -095 ("Not now" withdrawn 2026-11-23, D65: AUTH-085 … -091, -093, -094, -096, -107) | 11: 11 ✅ |
| Failed login | AUTH-011, -037, -038 | 3: 3 ✅ |
| Forgotten password | AUTH-020, -021, -075 … -082, -109, -111, -112 | 13: 11 ✅, 2 ✋ |
| Session | SESS-003, -005, -007, -008, -011, -023, -026 … -030, SESS-035, -039 | 13: 11 ✅, 2 ✋ |
| Permissions | ROLE-001 … -020, NAV-001, E2E-001 … -008 | 29: 28 ✅, 1 ✋ |
| Navigation | NAV-002, -003, -008 … -015, AUTH-013, -061, SEC-004 | 13: 12 ✅, 1 ✋ |
| Lookup | LOOK-006 … -009, -015, -020 … -022, -024 … -032, -037 … -061 | 42: 39 ✅, 3 ✋ |
| Bulk | MIG-012 … -028, -031 | 18: 18 ✅ |
| History | HIST-002, -003, -009, -014 … -046 | 36: 35 ✅, 1 ✋ |
| Pagination | HIST-003 … -006, -029 … -035, REP-042 | 12: 12 ✅ |
| Reports | REP-001, -004 … -006, -018 … -049 | 36: 28 ✅, 8 ✋ |
| Photo metadata | REP-010 | 1: 0 ✅, 1 ✋ |
| Transport | SEC-001, -018, ERR-033 | 3: 2 ✅, 1 ✋ |
| Time display | HIST-012, -018, LOOK-052 | 3: 2 ✅, 1 ✋ |
| Request access | AUTH-022 … -025, -083, -084 | 6: 4 ✅, 2 ✋ |
| Retail users | REP-013, MIG-030 | 2: 2 ✅ |
| Password rule | AUTH-015, -016, -031, -065, -068 … -074 | 11: 11 ✅ |

Not an acceptance check, but tracked the same way: the start screen and logo (`final.md` §9.4, §14) are covered by UI-001 … -012; device, accessibility, and performance by NFR-001 … -027; journeys by E2E-001 … -016; exploration by CH-01 … -09.

## 11. Running and Reporting

### 11.1 Run Log

One line per run:

| Date | Build (version + flavor) | Environment | Device | Cases run | Pass | Fail | Blocked | Tester |
|---|---|---|---|---|---|---|---|---|
| 2026-11-16 | 0.1.0 mock, release (`--obfuscate` for SEC-006) and debug (SEC-010) | Postman mock | Android emulator, Pixel 7 image, software graphics — not a real phone: Session A and B still run on one | 11: AUTH-023, -024, -043, -059, SESS-032, SEC-006, -008, -010, -011, -012, -022, and the login journey (login → code → Not now → Profile reminder) | 10 | 0 | 1 (SEC-010: listed after a login and a lookup — only the encrypted passes and phone ID on disk; History and a bulk not reached, the emulator crashed twice on the debug build, never on release) | Claude Code (agent) |
| 2026-11-17 | 0.1.0 mock, automated only | Fake backend on the Postman snapshot of 2026-11-16 (665f3c0); the mock server still answers the old collection (`roles/requestable`, `lookups/sessions`, `lookups/serials`: not found), so no device run of the new screens | Computer (`flutter test`) | 1004 tests; doc checks | 1004 | 0 | Device and staging run sheet of `16-mobile-migration.md`: not run | Claude Code (agent) |
| 2026-11-17 | 0.1.0 mock, release, `DEMO_PASSWORD_LATER: true` (fresh install) | Postman mock + the Not now demo | Android emulator, Pixel 7 image, software graphics | Not now journey: TC-AUTH-085 (Not now → Check), -087 (Profile reminder; a change from it clears it), -086 (the next login asks again), -092 (Log out on the choice screen), -091 (restart: opens on Check, because the mock's `GET me` answers `must_change_password: false`; the forced case is covered by the automated test), TC-SEC-008 (no password, code or pass in the release log) | 6 | 0 | 0 (no app ANR or crash; 3 ANRs of the emulator's launcher before the install) | Claude Code (agent) |

### 11.2 Bug Report

| Field | Content |
|---|---|
| Title | Short, the behaviour that is wrong |
| Test case | ID and title |
| Build and environment | Version, flavor, server, device, Android version |
| Role | Which profile (Section 7) |
| Steps | Numbered, from the test case |
| Expected | From the test case |
| Actual | What happened |
| Evidence | Screenshot or screen recording; the time it happened |
| Reference | The "Reference: …" from the error screen (the backend team finds the request with it) |
| Severity | Crash / Wrong data / Blocks a flow / Minor / Cosmetic |

### 11.3 Exit Criteria (Release)

- `flutter analyze` clean and every AUTO test passing.
- All **P1** cases pass on MOCK, STAGE, and DEVICE.
- No open crash or wrong-data bug.
- Every row of Section 10 has a passed test case.

## 12. Status (2026-11-22)

| Check | Result |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | 1336 passed, 0 failed (133 of them goldens; CI runs the other 1203) |
| Covered by automated tests (✅) | 767 of 895 (886 test cases and 9 exploratory charters) |
| To be automated (⏳) | 0 |
| Dependency scan (CI, TC-SEC-024) | OSV-Scanner v2.7.0 on `pubspec.lock`: 195 packages, no known vulnerability (2026-11-14) |
| Manual only (✋) | 128: 119 cases (12 of them Figma comparisons) and 9 charters, all in `manual-test-checklist.md` (sessions A–D) |
| Blocked (⛔) | 0. TC-AUTH-095 is now the backend's two cases, automated ("Not now" withdrawn, D65, 2026-11-23). The offline banner and the language switch are built (2026-11-19); their cases are automated or in the checklist. Certificates are withdrawn by the backend (SRS v1.2), not blocked |

Remaining work (the dependency scan, the blocked features, the open questions, the manual runs): [`remaining-work-test-plan.md`](remaining-work-test-plan.md).

### 12.1 Bugs Found by the Automated Flows

| Test | Bug | Fix |
|---|---|---|
| TC-REP-017 | My reports: the number and time row overflowed on a phone-width screen | The time takes the remaining width; meta texts end with "…" |
| TC-RTL-009 | Retail users: the "Email a new first password" menu item overflowed by 137 px | The label wraps inside the menu |
| TC-NFR-004 | Muted grey text (Login footer, hints, captions) had a contrast of 2.56:1, below the WCAG 4.5:1 minimum | `AppColors.textMuted` darkened from #94A3B8 to #64748B (4.76:1) |
| TC-UI-001 | Splash: logo, title, and progress sat on the left while loading (the content shrank to the logo's width; only the full-width Try again button hid it in the error state) | The content always spans the full width |
| TC-UI-004 | Splash: overflowed on a small phone at font size 2× (no scrolling) | The splash scrolls when the content does not fit; at least the screen height otherwise |
| TC-UI-008 | Logo: "ZISKA" wrapped and the mark grew with the phone's font size | The logo ignores the system font size (drawn at its set width) |
| TC-AUTH-039, -054, -056, -057 | Login, Forgot password, Reset password, and Change password showed a `429` as a fixed "Try again in N s." that never counted down and did not stop a new request (§6.2, §15.4) | `FailureBanner` counts down from `Retry-After`; `SubmitState.retryAt` blocks a new request until 0; time read through `clock` |
| TC-AUTH-066 (PROF-015) | After a voluntary password change the app stayed on the change screen and loaded the profile again | The session state is announced only when it changes (a forced change), so the router no longer rebuilds the screens |
| TC-AUTH-072 | Password fields removed a pasted tab without telling, so another password than the one pasted was set (§6.6: refused) | Control characters are kept and the rule refuses them; a line break never enters a one-line field (Flutter removes it) |
| TC-SESS-024 | With only one of the two passes stored, requests went out without a pass and the start screen stayed on "Something went wrong" | A login needs both passes: with one left, both are cleared and Login shows; the phone stays trusted |
| TC-SESS-030 | Log out could be confirmed twice while the first logout ran: two `auth/logout` | One logout at a time; a second press joins the first |
| TC-ROLE-018, -020 | A `403 forbidden` never reloaded the profile (§7.2), and a screen whose permission was gone stayed open (go_router checks only the base location) | `ForbiddenSignal` → background profile reload (no splash, one at a time); every pushed screen is checked against the guard and the official goes Home |
| TC-ROLE-012 | `GET me` with `permissions: null` crashed the profile parsing | Missing or `null` reads as no permission ("No features yet") |
| TC-LOOK-030 | A serial pasted with a letter (`10O0001`) was silently changed to `100001`, then looked up and recorded (§13.1.2: refused) | `SerialInputFormatter`: a typed letter does not enter; a paste stays as it is and is refused with its message |
| TC-LOOK-050 | A long product or generic name overflowed the result screen by 2 809 px | Detail values take the remaining width and wrap |
| TC-HIST-032 | A failed next page (a `429`, or offline) was asked for again on every rebuild: 28 requests in 15 s (§10.6: never retried in a loop) | A next page is asked for by itself only after a page that arrived; a failed one waits for Retry |
| TC-HIST-032, TC-ERR-013 | History, My reports, Retail users, and the picker showed a `429` as a fixed "Try again in N s." and Retry sent at once | `PaginatedState.retryAt`: the shared list counts down and Retry sends nothing before 0 |
| TC-REP-026 | Report incident showed a fixed `429` text and filed again on the next press | Countdown from `Retry-After`; no filing before it ends |
| TC-RTL-023, -034 | Add retail user and "Email a new first password": a fixed `429` text and a new request on the next press | Countdown (in the form, and in the message); no request before it ends |
| TC-ERR-007, -016 | "Email a new first password" errors showed no reference (§14.1: every error) | The message carries "Reference: …" |
| TC-ERR-028, -026 | A lookup was sent again during a `429` countdown, and the countdown stayed on screen as "0 s" | No lookup before the countdown ends; the message goes at 0 |
| TC-ERR-017 | An unknown `error.code` showed the general text, hiding the server message (§16: the fallback for an unknown code) | The server message for unknown codes only; known codes keep the app text |
| TC-SEC-014 | The hidden code field let the keyboard learn and suggest hidden codes (§12.1: never stored) | `AppTextField.secret`: no suggestions on the hidden code field (Check and Bulk lookup) |
| TC-NFR-014, -015 | Layout overflow on a 320 px phone and at font size 2× and 3×: password rules, result details, Profile rows, the role list (136 px), the Login divider, the Bulk lookup counter (136 px), Clear list, and the way label | The texts wrap or scale down; the role list takes the field width |
| TC-NFR-017 | The role list on Add retail user had no name for a screen reader | It shows and reads "Role" until a role is chosen |
| TC-UI-020, -021 | Small text under the WCAG 4.5:1 minimum: success (#16A34A, 3.30:1) and warning (#D97706, 3.19:1) in check badges, reasons, password rules, and the email notes; danger on the error banner (#DC2626, 4.41:1); muted grey on the grey screens (#64748B, 4.40:1); the Sign up panel title and icons (#0EA5E9, 2.42:1, under 3:1 for icons too) | Tokens darkened: `success` #15803D, `warning` #B45309, `danger` #C81E1E, `textMuted` #5F6E84, `infoAccent` #0369A1 (each 4.5:1 or more on white, the grey screens, and its own background) |
| TC-UI-013 | Colours outside the tokens: the result card and the filed report backgrounds (`Color(0xFFF0FDF4)`, `Color(0xFFFFFBEB)`), the Profile role badge text (`Color(0xFFBBF7D0)`), and `Colors.black` on the scanner, Bulk lookup, and the photo overlay | New tokens `successBackground`, `warningBackground`, `successOnDark`, `scrim` |
| TC-UI-014, -015 | Sizes outside the tokens: the Profile name (`fontSize: 18`), the Log out button in its dialog (`TextStyle`), the button icon gap (10), and the input padding (16 × 18, off the 4-point scale) | New type token `heading`; the dialog button uses the button style; the gap is `AppSpacing.xs`; the input padding is `AppSpacing.md` |
| TC-UI-029 | A disabled outlined button kept its full navy border, so it looked almost enabled | The border fades with the fill (45 %) |
| TC-UI-036 | A disabled field drew its text in the normal dark colour, with a border darker than an enabled field's: it looked editable (Bulk lookup while sending) | Disabled text `textMuted`, fill `surfaceMuted`, the plain `border` (theme `disabledBorder`) |
| TC-UI-063 | Item details, Profile rows, and the Bulk lookup counter row: the right-hand value (or Clear list) stopped half-way across, not at the edge (a `Flexible` label left its unused share at the end of the row) | The rows put the unused space between the two sides (`spaceBetween`): values end at the card edge |
| TC-UI-062 | The copy buttons for the reference and the first password were named "Copied" before anything was copied (their tooltip and screen-reader label) | "Copy reference number" and "Copy password" |
| TC-UI-072, -018 | Sheets, dialogs, menus, and switch tracks were tinted lavender, and list text, outlines, and dividers used colours Material made from the navy, not the tokens | The colour scheme maps those roles to tokens (`background`, `textStrong`, `textBody`, `textMuted`, `border`); the chosen-segment colour waits for decision sheet Q21 |
| TC-UI-075 | Login: the "NO ACCOUNT?" divider's right line stopped near the middle (the label kept 3/5 of the row) | The label is as wide as its text (at most 60 %); the two lines share the rest equally |
| TC-UI-082, -018 | Snack bars used a dark grey Material made from the navy, not a token | Snack bars: `textStrong` surface, `onPrimary` text |
| TC-UI-103, -030 | A loading button (Login, Check, Bulk lookup) showed only a spinner, and a screen reader heard an unnamed button; "Checking 3 items…" was never shown or read | The spinner carries the button's label for screen readers |
| TC-UI-102, -103 | Bulk lookup: each "Added …" snack bar covered **Check N items** for 4 s; a tap there hit the snack bar | The send bar is the screen's bottom bar, so snack bars float above it |
| TC-UI-095 | Scanner with camera access off: the viewfinder frame and the "Point your camera…" hint were drawn over the message and **Open settings** | Both are hidden once the camera fails |
| TC-UI-130, -063 | Profile cut the email to "official@example.…" with room to spare, and item details wrapped values at half the width (the label side kept half the row) | `LabelValueRow` (shared): the label takes its own width, at most 40 %; the value gets the rest |
| TC-UI-168 | The tonal button (**Back to Check** on a not-found result, **Back to login** on Sign up) was invisible on the grey screens: its fill was the screen colour and it had no border, so it read as a text link (seen on the emulator) | The tonal button is white with a light border (`border`, 1.5) and navy text, visible on grey and white screens |
| TC-AUTH-087 | After a voluntary change from the Profile reminder, the change screen came back: the router ran its guard on every profile change, and the profile refresh right after the pop rebuilt the popped page (seen in the flow test) | The router runs its guard again only when the session, a loaded profile, or its permissions change (decision 55) |
| TC-AUTH-097 | A login, code, change, or Not now answer of the wrong shape threw a TypeError that `guard()` did not catch: the spinner turned forever | `guard()` turns parser errors into "Something went wrong" |
| TC-SESS-033 | A renewal answer with a pass of the wrong type threw past both catches | Checked by type; not renewed, the login kept |
| TC-SESS-034 | Unreadable secure storage at start stopped the app before its first screen; a failed phone ID stayed failed | `prepareSession()`: the app opens on Login; the phone ID is asked for again |
| TC-SESS-035 | A storage write or delete that failed escaped as a platform error; a failed delete kept the app from Login | Writes give an app error; `end()` reaches Login whatever the delete does |
| TC-SESS-036 | Logging out while a renewal ran: the renewal wrote both passes back after the logout deleted them | A login generation; a renewal finishing after its login ended stores nothing |
| TC-SESS-037 | A late 401 for a request of the previous login ended the new login | A 401 for an older pass is retried with the current pass, never ends the login |
| TC-AUTH-098 | Back to login while the code was checked: the late 200 still logged in | A code answer for a challenge given up is dropped |
| TC-AUTH-099 | Bangla and Arabic-Indic digits were dropped from the code: a Bangla keyboard could not enter it | The code field reads them as 0–9 |
| TC-AUTH-100 | A pasted "Your code for 2026: 123456" sent 202612 | A paste with one 6-digit group uses that group |
| TC-AUTH-101 | The password field counted 128 graphemes, the rule 128 code points: Bangla conjuncts passed the field and failed the rule | The field counts code points |
| TC-AUTH-102 | A change answer still forcing a change was ignored | The session stays in the forced change |
| TC-SEC-011 | `android:allowBackup` was not set: Android could back up the login session | `allowBackup="false"` with backup and data-extraction rules |
| TC-AUTH-084 | **Call the office** without a phone app showed the email message | "No phone app found. Call …" |
| TC-AUTH-025 | A second **Email the office** without a mail app showed nothing (the same result twice) | The result goes back to idle first |
| TC-AUTH-110 | Any text with an `@` passed the email check (a full-width ＠ did not, but zero-width characters did) | One `@` with text on both sides, no spaces or invisible characters |
| TC-UI-118, -121, -018 | **New report** and **Add retail user** (floating buttons) were lavender, a colour Material made from the navy | Floating main actions use `primary` and `onPrimary`, like every main button |
| TC-UI-134 | History, My reports, Retail users, and the list errors sat 16 px from the sides; every other screen 24 px (`AppSpacing.screen`) | All at `AppSpacing.screen` |
| TC-UI-135 | Log out and Choose dates were plain Material buttons outside `AppButton` | `AppButton` gained the danger variant (Log out, as in the Figma); Choose dates is an outlined `AppButton` |
| TC-UI-136 | Three copies of a search field (History, Retail users, the picker) and the report note were built from bare `TextField`s | `AppSearchField` (named in §14.1) for the searches; the note is an `AppTextField` (several lines, a counter) |
| TC-UI-138, -139 | The scanner drew its own error box; "No item needs attention" was a plain line | The scanner shows `ErrorBanner`; the bulk results show `AppEmptyState` |
| TC-UI-140 | App-bar and dialog titles used Material's default styles, not the type tokens ("one title style per level") | Both use `headline` (merged over the theme, so the font family stays) |
| TC-UI-141 | The History clear-search button, the report link remove buttons, and the photo remove button had no label for a screen reader | "Clear the search" and "Remove" |
| TC-UI-142 | At font size 2×: "Verify pr…" (the old label), Profile values cut ("Ziska Pha…", "official@exam…"), labels and the product name broken mid-word, the History search hint cut | Check's buttons stack; `LabelValueRow` puts the label above a value that does not fit; the product name goes under the picture; hints wrap (up to 3 lines) |
| TC-UI-143 | Long hints ended with "…" (Bulk lookup's hidden code, Add retail user's email and first password) | Hints wrap |
| Step 6 note | Login's Email field had a person icon; Forgot password and Add retail user an envelope | The envelope on Login too |

### 12.2 How to Run

```sh
flutter test                 # everything
flutter test test/flow       # the full-app flows only
```

The flow harness (`test/flow/harness.dart`) starts the real app with `startApp(tester, profile: Roles.supervisor, overrides: {...})`; any route's answer can be overridden, for example `offline()` for no connection.
