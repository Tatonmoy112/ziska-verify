# Mobile contract migration report

Baseline: ProtectB app API guide 2026-11-16, D56-D63. App architecture: ../final.md v2.0. The source guides and Postman collection are copied into protectb-api/; the two environment files already matched.

Implemented: serial/QR-only lookup; own-only history with legacy hidden-code records; scanner sessions and scoped UUID recovery; serial stacks capped at 50 without splitting; public access-request form; picker-only retail users; independent permissions and result routing; typed session conflicts and server-derived cooldowns; Printing/sharing packages are removed; PDF/image remain development-only for the QR-sheet utility.

The former architecture is preserved under archive/. Existing auth and storage/backup work is retained, Not now included (restored 2026-11-17: the backend team will build `me/password/later`). Unrelated release completion is in release-backlog.md.

## Data-flow audit (2026-11-17)

Every route was checked against the contract copy at backend commit ebff1d9 (request fields, query parameters, answer fields, error codes, screen fields): no field mismatch. The fixes are the error, wait and counting rules of final.md §13.10; four open points are in backend-requests/data-flow-questions.md (final.md §20.1).

| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 1104 passed, 0 failed (129 goldens; the two changed report images looked at) |
| `flutter test --exclude-tags golden` (CI) | 975 passed, 0 failed |
| Doc checks (counts, traceability, links) | Clean: 794 cases, 651 automated; 129 links resolve |

Decided on the way: a 429 without a usable `Retry-After` gets no made-up wait (guide §1, build guide §5), so the planned 60 s fallback was not built; the password rule keeps the guide's labels ("8 characters or more"), the field already stops at 128.

## The Postman mock (2026-11-18)

The mock build needs a mock made from the 2026-11-17 collection (the current one serves the older copy: Request access, Scanner mode, stacks and Sessions answer "not found"). Steps: `docs/postman-mock-setup.md`, with `tool/postman/ziska-mock.postman_environment.json`. The mock-only `PostmanMockRouting` names each route's success example, echoes session IDs, numbers photos, and replaces the examples' passes (they contain "…", which no HTTP header may carry) (TC-MIG-050). `flutter test`: 1126 passed (CI 996). Every route probed on the new mock answers its example. Emulator run (mock release build, Pixel_7): login with the code, the Check tab's camera, a typed serial ("needs attention"), a serial stack of three, Scanner mode, History and Sessions all work. A QR scan on the emulator needs a QR in its virtual scene; that flow is covered by the automated tests.

## The Check tab is the camera (2026-11-18)

A scan is the trigger: the Check tab opens on a live camera, and a read QR is sent at once as `POST lookups {"way":"qr","value":…}` (guide §4.2) with no button; the result opens and back returns to the running camera. The serial is typed under the camera. The camera runs only while the tab is seen (TC-LOOK-124…127). The separate Scan QR code screen is removed.

| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 1116 passed, 0 failed (130 goldens; the Check tab at 1× and 2×, camera refused, looked at) |
| `flutter test --exclude-tags golden` (CI) | 986 passed, 0 failed |
| Doc checks | Clean: 803 cases, 660 automated |

## No "verify" in the app (2026-11-18)

The backend's SRS v1.2 calls an official's look-up a **check**; "verification" is only the consumer's public website (D8). The app's 16 texts that said "verify" now say check: the **Check** tab, **Check authenticity** with its **Check** button, **Checking…**, **Check result**, **Code from the email** and **Continue** on the code screens, **Product Authenticity Check** and **TRACK · TRACE · CHECK** (final.md §13.10). Code and route names are unchanged. A guard test (TC-UI-183) fails if a text says "verify" again.

| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 1112 passed, 0 failed (130 goldens regenerated; Check tab, code screen, Login, Splash, result looked at) |
| `flutter test --exclude-tags golden` (CI) | 982 passed, 0 failed |
| Doc checks | Clean: 799 cases, 656 automated |

## Scanner mode live (2026-11-18)

Scanner mode keeps every QR the camera reads: reads during a check wait in line and go 500 ms apart; each answer shows on the camera in its colour, with a vibration (final.md §13.10, TC-MIG-046…049). The bug it fixes: the camera reports each code once (`DetectionSpeed.noDuplicates`), and a read during a check was dropped, so that product was never checked.

| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 1110 passed, 0 failed (130 goldens; the scanner-mode images looked at) |
| `flutter test --exclude-tags golden` (CI) | 980 passed, 0 failed |
| Doc checks | Clean: 798 cases, 655 automated |

## Validation (migration run)

Run 2026-11-17 (Flutter 3.41.9, Windows):

| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 1048 passed, 0 failed (129 goldens, each changed image looked at) |
| `flutter test --exclude-tags golden` (CI) | 919 passed, 0 failed |
| Doc checks (counts, traceability, checklist, links) | Clean: 755 cases, 612 automated |
| Grep of `lib` for withdrawn routes, fields and permissions | None; `hidden_code` only as a History filter value for old checks |

Changes in this run, on top of the migration:
- **Not now kept** (decision 2026-11-17): the backend team will build `me/password/later`; until then the mock build plays it (`DEMO_PASSWORD_LATER: true`). Without `password_change_skippable` the forced change offers Save and Log out only (TC-AUTH-115).
- **History** has a Checks / Sessions switch; one session's checks open above it (TC-MIG-031).
- **Profile** lists the permissions by their SRS names (TC-PROF-041, SRS FR-ACC-15).
- **Request access** uses the navy header and labels above the fields, like the other sign-in screens.
- **A bug found and fixed:** losing `item:lookup` while a single result was open left a blank page on top (the pushed page's `extra` is not in go_router's match list, so the profile listener could not see it); the page now goes to Verify itself.
- The stale goldens of the migrated screens were regenerated after looking at them.

**Not run:** the mock server (`config/mock.json`) still serves the old Postman collection: `roles/requestable`, `lookups/sessions` and `lookups/serials` answer "mock request not found", and `formats` still lists `hidden_code`. Request access, scanner mode, serial stacks and the sessions list therefore cannot be tried on a phone with the mock build until the collection of 2026-11-16 is imported into that mock. Device/staging cases remain unrun. No production server, database or portal was changed. No real account request or check was sent.

The initial SDK ownership/telemetry problem was resolved for this session using process-local Git safe-directory configuration and a temporary APPDATA directory; no global Git configuration was changed.
