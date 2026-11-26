# Track & Trace — Test Cases

> **2026-11-16 baseline:** [16-mobile-migration.md](16-mobile-migration.md) replaces conflicting cases for hidden-code input, bulk submission, everyone scope, retail administration, certificates, and email-only access requests. Historical IDs/counts below remain for traceability; do not execute retired cases as release requirements. Current architecture: ../../final.md.


This folder holds every test case of the app, one file per area. [`docs/test-plan.md`](../test-plan.md) is the master plan: strategy, environments, roles, priorities, exit criteria, traceability, and status.

## 1. Rules

- Expected results come only from `final.md` and the backend documents (`docs/protectb-api/`, `ProtectB-DOCS`). Figma is for look and feel only.
- A behaviour the spec does not define is marked **Spec gap** and listed in Section 7. No expected result is invented.
- IDs never change. A new case takes the next number of its area.
- One behaviour per case. The expected result is checkable: an exact text, a screen, or a request.

## 2. Files

Current migration acceptance: [16-mobile-migration.md](16-mobile-migration.md). The following inventory is the pre-migration snapshot.

| Area | File | Cases | P1 | P2 | P3 | ✅ Auto | ⏳ To automate | ✋ Manual | ⛔ Blocked |
|---|---|---|---|---|---|---|---|---|---|
| AUTH | [01-auth.md](01-auth.md) | 112 | 39 | 52 | 21 | 99 | 0 | 13 | 0 |
| SESS | [02-session.md](02-session.md) | 48 | 21 | 21 | 6 | 43 | 0 | 5 | 0 |
| ROLE and NAV | [03-roles-nav.md](03-roles-nav.md) | 47 | 17 | 24 | 6 | 44 | 0 | 3 | 0 |
| LOOK | [04-lookup.md](04-lookup.md) | 102 | 42 | 43 | 17 | 89 | 0 | 13 | 0 |
| BULK | [05-bulk.md](05-bulk.md) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| HIST | [06-history.md](06-history.md) | 60 | 18 | 32 | 10 | 57 | 0 | 3 | 0 |
| REP | [07-reports.md](07-reports.md) | 77 | 21 | 43 | 13 | 65 | 0 | 12 | 0 |
| RTL | [08-retail-users.md](08-retail-users.md) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| PROF | [09-profile.md](09-profile.md) | 53 | 3 | 31 | 19 | 46 | 0 | 7 | 0 |
| ERR | [10-errors-network.md](10-errors-network.md) | 57 | 11 | 32 | 14 | 52 | 0 | 5 | 0 |
| SEC | [11-security.md](11-security.md) | 39 | 21 | 16 | 2 | 32 | 0 | 7 | 0 |
| NFR | [12-device-a11y-perf.md](12-device-a11y-perf.md) | 27 | 0 | 17 | 10 | 8 | 0 | 19 | 0 |
| E2E | [13-e2e-journeys.md](13-e2e-journeys.md) | 16 | 7 | 9 | 0 | 10 | 0 | 6 | 0 |
| Exploratory | [14-exploratory-charters.md](14-exploratory-charters.md) | 9 | 0 | 6 | 3 | 0 | 0 | 9 | 0 |
| UI | [15-ui.md](15-ui.md) | 183 | 29 | 99 | 55 | 169 | 0 | 14 | 0 |
| MIG | [16-mobile-migration.md](16-mobile-migration.md) | 91 | 49 | 38 | 4 | 90 | 0 | 1 | 0 |
| STG | [17-test-server.md](17-test-server.md) | 58 | 44 | 11 | 3 | 47 | 0 | 11 | 0 |
| ARCH | [18-architecture.md](18-architecture.md) | 94 | 3 | 41 | 50 | 94 | 0 | 0 | 0 |
| **Total** | | **1073** | 325 | 515 | 233 | 945 | 0 | 128 | 0 |

## 3. Case Format

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|

