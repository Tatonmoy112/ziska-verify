# Architecture — the layer rules

These cases check the layer rules of `final.md` §3, §4 and §11 on the imports of every hand-written file in `lib/`. They come from the production audit, step 2, finding P-1 ([docs/production-audit.md](../production-audit.md)).

TC-ARCH-001 … -011 run in `test/architecture/layer_rules_test.dart`, and TC-ARCH-012 … -014 (the verification use cases, P-3) in `test/features/verification/domain/verification_usecases_test.dart`, both in CI with the other tests. The checker is `test/architecture/layer_rules.dart`. It reads only text: no plugin and no network.

## The rules

| Rule | Never allowed |
|---|---|
| R1 | `core` imports a feature or `app` |
| R2 | `shared` imports a feature or `app` |
| R3 | a feature imports `app` |
| R4 | a feature imports another feature, except the app-wide profile entity and Cubit (§4) |
| R5 | `presentation` imports `data` |
| R6 | `domain` imports `data` or `presentation` |
| R7 | `data` imports `presentation` |
| R8 | `domain` reaches Flutter (`package:flutter`, `dart:ui`), directly or through any file it imports |
| R9 | `domain` reaches a package that is not pure Dart, directly or through any file it imports (allowed: `clock`, `collection`, `freezed_annotation`, `intl`, `json_annotation`, `meta`, `timezone`; and no `dart:io`, `dart:html`, `dart:ffi` …) |
| R10 | a plugin is imported outside `core`. A plugin is any package whose pubspec has `flutter: plugin:`, read from `.dart_tool/package_config.json`, so a new plugin is covered automatically |
| R11 | `get_it` is imported outside `app` |
| R12 | `dio` is imported outside `core`, a feature's `data` and `app` |
| R13 | a feature file is outside `data`, `domain` and `presentation` |
| R14 | `presentation` imports a repository interface: blocs reach data through use cases only (P-3) |

**A known break** that has a planned fix is listed in `knownBreaks` in the test, with its finding. A fixed one must be taken off the list (TC-ARCH-002). The list is empty: its one entry, P-2 (Profile → History's `CheckTotalsCubit`), was fixed on 2026-11-24.

## Cases

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-ARCH-001 | `lib/` keeps every layer rule | POS | P2 | AUTO | ✅ `layer_rules_test` | The real `lib/` | Check every import against R1–R14 | No break other than those in `knownBreaks` | final.md §3, §4, §11 |
| TC-ARCH-002 | Every known break still exists | STATE | P2 | AUTO | ✅ `layer_rules_test` | The real `lib/` | Check each entry of `knownBreaks` | Each one is still found; a fixed one fails the test until it is taken off the list | production audit P-1 |
| TC-ARCH-003 | The code and the plugins are read | POS | P2 | AUTO | ✅ `layer_rules_test` | The real `lib/` and package list | Read `lib/`; read the plugins | Over 150 files, `main.dart` among them; no `.g.dart` or `.freezed.dart`; `l10n/generated` read; the 9 plugins the app uses are found, and `dio`, `logger`, `intl`, `get_it` and `flutter_bloc` are not plugins | final.md §2 |
| TC-ARCH-004 | Generated code | EDGE | P3 | AUTO | ✅ `layer_rules_test` | A generated file that breaks R1 and imports Flutter; a domain file that imports it | Check | The generated file is not reported; the domain file is reported under R8 with the chain through the generated file | final.md §3 |
| TC-ARCH-005 | An export and a relative import count | EDGE | P3 | AUTO | ✅ `layer_rules_test` | A presentation file that exports a data file; another that imports it with `../../data/` | Check | Both reported under R5, with the resolved path | final.md §4 |
| TC-ARCH-006 | Comments, quotes and clauses | EDGE | P3 | AUTO | ✅ `layer_rules_test` | Imports in a `//` comment and in a `/* */` comment; a double-quoted import with a `show` over 3 lines; `as` and `hide` | Check | Commented-out imports are ignored; the real `hide` import of data is reported once | final.md §4 |
| TC-ARCH-007 | Allowed links are not reported | EDGE | P3 | AUTO | ✅ `layer_rules_test` | `app` with `get_it`, `dio`, data, presentation and a repository; a use case and data using a repository; a plugin in `core`; a feature using the profile entity and Cubit, its own domain and `shared`; a domain using `dart:async`, `meta`, `collection` and `core`; data with `dio` | Check | No break | final.md §4, §11 |
| TC-ARCH-008 | Each rule is reported | WORST | P3 | AUTO | ✅ `layer_rules_test` | One file breaking each of R1–R14 | Check each | Exactly that rule, with that file, and the text starts with the rule's ID; every rule has a case | production audit P-1 |
| TC-ARCH-009 | Several breaks in one file | WORST | P3 | AUTO | ✅ `layer_rules_test` | A domain file importing `get_it`, `dio`, a plugin, its own data and another feature's domain | Check | All 8 breaks: R4, R6, R9 ×3, R10, R11, R12 | production audit P-1 |
| TC-ARCH-010 | A chain and a cycle | WORST | P3 | AUTO | ✅ `layer_rules_test` | domain → core/a → core/b → Flutter, with core/b → core/a | Check | One R8 with the chain `core/a.dart -> core/b.dart -> package:flutter`; the cycle ends | final.md §3 |
| TC-ARCH-011 | Missing code or package list | WORST | P3 | AUTO | ✅ `layer_rules_test` | A folder and a package list that do not exist | Read them | A clear error: the folder's name; "run `flutter pub get`" | — |
| TC-ARCH-012 | Each verification use case makes its one call | POS | P2 | AUTO | ✅ `verification_usecases_test` | A mocked repository | Call `GetFormats`, `GetSession`, `ScanItem`, `CheckSerials`, `EndSession` and `GetSessions` | Each calls its repository method once and nothing else, and returns the repository's answer itself | final.md §4; guide §4.1, §4.3–4.5, §4.7 |
| TC-ARCH-013 | Arguments pass unchanged | EDGE | P3 | AUTO | ✅ `verification_usecases_test` | A QR value with spaces and lower case; a session ID in mixed case; serials with leading zeros and a repeat; a query with dates and the first page | Call the use cases | The same value, ID, list (same object, order kept), query and page reach the repository; no cursor made up | final.md §13.10 (the QR value sent as read) |
| TC-ARCH-014 | A failure comes back untouched | WORST | P2 | AUTO | ✅ `verification_usecases_test` | The repository answers a 429 (`Retry-After: 30`, `req-429`), then a lost answer | Call each use case | The same failure object: request reference and wait kept; one call, no retry | final.md §13.10 |
