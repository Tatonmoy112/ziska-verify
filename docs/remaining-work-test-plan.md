# Track & Trace — Remaining Work Test Plan

> **2026-11-16 contract migration:** final.md v2.0 and [the migration acceptance cases](test-cases/16-mobile-migration.md) supersede conflicting requirements below. Hidden-code submission, the 500-item bulk endpoint, everyone scope, retail administration and certificates are retired. Old counts/status tables are historical, not current completion evidence. Use [the release backlog](release-backlog.md) for unrelated unfinished work.


| Field | Value |
|---|---|
| Version | 1.0 — 2026-11-14 |
| Parent plan | [`test-plan.md`](test-plan.md) (strategy, environments, roles, priorities, bug template, exit criteria) |
| Cases | [`test-cases/`](test-cases/README.md) |
| Status at start | 543 cases: 413 ✅ automated, 118 ✋ manual, 11 ⛔ blocked, 1 ⏳ to automate (SEC-024); 694 automated tests passing |

## 1. Purpose

Four items stand between the current state and a release-ready test record. This plan says, for each one, what is tested, what must exist before testing starts, which cases cover it, who owns it, and when it is closed.

| # | Item | Today | Owner |
|---|---|---|---|
| 1 | Dependency vulnerability scan (TC-SEC-024) | ⏳: CI has no scan | App |
| 2 | Three features in the spec that are not built: certificate, language switch, offline banner | 11 cases ⛔ | App, client (Bangla texts, certificate layout) |
| 3 | 19 open questions (spec gaps; 16–19 found while writing the blocked cases) | Listed in [README §7](test-cases/README.md#7-open-questions-spec-gaps); the app's current behaviour noted where tested | User, client, backend |
| 4 | Manual runs: sessions A–D of the [manual checklist](manual-test-checklist.md) | Not run | Tester |

## 2. Order

| Order | Work | Depends on | Closes |
|---|---|---|---|
| 1 | Add the dependency scan to CI | Nothing | Item 1 |
| 2 | Send the [decision sheet](decision-sheet.md) to the user, the client, and the backend team | Nothing | Starts item 3 |
| 3 | Session A (phone + mock) and Session B (release build) | A phone; a release build | Part of item 4 |
| 4 | Apply each decision as it arrives (spec, cases, tests) | Answers to item 3 | Item 3, question by question |
| 5 | Build each blocked feature; its cases turn ⛔ → ⏳ → ✅ / ✋ | The feature and, for the language switch, the Bangla texts | Item 2, feature by feature |
| 6 | Session C (test server) | The backend's test server and test sheet | Part of item 4 |
| 7 | Session D (exploratory charters) | Sessions A and C done | Item 4 |

## 3. Item 1 — Dependency Vulnerability Scan

**What and why.** Every package the app ships comes from `pubspec.lock`. A package with a published vulnerability is found before it reaches a release (`final.md` §12.1 Supply chain).

| Field | Value |
|---|---|
| Tool | OSV-Scanner (Google), reading the Pub ecosystem from `pubspec.lock` against the OSV database |
| Where | `.github/workflows/ci.yml`, on every push to `main` and every pull request |
| Entry criteria | `pubspec.lock` committed; CI running |
| Cases | TC-SEC-024 (the scan runs and a known-vulnerable package fails the build), TC-SEC-025 (`pubspec.lock` committed), TC-SEC-026 (an accepted finding is recorded with a reason and an end date, never skipped silently) |
| Proof | The scan run locally twice: on the real `pubspec.lock` (findings listed, if any), and on a scratch lockfile pinning a known-vulnerable Pub version (it must be reported) |
| Exit criteria | CI fails on a known vulnerability; the three cases ✅ |

A finding is handled in this order: upgrade the package; if no fixed version exists, record it in `osv-scanner.toml` with the advisory ID, the reason, and an end date, and add a row to [test-plan §12.1](test-plan.md#121-bugs-found-by-the-automated-flows).

## 4. Item 2 — Blocked Features

Each feature has its cases written now (⛔). When the feature is built, its cases turn ⏳, are automated where they run on the computer, and the device ones join the manual checklist.

### 4.1 Certificate

| Field | Value |
|---|---|
| Spec | `final.md` §13.3; §2.2 (`pdf`, `printing`, `share_plus`; a bundled TTF font, since the built-in PDF fonts have no Unicode) |
| Entry criteria | `CertificateComposer` (domain), `PdfService` and `ShareService` (core), the certificate route `/home/result/certificate`, the action on a valid or warning result |
| Test fakes to add with it | `FakePdfService` (keeps the composed text and fields), `FakeShareService` (records the file shared, can cancel), registered in `test/flow/harness.dart` like `FakeLauncher` |
| Cases | TC-LOOK-068 … -073 and the new LOOK cases in [04-lookup.md](test-cases/04-lookup.md#certificate) |
| Exit criteria | Every certificate case ✅ or ✋ passed; the client's layout (§20.3) checked against the PDF |

### 4.2 Language Switch (English / Bangla)

| Field | Value |
|---|---|
| Spec | `final.md` §13.8 (language on Profile), §16 (texts by `error.code`, Bangla digits, Bangladesh time), §12.1 (the choice is a stored preference) |
| Entry criteria | `PreferencesService` (core, `shared_preferences`), a locale state read by `App`, the switch on Profile, and **every** key of `app_en.arb` translated in `app_bn.arb` (today only `appTitle`; the client supplies the texts, §20.3) |
| Test fakes to add with it | `FakePreferencesService` (in-memory), passed to `startApp` so a restart keeps the choice |
| Cases | TC-PROF-006, -018, -019, TC-HIST-044, and the new PROF cases in [09-profile.md](test-cases/09-profile.md#language) |
| Exit criteria | ARB completeness test ✅; every language case ✅ or ✋ passed; a Bangla reader has checked the texts on a phone |

### 4.3 Offline Banner

| Field | Value |
|---|---|
| Spec | `final.md` §14.2 (`NetworkStatusBanner`, driven by `ConnectivityService`); §2.2 (`connectivity_plus`) |
| Entry criteria | `ConnectivityService` (core) with a status stream, `NetworkStatusBanner` (shared) shown above every screen |
| Test fakes to add with it | `FakeConnectivityService` with a stream the test sets online and offline |
| Cases | TC-ERR-036 and the new ERR cases in [10-errors-network.md](test-cases/10-errors-network.md#offline-banner) |
| Exit criteria | Every banner case ✅ or ✋ passed |

## 5. Item 3 — Open Questions

**What and why.** Nineteen behaviours are not defined by `final.md` or the backend documents. Their cases say "Spec gap n" instead of an expected result, so they cannot pass or fail.

| Field | Value |
|---|---|
| Tool | The [decision sheet](decision-sheet.md): for each question the app's behaviour today, the owner, two or three options, and the cases each option changes |
| Owners | Backend: 3, 4B (capitals), 6, 12B (`Retry-After` form), 19B (digits the server accepts). Client: 1, 2, 14, 15, 17. App owner: 4A (format), 5, 7, 8, 9, 10, 11, 12A, 13, 16, 18 (with the client), 19A |
| Entry criteria | The sheet sent to each owner |
| Per decision | A `final.md` Decision log row; the case's Expected written; its test added or changed; the question marked settled in README §7 |
| Exit criteria | No case says "Spec gap"; README §7 holds settled questions only |

## 6. Item 4 — Manual Runs

**What and why.** 118 cases need a person: a phone's camera, gallery, mail app, dialler, real screens and fonts, the release build, and the backend's test server.

| Session | Cases | Runs | Entry criteria | Time (about) |
|---|---|---|---|---|
| A. Phone + mock build | 63 | Now | A phone with USB debugging; the mock build installed; the QR sheet; the Postman mock reachable | 6 h, in two sittings |
| B. Release build | 4 | Now | A release APK built with `--obfuscate`; logcat; a decompiler | 1 h |
| C. Test server | 43 | When the backend sends the test server | The staging build; the backend's test sheet (10 logins, items for every result); its mail page; portal access | 5 h |
| D. Exploratory charters | 9 | After A, and again after C | The session's build; 45–60 min per charter | 8 h |

How a session is run, recorded, and retested is the run kit at the top of the [manual checklist](manual-test-checklist.md#run-kit).

**Exit criteria (with [test-plan §11.3](test-plan.md#113-exit-criteria-release)):** every P1 manual case passed on its target (MOCK, STAGE, or DEVICE); no open crash or wrong-data bug; every charter run at least once with its bugs filed.

## 7. Status

| Item | State |
|---|---|
| 1. Dependency scan | Done: CI job `dependency-scan` (OSV-Scanner v2.7.0); TC-SEC-024 … -026 ✅; 195 packages, no known vulnerability (2026-11-14) |
| 2. Blocked features | Case sets written: 52 ⛔ (certificate 21, language 20, offline banner 11), each with entry criteria and the test fakes it needs; features not built |
| 3. Open questions | [Decision sheet](decision-sheet.md) ready for 19 questions (backend 5, client 5, app owner 12); no answer yet |
| 4. Manual runs | [Run kit](manual-test-checklist.md#run-kit) ready (schedule, equipment, pre-flight, recording, triage, exit); sessions not started |