| Column | Meaning |
|---|---|
| ID | `TC-<AREA>-NNN`; journeys `TC-E2E-NNN`; charters `CH-NN` |
| Type | One tag from Section 4 |
| Pri | P1 release blocker, P2 main feature, P3 look and small UX ([test-plan §5](../test-plan.md#5-priorities)) |
| Run on | AUTO, MOCK, STAGE, DEVICE ([test-plan §3](../test-plan.md#3-test-levels)) |
| Auto | ✅ automated (file named), ⏳ to automate, ✋ manual only, ⛔ Blocked (the feature is not built yet) |
| Pre-conditions / Data | Build, role (`docs/USER.md`, R1–R8), and the data the case needs. Without a role named, the mock's default R2. |
| Source | The `final.md` section (§) or the API guide rule the expected result comes from |

## 4. Type Tags

| Tag | Covers |
|---|---|
| POS | The main path works |
| NEG | Invalid input or a refused action is stopped with the right message |
| BVA | Boundary values: min − 1, min, max, max + 1 |
| EDGE | Unusual but valid data or use |
| WORST | Failure combinations: double taps, interruptions, app killed, races, broken answers |
| STATE | State transitions: session states, guard, flows that move between screens |
| NET | Network failures and server status codes |
| SEC | Security rules (storage, logs, routes, masking, transport) |
| A11Y | Accessibility: screen reader, font size, contrast, tap targets |
| PERF | Speed, memory, long lists, long sessions |
| COMPAT | Android versions, screen sizes, rotation, system settings |
| I18N | Languages, Bangla text and digits, time zones |
| UI | Layout and look |
| E2E | A complete journey across features |

## 5. Test Design Techniques

| Technique | Applied to |
|---|---|
| Equivalence partitioning and boundary values | Email, password (7 / 8 / 128 / 129), serial (1 / max / max + 1), hidden code and QR (length − 1 / length / length + 1), the 64-character limit, note (0 / 1 / 1 000 / 1 001), photo (1 MB ± 1 byte), bulk (0 / 1 / 500 / 501), search (100 / 101), retail user name (100 / 101) |
| Decision tables | Role × permission × tab, tile, and button; lookup result × reason; `email_sent` `true` / `false` / `null` |
| State transitions | Session states and the route guard (§6.7, §9.4); login → code → forced change → Home; report filed → photos → the 1-hour window; bulk editing → sending → results, `503`, `429` |
| Error guessing and worst case | Double taps, back press and app kill during a request, phone clock changes, empty or unreadable secure storage, malformed JSON, an HTML page with `200`, `Retry-After` missing, `0`, or very large |
| Network faults | Offline, a dropped connection mid-request, timeout, slow network, DNS and TLS failures, every status code on every screen |
| Pairwise | The 8 roles × features × entry points |
| Security checklist (OWASP MASVS areas) | Storage, logs, clipboard, routes, transport, masking, app-switcher, obfuscation |
| Non-functional | Accessibility, performance, compatibility, 1-hour soak |
| Journeys and exploratory charters | A day in the life per role; time-boxed sessions for what scripted cases miss |

## 6. Coverage Matrix

Each spec rule, the cases that cover it today, and what is missing. The step is the writing step of the plan that adds the missing cases.

| Area | Spec | Covered by | Missing | Step |
|---|---|---|---|---|
| Phone ID | §6.1 | SESS-001, AUTH-058, -059, SESS-032 | — | 2 ✓ |
| Login branching | §6.2 | AUTH-003, -005, -012, -034 … -036, -043, -044 | — | 2 ✓ |
| Login input | §6.2, §6.6 | AUTH-001, -002, -027 … -033 | — | 2 ✓ |
| Failed login and lockout | §6.2 | AUTH-011, -026, -037 … -042 | — | 2 ✓ |
| Emailed code | §6.2 | AUTH-004, -010, -045 … -055 | — | 2 ✓ |
| Resend code | §6.2 | AUTH-006 … -008, -056, -057, ERR-025 … -030 | — | 5 ✓ |
| Password rule | §6.6 | AUTH-015 … -018, -031, -065, -068 … -074 | — | 2 ✓ |
| Forced change | §6.6, §9.4 | AUTH-013, -014, -055, -060 … -062 | — | 2 ✓ |
| Voluntary change | §6.6, §13.8 | AUTH-019, -063, -064, -066, -067, PROF-005 | — | 2 ✓ |
| Forgotten password | §6.6 | AUTH-020, -021, -075 … -082 | — | 2 ✓ |
| Request access | §13.9 | AUTH-022 … -025, -083, -084 | — | 2 ✓ |
| Passes and renewal | §6.3, §6.4 | SESS-003, -004, -011 … -022, -031 | — | 2 ✓ |
| Session end | §6.5 | SESS-005 … -009, -027 … -030 | — | 2 ✓ |
| Start-up | §6.7, §9.4 | SESS-002, -010, -023 … -026, UI-001 … -005 | — | 2 ✓ |
| Permissions | §7 | ROLE-001 … -018, NAV-001 | — | 3 ✓ |
| `403 forbidden` reload | §7.2, §9.4 | NAV-007 (✋), ROLE-018 … -020 | — | 3 ✓ |
| Route guard and navigation | §9.3–9.5 | NAV-002 … -006, -008 … -015, ERR-006 | — | 3 ✓ |
| Input formats | §13.1.3 | LOOK-001, -020 … -025 | — | 3 ✓ |
| Input checks | §12.1, §13.1.2 | LOOK-002 … -005, -016, -026 … -042, SEC-016, -017 | — | 5 ✓ |
| Results and reasons | §13.1.4, §13.1.5 | LOOK-006 … -009, -043 … -055 | — | 3 ✓ |
| Result screen, loader, product picture | §12.1, §13.1.2, §13.1.4 | LOOK-089 … -117, SEC-027, -028, UI-160 … -167 | — | 12 ✓ |
| Lookup errors | §13.1.6 | LOOK-014, -056 … -061, ERR-003 | — | 3 ✓ |
| Camera | §13.1 | LOOK-015, -017 … -019, -062 … -067 | — | 3 ✓ |
| Certificate | §13.3 | LOOK-068 … -088 (⛔ not built; entry criteria in 04-lookup.md, Certificate) | — | 3 ✓ |
| Bulk building | §13.2 | BULK-002 … -006, -015 … -022 | — | 3 ✓ |
| Bulk sending and results | §13.2 | BULK-007 … -012, -023 … -037 | — | 3 ✓ |
| History filters | §13.4 | HIST-005, -009 … -011, -014 … -023, -042 | — | 4 ✓ |
| Paging | §10 | HIST-002 … -006, -013, -029 … -038, -041 | — | 4 ✓ |
| Item tracking and search | §13.4.1 | HIST-007, -008, -024 … -028, -043 | — | 4 ✓ |
| History rows and data | §13.4, §16, §10.6 | HIST-012, -039, -040, -044, -045, -046 | — | 4 ✓ |
| Filing a report | §13.5 | REP-001 … -004, -015, -018 … -028, -041, -048 | — | 4 ✓ |
| Photos | §13.5.1–13.5.3 | REP-005 … -012, -029 … -040, -049 | — | 4 ✓ |
| My reports | §13.5.4 | REP-016, -017, -042 … -047 | — | 4 ✓ |
| Retail user picker and list | §13.6 | REP-013, RTL-002, -037 … -044 | — | 4 ✓ |
| Add retail user | §13.6.1 | RTL-003 … -008, -012 … -031 | — | 4 ✓ |
| Email a new first password | §13.6 | RTL-009 … -011, -032 … -036 | — | 4 ✓ |
| Profile | §13.8 | PROF-001 … -019 (-018, -019 ⛔) | — | 4 ✓ |
| Errors | §14.2, §15.2, §15.4, §16 | ERR-001 … -024, -031 … -046 (-036 … -046: offline banner) and the request matrix in 10-errors-network.md | — | 5 ✓ |
| Rate limits | §15.5 | ERR-004, -013, -025 … -030, AUTH-007, BULK-012 | — | 5 ✓ |
| Security | §6.1, §6.3, §9.5, §12, §17 | SEC-001 … -024, LOOK-013, -016, NAV-009, -015 | — | 5 ✓ |
| Device and accessibility | §14 | NFR-001 … -027 | — | 6 ✓ |
| UI: tokens, components, screens, look | §14, §9.3.1, §13, §16 | UI-001 … -159 (15-ui.md) | — | UI ✓ |
| Language | §16 | AUTH-017, HIST-012, -018, -044 (⛔), PROF-006 (⛔), -008, -018 … -035 (⛔), ERR-019, CH-09 | — | 6 ✓ |
| Journeys and exploration | — | E2E-001 … -016, CH-01 … -09 | — | 6 ✓ |

## 7. Open Questions (Spec Gaps)

To settle them, fill in the [decision sheet](../decision-sheet.md): each question with the app's behaviour today, two or three options, and the cases each option changes.

| # | Question | Cases waiting | Owner |
|---|---|---|---|
| 1 | The certificate (§13.3). **Withdrawn:** the backend removed certificates (SRS v1.2); not built, not a release feature. | LOOK-068 … -088 (withdrawn) | — |
| 2 | The language switch (§13.8, §16). **Built 2026-11-19;** every text has a Bangla draft, waiting for the client's Bangla reader (§20.3, [bangla-drafts-for-review.md](../bangla-drafts-for-review.md)). | PROF-006 and I18N cases | Client (review) |
| 3 | Which time zone defines a day for History `from` / `to` (§16, §20.2). **Answered (guide §4.5, §5, e163a52): whole UTC days. Built 2026-11-23:** the app asks for the UTC days a Bangladesh day overlaps and keeps the rows inside it; counts from the kept rows (HIST-051 … -054). | HIST-010, -051 … -054 | — |
| 4 | Email input is not defined beyond "a valid email address": spaces around it, capitals, and which addresses the app refuses. **Fixed 2026-11-16 (decision 56): spaces around it removed; one `@` with text on both sides; no space or invisible character inside (AUTH-110).** **Answered (guide §3.1, e163a52): the backend matches an email in any case, spaces around it ignored.** | AUTH-027 … -030 | App, backend |
| 5 | A login or code answer with an unknown `data.status` has no defined display. App today: not logged in, the Login screen stays. | AUTH-036 | App |
| 6 | A new password equal to the current one: neither final.md nor the API guide said whether it is refused. **Answered (guide §3.6, §3.7, e163a52): allowed; if that changes, the answer will be 403 `policy_denied`, which the app shows with the rules.** | AUTH-063 | — |
| 7 | "Call the office" on a phone without a dialler has no message (Email has "No email app found. Write to …"). **Fixed 2026-11-16: "No phone app found. Call …" (AUTH-084).** | AUTH-084 | App |
| 8 | Secure storage that cannot be read at start: the screen is not defined (§6.1 only says the phone ID is never regenerated on an error). **Fixed 2026-11-16 (decision 56): the app opens on Login; the phone ID is not replaced and is read again at the next try (SESS-034).** | SESS-025, -034 | App |
| 9 | `GET me` without `permissions`, or with `permissions: null`: no defined display (the API guide always sends a list). App today (after the ROLE-012 fix): read as no permission, "No features yet". | ROLE-012 | App |
| 10 | A bulk send cut off by a lost connection. **Withdrawn:** the 500-item bulk lookup is removed; a stack of serials is one request (guide §4.7; TC-MIG cases). | — | — |
| 11 | Camera or gallery access denied while adding a report photo has no defined message (the scanner has "Camera access is off…"). | REP-040 | App |
| 12 | `429` without `Retry-After`, or with a date. **Decided 2026-11-17/18:** a `Retry-After` in seconds, or an HTTP date still to come, counts down; otherwise "Try again later." and a manual retry at once; no wait is made up (guide §1: "never by a number written into the app"). | ERR-025, -027, -048 | — |
| 13 | The offline banner (`NetworkStatusBanner`, `ConnectivityService`, §14.2). **Built 2026-11-19** (`NetworkStatusShell`). | ERR-036 … -046 | — |
| 14 | Screens showing a first password or a result are not hidden from the app switcher or screenshots; §12 does not ask for it. | SEC-012 | App, client |
| 15 | Dark mode: §12.1 stores a theme preference, but no dark theme is defined, and the app has none. | NFR-020 | App, client |
| 16 | A certificate that cannot be made. **Withdrawn** (no certificate). | — | — |
| 17 | The certificate's language. **Withdrawn** (no certificate). | — | — |
| 18 | The language at the first start: the phone's language when it is Bangla, or English always (§16 lists both languages, not the default). **App answer 2026-11-19:** English until chosen. | PROF-030 | Client |
| 19 | Bangla digits (১২৩) typed into a serial: refused, or read as 0–9 (the formats list Latin digits only). **App answer 2026-11-19:** read as 0–9. **The backend (guide §4, e163a52):** the server does not convert them, and such a value answers `not_found`. **Kept as the app's own choice (user decision 2026-11-23):** the server only ever receives 0–9. | PROF-035 | Client (19A) |
| 20 | `final.md` §14.1 names components that are built under other names or not built (15-ui.md, section G). | UI-159 | App |
| 21 | A chosen segment or chip has no token colour. **Decided 2026-11-15: navy fill, white text (`primary`, `onPrimary`), as the Figma History chips.** | UI-018 | App |

## 8. Progress

| Step | Content | State |
|---|---|---|
| 1 | Coverage matrix; existing cases moved here with Type and Pre-conditions | Done |
| 2 | AUTH and SESS: 80 new cases (AUTH-027 … -084, SESS-011 … -032) | Done |
| 3 | ROLE/NAV, LOOK, BULK: 97 new cases (ROLE-009 … -020, NAV-008 … -015, LOOK-020 … -073, BULK-015 … -037) | Done |
| 4 | HIST, REP, RTL, PROF: 110 new cases (HIST-015 … -046, REP-018 … -049, RTL-012 … -044, PROF-007 … -019) | Done |
| 5 | ERR/NET and SEC: 48 new cases (ERR-007 … -036 with the request matrix, SEC-007 … -024) | Done |
| 6 | Device, accessibility, performance, UI: 21 new cases (NFR-009 … -027, UI-011, -012); 16 journeys (E2E-001 … -016); 9 charters (CH-01 … -09); manual checklist: 75 new cases and Session D | Done |
| 7 | Automation, batch 1 (AUTH, SESS, ROLE, NAV, LOOK, BULK): 139 cases automated; 9 bugs found and fixed (test-plan §12.1) | Done |
| 8 | Automation, batch 2 (HIST, REP, RTL, PROF, ERR, SEC, NFR, UI, E2E): 147 cases automated, including the request matrix (19 requests × 7 codes); 10 more bugs found and fixed (test-plan §12.1). SEC-024 (dependency scan) stays ⏳: a CI tool, not `flutter test` | Done |
| 9 | Close-out: traceability (test-plan §9, §10 with the state of every row), open questions with the app's current behaviour, checklist consistency, final status | Done |
| 10 | Remaining work planned in [`../remaining-work-test-plan.md`](../remaining-work-test-plan.md): dependency scan in CI (SEC-024 … -026 ✅); 41 new blocked cases with entry criteria (52 ⛔); [decision sheet](../decision-sheet.md) for 19 questions; [run kit](../manual-test-checklist.md#run-kit) for sessions A–D | Done; the decisions, the three features, and the manual runs are open |
| 11 | UI: [15-ui.md](15-ui.md) written (159 cases, sections A–G); 145 automated in `test/ui/` (assertions run everywhere, CI too; 118 golden images on the development PC, each looked at); 14 by hand (the Figma comparisons and the splash on a phone); 27 bug entries found and fixed (test-plan §12.1, some covering several screens); decision sheet Q20 (updated) and Q21 (new) | Done |
| 12 | Result screen, loader, and product picture (final.md §13.1.2, §13.1.4, decisions 46–49): 39 new cases (LOOK-089 … -117, SEC-027, -028, UI-160 … -167) and 12 UI cases rewritten; all automated but TC-LOOK-116 (a real picture on a phone, checklist session C) | Done |
| 13 | The offline banner (`NetworkStatusBanner`, `ConnectivityService`, §14.2). **Built 2026-11-19** (`NetworkStatusShell`). | ERR-036 … -046 | — |
| 14 | Backend D56–D63 and D59 (SRS v1.2): the migration cases as TC-MIG-001 … -031 in the standard table; certificates (LOOK-068 … -088) and hidden-code entry (LOOK-004, -005, -013, -023, -033 … -036, -095) withdrawn, listed at the end of their files; BULK and RTL traceability replaced by TC-MIG cases; new AUTH-115 (D59; Not now kept, restored 2026-11-17) and PROF-041 (permissions on Profile); a blank result screen after losing `item:lookup` found and fixed (TC-MIG-018 flow) | Done |
