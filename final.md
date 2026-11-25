# Track & Trace - Flutter Application Architecture

| Field | Value |
|---|---|
| Version | 2.0 |
| Date | 2026-11-16 |
| Platforms | Flutter Android and iOS |
| Backend | ProtectB mobile-app-api, `/v1/clients/{slug}/` |
| Contract baseline | ProtectB mobile guide dated 2026-11-16; mobile decisions D1-D63, including D56 and D58-D63 |
| Evidence | `docs/protectb-api/` is the app-owned contract snapshot, copied from `ProtectB-DOCS-initial` at commit 4ec8318 (2026-11-18) and rechecked against `ProtectB-DOCS` at 5d96a91 (2026-11-22: `mobileApp/` unchanged); its Postman examples drive contract and flow tests |

The previous architecture is preserved in `docs/archive/app-architecture-1.6.md` for traceability. Its hidden-code submission, bulk endpoint, everyone scope, retail administration, and certificate requirements are superseded.

## 1. Product and scope

Track & Trace serves a single client's officials. The backend decides authenticity and records checks. Consumers use the verification website, whose QR links the app parses without opening them.

- One client per build; the HTTPS API host and client slug are configuration.
- Authenticated single lookup by serial or QR, continuous QR scanner sessions, serial stacks, own history and session browsing, incident reports and photos, retail-user picking, and profile/support.
- Public access requests are applications for office approval; they never log the applicant in.
- Online only. No offline submission queue, local product database, or persisted scan results.
- No hidden-code entry, everyone's history, retail-user administration, certificates, GPS, barcodes, or consumer verification requests.
- Unrelated release work is tracked in `docs/release-backlog.md`.

## 2. Toolchain

Flutter 3.41.9 and Dart 3.11.5 are pinned through `.fvmrc`; Android uses JDK 17. Use the locked dependency versions. Existing packages provide BLoC/Cubit, Dio, go_router, GetIt, Freezed/JSON generation, secure storage, QR scanning, photos, and localization. Every plugin remains behind a core wrapper: the interface in `core/services/<area>/<name>_service.dart`, the plugin in its own file named after its class (for example `mobile_scanner_service.dart`), which only `app/bootstrap.dart` imports (2026-11-24, production audit P-7; checked by rules R15 and R16).

PDF and image dependencies are development-only for the manual QR-sheet generator. Printing and certificate sharing are not application dependencies.

## 3. Engineering principles

Use small constructor-injected interfaces and feature-first layering. Domain entities, validators, and repository interfaces are pure Dart. Repositories return `Result<T>` and typed `Failure` objects rather than throwing through presentation. Unknown response fields are ignored; unknown verification outcomes are never shown as valid.

Generated JSON, Freezed, and localization files are regenerated and committed, never edited by hand.

## 4. Architecture and data flow

Presentation calls domain use cases only, never a repository interface (2026-11-24, production audit P-3). Data implements those interfaces, calls API services, parses DTOs, and maps them into domain entities. API services use the shared API client and its envelope/error handling.

- `lib/app/` owns composition, session/profile wiring, route guards, and cross-feature callbacks.
- `lib/features/authentication/` owns login/password and public access requests.
- `lib/features/verification/` owns serial/QR lookup, active scanner sessions, serial stacks, and session summaries/listing.
- `lib/features/history/` owns paginated check records and filters, including session-filtered checks.
- Incidents own report filing/uploading; retail users expose only the incident picker.
- `lib/core/` contains infrastructure and plugin interfaces, and never imports a feature. Its folders depend on one another one way only: `network` (with the Dio session service) uses `services/session`'s interface, never the reverse (2026-11-24, production audit P-8; rule R17).
- Features do not import one another's internals. The app-wide profile entity/Cubit is the existing exception.
- Every API service is an `abstract interface class …ApiService` with a `Dio…` implementation (P-14). These rules are checked on every import by `test/architecture/layer_rules_test.dart` (R1–R19, `docs/test-cases/18-architecture.md`).
- The router maps history records into verification-owned recovered row summaries through a callback. It also composes report/picker and session/history navigation.

## 5. Core and data services

| Service | Responsibility |
|---|---|
| ApiClient / DioFactory | HTTPS requests, documented parameters, public-request auth bypass, success envelopes, typed errors, raw image bodies |
| AuthInterceptor | Bearer authorization, coordinated renewal, bounded expired-token retry, forced-change signal, forbidden-profile refresh |
| SessionService | Login state, secure token pair, renewal, logout and stale-response protection |
| PhoneIdService | One cryptographically random installation ID, retained on logout |
| SecureStorageService | Keychain/Keystore for phone ID, passes, and scoped active scan UUIDs |
| ActiveScanStore | UUID v4 creation and recovery-ID storage under a client/official-specific key |
| ScannerService | QR-only preview, lifecycle, torch, permission/plugin errors |
| PhotoService | Pick, normalize orientation, remove metadata, resize/compress, enforce upload size |
| PictureImages | Product pictures over HTTPS without API authorization; memory only |
| LauncherService / AppInfoService | Mail/dialler and app version |
| LoggerService | Method/path/status/request reference only; secret redaction |

Access requests have a separate repository and use cases. Verification DTOs distinguish ordinary lookup results, scan metadata, session summaries, and serial-tagged stack results. History DTOs retain `session_id` and the legacy history way.

## 6. Authentication and session

Preserve the existing four routing states: unauthenticated, awaiting new-phone code, password-change required, and authenticated.

- Generate the phone ID once from 32 secure random bytes, base64url without padding (43 characters). Never rotate it on logout or an error.
- Decide login by `data.status`: `code_sent` retains the challenge in memory; `logged_in` stores both passes before proceeding.
- Login failures use the same message for wrong email/password, blocked and locked accounts.
- A trusted phone skips the emailed code. A new phone sends the same installation ID with login and with the emailed code.
- Access passes last 15 minutes; rotating refresh passes last 30 idle days. The refresh pass goes only in `auth/refresh`'s body.
- Concurrent expired requests wait for one renewal. Store both replacement passes before retrying each original request once. They are kept in memory first: the old refresh pass is spent and is never sent again (guide §3.4). If the phone cannot store them, the login goes on from memory and the stored spent pair is deleted, so a restart opens Login (TC-SESS-045). Stale responses never end a newer login or restore ended credentials.
- Authenticated `401 unauthenticated` ends the login, except the documented wrong-old-password response from `me/password`.
- Public code/password/access-request errors stay in their respective forms and do not clear another session.
- Whoever makes an account decides whether its first password must be changed (backend D59): the portal and the staff panel tick it by default, an approved access request leaves it off. The app follows `must_change_password` as `logged_in`, `GET me` and renewals send it. Only profile, change password, and logout remain available until it is changed.
- **No "Not now"** (backend D65, DEC-429; guide §3.2; removed 2026-11-23): whoever sets an official's password ticks "must change password" or not (D59), also when replacing a password. Ticked, the login answers `must_change_password: true` and only the change screen and **Log out** are open until the password is changed; unticked, the app works as usual and the password can be changed in Profile. Fields the guide does not have (`password_change_skippable`, `password_change_pending`) are ignored.
- User-chosen passwords require 8-128 code points, a Unicode letter, a Unicode digit, and no control characters. Show live rule hints and a visibility control before typing.
- A wrong, expired or closed reset code (backend D64: 10 wrong codes in an hour close the reset for 15 minutes, with the same 401) shows "The code is wrong or has expired. Ask for a new code." and **Send a new code**, which returns to the email step with the email kept. The neutral sentence of step 1 is never contradicted on the reset screen.
- Password change replaces the access pass while keeping the refresh pass. Forgotten-password reset returns to login.

## 7. Permissions

| Permission | Capability |
|---|---|
| `item:lookup` | One-item serial entry or QR scanning |
| `item:bulk_lookup` | Continuous scanner mode and serial stacks |
| `history:own` | Own checks, own session list/detail, profile totals |
| `incident:report` | File incidents, upload photos, own reports, retail picker |

Read permissions from `GET me`, not role names or tokens. Empty sets are valid; unknown keys grant no capabilities. The keys become the typed `Permission` values at the data boundary (`features/profile/domain/entities/profile.dart`, the only place they are written); a key not written exactly as the backend writes it is dropped there (2026-11-24, production audit P-4). Reload profile after `403 forbidden` and remove inaccessible routes. Guard parameterized session-check paths as well as menu entry points.

A custom role can have bulk without single lookup or history. It can inspect its current results; recovery and session browsing must not call history endpoints without `history:own`. `history:all` and `retail_user:add` are withdrawn and grant no UI.

## 8. State and concurrency

Keep app-wide session/profile state and route-scoped feature controllers. Duplicate form submissions are dropped. History search is debounced; changes reset the cursor; stale responses are discarded. Paginated lists allow one next-page request at a time.

- `RequestAccessCubit`: roles/loading, form, code, pending, failure and cooldown; no password in state.
- `ScanSessionCubit`: initialization/recovery, active UUID, one scan at a time, counters, latest full result, memory-only summary rows, repeat indicator, cooldown and paused state.
- `SerialStackCubit`: validated serial draft, locked submitted payload, result, failure/cooldown, transport-uncertain state and bounded scheduled retry.
- `SessionsCubit`: session filters and cursor pagination, guarded against stale responses.

Pause camera and scheduled retries while backgrounded. Closing a controller cancels timers/subscriptions. Discard results arriving after exit/logout. Nothing is automatically submitted on connectivity restoration.

## 9. Navigation

Three persistent tabs remain: Check, History (permission-gated), Profile. New flows open above the tab bar.

| Path | Access |
|---|---|
| `/splash`, `/login`, `/login/verify-code` | Session-driven |
| `/forgot-password`, `/forgot-password/reset`, `/request-access` | Public |
| `/change-password` | Required or voluntary change |
| `/home`, `/profile` | Authenticated with profile |
| `/home/result` | Current in-memory lookup/scan/stack result, with a lookup capability |
| `/home/scanner-mode`, `/home/serial-stack` | `item:bulk_lookup` |
| `/history` (Checks and Sessions views), `/history/sessions/:id` (one session's checks) | `history:own` |
| `/home/reports`, `/home/reports/new` | `incident:report` |

The routes are built in `lib/app/router/routes/`, one file per area (auth, check, history, reports, profile); `app_router.dart` holds the `GoRouter`, the guard and the check of pushed pages (2026-11-24, production audit P-6). **Who navigates** (2026-11-24, production audit P-9): a screen opens its own feature's routes itself by `RouteNames`, and Home, the app's root, from anywhere; a route of another feature is reached through a callback the router passes in (as Check reaches Profile, New report and My reports, and a result reaches New report). Checked by rule R18. A result route restored without its in-memory extra returns to Check. A session-check route can rebuild from its session ID and the backend. Secrets never enter URLs, navigation logs, or route extras. Retired retail routes are unavailable.

## 10. Pagination and time

Pass opaque cursors back unchanged, and only to the list that gave them: a filter changed during a 429 wait loads its own first page (TC-HIST-055). A full last page can be followed by an empty page. Keep totals from the first checks page; later-page `totals: null` does not erase them. Profile totals come from `GET checks?limit=1`, with no additional endpoint.

Checks support result, way, inclusive date strings, search, and `session_id`. No history/session request sends `scope`. Clearing ordinary filters in a session detail keeps its session restriction.

Session lists support status, dates, limit and cursor, with both QR and serial kinds in the returned rows. Omitted dates use the server's last-seven-days default. There is no undocumented kind query.

Render times in Asia/Dhaka using the existing utilities and injectable clock.

**Dates (2026-11-23).** The backend's `from`/`to` are whole UTC days, both included, and the totals count those UTC days (guide §4.5, §5). The app shows Bangladesh days, which run from 18:00 UTC the day before to 18:00 UTC, so for the Bangladesh days F to T (`LocalDays`):
- it sends `from` = F − 1 and `to` = T, in `YYYY-MM-DD` with Latin digits; an open side stays open;
- it keeps only the rows inside the chosen days: checks by `at`, sessions by `started_at` (which time the backend filters sessions by is not written down);
- rows come newest first, so the list ends at the first row before the first day (a check by `at`, a session by `last_scan_at`); a page that keeps no row but has a cursor loads the next by itself, up to 50 in a row;
- the server's totals are not shown for a date filter: the counts are the kept checks', given once the list is complete and kept through a refresh; with a result picked, its own checks are counted. No `limit=1` request counts them. Without dates, the server's totals as before (TC-HIST-051 … -054).

## 11. Configuration and organization

Use mock/staging/live flavors and matching JSON configuration. API base addresses are HTTPS; the slug is fixed per build. Office contact configuration is used for the empty-access-role fallback; authenticated support comes from `GET me`.

**Citations in code comments** (2026-11-24, production audit P-11) name the current section: `final.md §N`, `guide §N` (the app API guide), `build guide §N`, `UI audit 2026-11-22, N.N`, `test plan §N`; a test checks that each exists, in the code, the tests, the tools and the Android and iOS projects, a citation over two lines included (P-16). Register implementations in `app/bootstrap.dart`; feature widgets receive interfaces/callbacks. Tests mirror the feature layers and use the fake backend, secure storage, camera, photo, launcher, and image wrappers. No automated tests call real services or plugins.

## 12. Security and privacy

Never log passwords, emailed codes, phone IDs, passes, lookup values, request bodies, query values, or photos. A release build prints nothing to the phone's log, by the app's own switch (`ConsoleLoggerService` `printing`, on in debug builds only), never by a package default (2026-11-24, production audit P-12); a debug build prints redacted lines. Do not cache products/pictures on disk. No cookies or CSRF machinery is added to the mobile API.

Only the active scanner UUID is persisted for a session, under a client/official-specific storage key. Lists, results, serial drafts, access passwords and codes remain in memory. Logout/account changes remove recovery state; late responses cannot repopulate it.

**Crash reports** (2026-11-24, production audit P-10): Firebase Crashlytics, only in a staging or live release build given a Firebase app for its platform (Section 17); otherwise nothing leaves the phone. A report holds the stack trace, the redacted log line and the error as its type only (an app error adds its code, status and request reference), never an error's own text, which can quote an answer or the screen. Crash reporting that cannot start never stops the app. Show backend request references on API errors. Never open QR links. Show `item.code` already masked by the backend, without reconstructing a hidden code. Reports and photos retain their existing raw-upload and metadata-removal rules. Preserve native backup exclusions and dependency scanning in CI.

## 13. Feature behavior

### 13.1 Single lookup

Load `formats` once per login and validate only serial/QR inputs using that response. A QR's letters are checked in either case, one character for one, and the value is sent as read: the server reads it in capitals (guide §4, "Reading a QR"; TC-LOOK-128). Back from a scanned result, the same QR is not read again for 5 seconds, as the camera may still see it (guide §4.3, "Do not send the same QR twice in a row while it stays in front of the camera"; TC-LOOK-129). Keep serials as text, including leading zeros. Reuse normalization and QR parsing; take the value after the last `/q/` without opening the URL.

Show the backend result and reference:

| Result | Display |
|---|---|
| valid | Genuine first check, supplied item/count |
| warning | Genuine with every supplied reason: checked_before, recalled, expired, damaged, switched_off |
| not_found | Reference and entered serial/QR; no fabricated item |
| unassigned | Reference, no fabricated item |
| unknown | Neutral unavailable result; never valid |

Counts show this-check number and previous time; earlier officials' names are removed. Product picture/name, masked code, batch and nullable dates retain existing rendering. Not-found hints refer to serial format and QR scanning, never scratching a hidden-code panel.

### 13.2 Continuous QR scanner sessions

Entering scanner mode creates a UUID v4 unless recovering one. There is no start API: the first `POST lookups` with `{way: qr, value, session_id}` starts it. Persist only the UUID before scanning.

Show each answer on the camera screen immediately, with authoritative `session` totals and `repeat`. Deduplicate visible rows by reference. Repeated frames are suppressed; a backend repeat shows Already scanned and adds no row. Keep the list newest first and render it lazily.

- session_full/session_ended: create/persist a new UUID, clear the old in-memory session, retry the current scan once. Until the next scan the screen says "A new session started: the last one was full, or closed after 15 minutes without a scan.", adding "Its products are in History, then Sessions." for a role with `history:own` (TC-MIG-072; user decision 2026-11-23: the list is cleared, not kept).
- session_not_yours: discard the ID, create a new session, require another scan.
- 429 with usable Retry-After: pause further submissions, wait, retry the current scan while foregrounded.
- Network failure or 503 service_unavailable: show Scan again; do not queue it.
- Both back actions send end without waiting for its reply, clear rows/UUID, and leave immediately. The backend also expires idle sessions.
- Recovery with history permission reads the summary and paginated checks. It rebuilds summary rows, not full lookup details absent from the history response. An ended/missing session starts fresh.
- Without history permission, retain the recovered UUID and obtain counters on the next scan; never call protected history reads.

Only the latest full live response opens full result details. Older/recovered summary rows do not pretend to contain full product data.


**Finish (2026-11-19).** A **Finish** bar under the camera (off until a scan is answered) ends the session with a summary. No read is taken after it; the reads already taken are still sent and answered, a 429's wait included, even when a result is opened meanwhile (TC-MIG-070). After a resume, the session's scans come a page at a time: the summary says "Showing X of Y" and **Load more** adds the rest (TC-MIG-071). Then `POST lookups/sessions/{id}/end` is sent without waiting and the session ID is forgotten. The summary shows "Session finished", how many products were scanned, the counts, any reads let go, and every product with its result, newest first; a product answered in this run opens its full result. **Scan more** starts a new session on the camera; **Done** returns to the Check tab. Back (the app's or the phone's) still leaves at once, as guide §4.4 asks.
### 13.3 Serial stacks

Type or paste serials separated by comma/whitespace/newlines. Normalize, validate, preserve first occurrence order and leading zeros, and deduplicate. Accept 1-50 distinct serials. Reject overflow without truncation or splitting.

`POST lookups/serials` sends `{serials: [...]}`. Match the serial-tagged answers to the expected order, check their count, and display backend session totals plus each result/reference. A successful request is already an ended serial session; no end call is made.

Lock the submitted payload through retries. A confirmed 503 service_unavailable retries once after one second; subsequent failures require manual retry. A valid 429 waits the server header. Transport loss is uncertain: never replay it automatically, because a committed response may have been lost. Explain that an explicit retry may create additional checks. Clear drafts/results on exit; clear the submitted draft after success.

### 13.4 Own history and sessions

Search serial/reference, filter, and page through own checks. Session details use `checks?session_id=...` and retain that filter when changing other controls. Legacy history can still display/filter `way: hidden_code`; it is not a submission option.

The History tab has a **Checks | Sessions** switch under its title (a segmented control, navy for the chosen segment). **Checks** is the own-checks list. **Sessions** lists the official's own sessions, scanner sessions and serial stacks alike, newest first, with status (all, open, ended) and date filters; without dates the backend answers the last 7 UTC days. Dates chosen in Checks or Sessions are Bangladesh days, asked as the UTC days they overlap (Section 10, "Dates"). Each row shows the kind, the status, the first and last scan times, and the backend totals. A row opens **Session checks**, the checks of that session (`/history/sessions/{id}`), without the switch; back returns to the Sessions view. Returning to the retained History tab refreshes it. Profile totals refresh when the profile tab returns.

### 13.5 Incident reports and photos

Keep note, optional own-check reference, optional retail user, and up to three photos. Filing returns the report ID. Upload each photo sequentially as raw image bytes with content type and length, after resizing to 2048 px/JPEG quality 85 and enforcing 1 MB. Reuse identical bytes when retrying; never re-file the report to retry a photo. Only the author may add photos within an hour. My reports shows own reports/photo counts; the app cannot download report photos.

### 13.6 Retail picker

Only `GET retail-users` remains. It requires incident permission, searches active users and pages masked-email results. Retail status defines picker membership; it does not grant any app permission. Account creation and password administration belong to the office portal.

### 13.7 Home and profile

Retain the current token-based visual design. Home shows serial entry/QR for single permission and separate Scanner mode/Serial stack tools for bulk permission, plus permitted reports. Empty permissions show an empty state.

Profile shows identity, role, organisation, support, language (Section 16), version, voluntary password change and logout. A **What you can do** card lists the official's permissions by their names in the SRS (FR-ACC-15): Check one item, Check many items, Own history, Report incidents; unknown keys are not shown, and an empty set shows "None. Ask your office.". Check totals require history permission. Crashlytics provisioning remains separate release work.

### 13.8 Public access requests

Fetch requestable roles without authorization. If none exist, show Ask the office for an account with the configured contact fallback. Collect name (1-100 characters), role, chosen password and email before sending an email code. Then collect the six-digit code and submit exactly those five documented fields.

Always show the same code-sent confirmation, including for existing accounts. Email edits invalidate the local code step. Invalid/expired codes stay in the form; 403 policy and 404 role errors preserve its code and fields, refreshing roles on 404. A 409 consumes the code and returns to requesting another. Honor Retry-After and drop concurrent submissions. Success clears secrets and shows Pending; approval/refusal happens in the office and arrives by email.

### 13.9 Screen rules (2026-11-17)

- A 429 countdown disables the primary action of the screen and shows the seconds (sign-in screens, Check, the Check tab's camera, Splash).
- A request that never left the phone (no connection) is safe to send again; a lost answer may have been recorded: a single check then says "The answer was lost. This check may already be recorded; checking again counts as another check." (TC-LOOK-060, -130), a stack then warns, and sends again only after **Send again** in "Send the stack again?", which points to History, then Sessions, to look first (TC-MIG-069), and a report is never filed again from its screen (**Check My reports**). A stack answer that was recorded but cannot be read is never sent again.
- The Check tab keeps its camera and the tools when the formats fail; only the serial form waits for them, and the camera says "Scanning waits for the code formats."
- After a failed single QR lookup, **Scan again** restarts the camera so the same QR can be read; nothing is sent again by itself.
- Scanner mode clears the previous card on a failure and says "No connection, scan again."; a `session_not_yours` restart says "A new session started."
- The result card shows every field of a found item, a missing one as "—", with the check count; from scanner mode or a stack, the result goes back to its list, never Home.
- History has its own empty text for "no checks yet"; one session's checks open under a summary of that session (`GET lookups/sessions/{id}`).
- Profile lists both support channels the office set, each with a fallback text when the phone has no mail or phone app.
- Scanner mode has the Check tab's camera look: dark, the frame and its hint; the counters show zeros before the first scan; **Scan again** shows only after a failure; the latest card names the serial and product.
- History rows show who checked ("Checked by …", always the official logged in, backend D61) and, for a session's check, the session ("Session 7F3C2A10": the ID's first 8 characters), as SRS FR-HIS-04 lists (user decision 2026-11-19); the way filter uses the same chips as the results. The Sessions view is a paged list like History's (skeleton, empty and error states, automatic paging).
- The stack shows "N of 50 serials" (repeats sent once) before sending, and Back waits while a stack is sent.
- A photo answered `409` says why ("No more photos: the report has 3, or its hour is over."); **Done** and Back ask before leaving photos that are not sent, and the screen cannot be left while the report is filing (TC-REP-064, -065); My reports opens a report in full.
- Profile's three stat cards add up: Checks = Valid + Needs attention (warning, not found, not in a batch).

### 13.10 Data-flow rules (2026-11-17)

- Every 429 waits its own `Retry-After`. Request access counts codes and requests apart, each photo has its own wait, and the loop stops at a 429 photo. The formats' Retry, the list Retry buttons and a resumed session's scans wait out the countdown.
- History, Sessions, My reports and the retail user picker keep the filter or search tapped during a wait and load once when it ends; a pull during a wait sends nothing.
- `Retry-After` is read in seconds or as an HTTP date still to come. Without a usable value the screen says "Try again later" and allows a manual retry; no wait is made up.
- The report note takes at most 1,000 code points, and its counter counts code points (a flag counts two).
- The stack's live count counts serials as they are sent: each value prepared, so "1000-001" and "1000001" are one serial.
- The same photo picked twice keeps one place: the server answers its `n` again and the app says "That photo is already on the report."
- A report answered 2xx with a body that cannot be read may be filed: it is never filed again from the screen (**Check My reports**).
- A 404 names what is gone: "Check not found." the check, "Retail user not found." the retail user (taken off the report, so the picker is offered again), "Role not found." the role (the text is read once, in the repository that sent the request, into a typed reason: 2026-11-25, production audit P-25); any other 404 is "Not available". A page without the error envelope is decided by its status: 400/413/415 a defect, 403 a general error, 404 "Not available".
- A refused photo shows, under the photos, the server's message for a 409 and the reference.
- The QR value is sent as read, trimmed only, and checked against the `characters` of `GET formats` in either case (Section 13.1).
- A `409 conflict` shows the server's message (guide §1: "Show the message"), unless the screen handles it itself (TC-ERR-051).
- A refused certificate means nothing was sent. A request sent without a pass carries no `Authorization`. A late 403 `password_change_required` for an older pass leaves the login of now as it is.
- Logout and the end of a session are sent with no body and no `Content-Type` (guide §1); Log out spins until the login has ended.
- A phone ID that secure storage cannot read gives "Something went wrong. Try again." on Login and the email code screen.
- The app never says "verify" (SRS v1.2 glossary: an official's look-up is a **check**; "verification" is the consumer's public website, which the app never touches). The tab is **Check**, the card **Check authenticity** with its button **Check**, the loader **Checking…**, the result page **Check result**; the email code screens say **Code from the email** and **Continue**; the brand lines say **Product Authenticity Check** and **TRACK · TRACE · CHECK**. Code and route names keep their old words (`verify_screen.dart`, `auth/verify-phone`).
- **Login's Request access** (guide §3.9; renamed from "Sign up" 2026-11-23, TC-AUTH-118): the screen of guide §3.9 with its fields (name, role, password with the rule, email), the emailed code and the office's answer by email. It says it is a request: "Ask for an account. Your office checks the request and emails you its answer.", the button **Send request**, and once sent the guide's "Your request was sent. You will get an email when it is answered." (an answer may be a refusal). Code and API names keep the backend's term (`request_access_screen.dart`, `auth/access`).
- **The offline banner** (built 2026-11-19, §14.2): "No internet connection. Checks need a connection." above every screen, login screens included, after one second without a link and gone at once when it is back. It follows the phone's link only (Wi-Fi without internet shows no banner; the failed request says so), never blocks or covers a button, sends nothing by itself when the link returns, and is read by TalkBack (the screens below are their own semantics container, so a page route cannot hide it). At a large font the Check tab's header scrolls with the page, so it never overflows a small phone.
- **Login ends with a copyright footer** (user decision 2026-11-18): under **Request access**, "Only authorized users can access this system", a hairline, "© {year} Ziska Pharmaceuticals Ltd. All rights reserved." (the year from the clock) and "Version {version} ({build})" from the installed app. It rests at the bottom of a tall phone and scrolls after the form on a short one or at a large font; screen readers read the copyright and version as one item.
- **The Check tab is the camera** (user decision 2026-11-18). With `item:lookup` the tab opens on a live camera under the header: a read QR is the trigger, sent at once as `POST lookups {"way":"qr","value":…}` with no button, and its result opens; back returns to the running camera. The serial is typed right under the camera ("Or type the serial", **Check**); the tools follow. The camera runs only while it can be seen: the tab shown and not covered, the app in the foreground, no result open and no failed scan waiting for **Scan again**. Camera refused: the message with **Open settings**, and typing still works. Without `item:lookup` there is no camera. The former **Scan QR code** card and its separate screen (`/home/scan`) are gone.
- Scanner mode never drops a read QR: reads that come while one is being checked wait in line and are sent in the order read, one at a time, 500 ms apart (guide §4.3: 2 scans a second). A 429 holds the line until `Retry-After`; any other failure lets the waiting reads go and says how many to scan again. Each answer shows at once on the camera in its colour (Genuine, Needs attention, Not found, Not in a batch, Already scanned) with the serial and product, the frame takes that colour, and the phone vibrates: a short buzz for Genuine, a longer one for anything else.
- The Check tab shows a formats failure with **Try again** under the camera. Scanner mode offers **Try again** when a resumed session's scans fail to load, and a resumed session without its totals says "Resumed session. The counts show after the next scan." instead of zeros.

## 14. UI Component Architecture

### 14.1 Reusable Components

Use existing design tokens and shared controls; no new design system or Figma API write is needed.

| Component | Purpose |
|---|---|
| `AppButton` | Main actions and loading/disabled states |
| `AppTextField` | Labels and serial/name/email/note input |
| `AppPasswordField` | Secret input and visibility |
| `AppOtpField` | Normalized six-digit code input |
| `PasswordRules` | Live Unicode-aware password requirements |
| `VerificationResultCard` | Result, reasons and check reference |
| `ItemDetailsCard` | Supplied item/count details |
| `SessionCounters` | Authoritative scanner/stack totals |
| `CheckTile` | Own historical check summaries |
| `FailureBanner` | Error reference and optional cooldown |
| `AppPaginatedList<T>` | Existing check/report/picker paging |
| `AppEmptyState` | Empty/permission states |

### 14.2 UI States

Every network flow needs initial/loading, success, empty where applicable, and recoverable failure states. Use server Retry-After for countdowns. With no usable header, show a rate-limit message and manual retry without inventing 60 seconds. Loading never leaves a form submitting forever on malformed responses.

Use Lucide icons, token-based spacing/color/typography, and scrolling at small sizes/large fonts. Live scan lists and stack results render lazily. Accessibility must communicate results in words, not color alone.

## 15. API contract

All routes are relative to `/v1/clients/{slug}/` and use the documented success/error envelope. They are listed once, in `lib/core/network/api_routes.dart` (`ApiRoutes`): `ApiClient` takes a route, not a path, refuses a route of the other method, and a test keeps the list equal to the backend's Postman collection (2026-11-24, production audit P-17). A service reads an answer's `data` through `ApiData` (`core/network/api_data.dart`): any other shape is `InternalErrorException('<name>_shape')`, the name fixed per answer (2026-11-25, P-19). The `error.code` values are written once, in `core/errors/api_error_codes.dart` (`ApiErrorCodes`), which a test keeps equal to guide §1's table (2026-11-25, P-23). An `AppException`'s `message` is only the server's text: why the app itself failed is a typed `reason` (`core/errors/failure_reason.dart`, with each feature's own enum), and `NetworkException.wasNotSent` a field; nothing decides on `message` (2026-11-25, P-24). Branch on HTTP status and codes, never message text.

| Resource | Routes |
|---|---|
| Login/session | auth/login, auth/verify-phone, auth/resend-code, auth/refresh, auth/logout, GET me |
| Password | me/password, auth/password/forgot, auth/password/reset |
| Public requests | GET roles/requestable, POST auth/access/code, POST auth/access |
| Verification | GET formats, POST lookups (with optional session_id), POST lookups/serials |
| Sessions | GET lookups/sessions, GET lookups/sessions/{id}, POST lookups/sessions/{id}/end |
| History | GET checks |
| Reports | POST/GET incidents, POST incidents/{id}/photos |
| Picker | GET retail-users |

The bulk endpoint and retail administration endpoints are gone. No hidden-code way or scope is sent. The server owns limits: the current serial-stack bound is 50, with 500 serials/minute; use Retry-After rather than a client rate window. Scanner counters include remaining capacity when the scan response supplies it.

## 16. Localization

English and Bangla ARBs with generated accessors. Every English text has a Bangla text with the same placeholders and plural cases; `test/l10n/arb_completeness_test.dart` fails otherwise. The Bangla texts are drafts until the client's Bangla reader approves them (`docs/bangla-drafts-for-review.md`).

- **Switch:** Profile → **Language** offers English and বাংলা, each named in its own language, the current one marked. The choice applies at once, without a restart, and is kept on the phone (`PreferencesService` on `shared_preferences`) across restarts and logouts; it is a phone setting, not part of the login. `LocaleCubit` reads it before the first screen.
- **First start:** English until a choice is made, whatever the phone's language.
- **Times and dates:** Bangladesh time, written with the chosen language's calendar data (in Bangla: Bangla digits and month names). Dates sent to the API stay `YYYY-MM-DD` in Latin digits.
- **Digits typed:** Bangla digits typed or pasted into a serial are read as 0–9 (`CodeNormalizer`, `SerialInputFormatter`). This is the app's own choice (user decision 2026-11-23): the server does not convert them, and a value with Bangla digits answers `not_found` there (guide §4, "Reading a serial"), so the server only ever receives 0–9.
- **Errors:** a known `error.code` shows the app's text in the chosen language; an unknown code shows the server's message, with the reference.
- **Font:** the platform's Bangla font. The theme names Noto Sans Bengali as its fallback; the tests load it from `test/fonts/` (OFL 1.1), so the Bangla goldens show real letters.

## 17. Environments

**Crash reporting** (2026-11-24): staging reports to the Firebase project `ziska-verify` (its Android app only); live waits for its own production project. Six optional values in `config/staging.json` and `config/live.json`, all or none for a platform: `FIREBASE_PROJECT_ID`, `FIREBASE_SENDER_ID`, `FIREBASE_ANDROID_API_KEY`, `FIREBASE_ANDROID_APP_ID`, `FIREBASE_IOS_API_KEY`, `FIREBASE_IOS_APP_ID`. A half-filled set, or any of them in the mock build, stops the app at start (Section 12). Mock builds use the updated Postman snapshot and require its current mock server. Staging/live retain HTTPS and fixed client identity. The mock build has no other demo flag than `POSTMAN_MOCK_ROUTING` (Section 20.2); `DEMO_PASSWORD_LATER` was removed with "Not now" (2026-11-23).

The backend's test server (2026-11-22) is the staging environment: `https://testapp.protecb.com`, client `ziska-test`. The app was checked against it in 11 steps (`docs/staging-integration-2026-11-22.md`); the server's answers are fixtures replayed in `test/staging/`. Do not test recorded checks against a live client.

What is still open on the backend's side is in `docs/backend-requests/2026-11-22-backend-fix-list.md`.

The backend's documented rules (`ProtectB-DOCS` e163a52, DEC-429 and D65, and its reply to our fix list; the contract copy in `docs/protectb-api/` is byte-identical):
- **Serials** (guide §4.1): digits 0–9 only, leading zeros dropped (`001` and `1` are one item), up to 40 characters, `serial.max_digits` counting the serial's own digits; `0` is `not_found`. The app sends the first typed of such serials once; Bangla digits are read as 0–9 on the phone first (Section 16).
- **QR values** are read in capitals; the app sends a QR as read, in either case (Section 13.1).
- **Dates** are whole UTC days; the app asks for the UTC days a Bangladesh day overlaps (Section 10, "Dates").
- **Lengths** count code points, an emoji as one (DEC-429). **The test server does not run it yet** (2026-11-23: a request's name and a retail search of 99 letters and an emoji still answer 400), so the app keeps those two within 100 UTF-16 units (`TextLimits.fitUtf16`). The change to code points is ready on the branch `hold/code-point-lengths`, to merge once the checker's `signup-probe` and `lengths` show it accepted. A note and a password already count code points.
- **A note is trimmed before it is counted:** the spaces around it do not count toward its 1,000 characters.
- **Email** is matched in any case, spaces around it ignored; the app trims it.
- **A new password may equal the current one**; if that changes, the answer will be 403 `policy_denied`, which the app shows with the rules.
- **A renewal during a forced change** answers 200 with `must_change_password` again; the app keeps the change screen.
- **Routes without a body** are sent with no body and no JSON `Content-Type`.
- **No "Not now"** (D65): Section 6.

## 18. Verification

Run format, analysis, tests, supported-host goldens, and the mock APK build with the pinned SDK. Regenerate outputs after model/ARB changes. Contract/flow tests use the current Postman examples and locally scripted documented errors; no real networks or plugins.

New acceptance cases and manual steps are in `docs/test-cases/16-mobile-migration.md`. Retained tests cover authentication/renewal, reports/photos, result rendering, own history, permissions, security and accessibility. Retired capabilities' scenarios are superseded rather than retained as release requirements.

## 19. Migration decisions

Approved for this migration: full Flutter contract migration; serial entry limited to 50 rather than splitting; unrelated release completion tracked separately. No backend implementation or production rollout is performed by this repository change.

| # | Decision (2026-11-16) | Source |
|---|---|---|
| M1 | **No "Not now"** (backend D65, DEC-429; guide §3.2). Whoever sets the password ticks "must change password" or not (D59). The button, its route `me/password/later`, the fields, the Profile reminder and the mock demo were removed on 2026-11-23, following ProtectB-DOCS as the source of truth (it had stayed since 2026-11-17, waiting for a route the backend decided not to build). | User decisions 2026-11-17, 2026-11-23 |
| M2 | **Sessions live in the History tab**, behind a Checks / Sessions switch; one session's checks open above it. | User decision; SRS UC-06, FR-SCN-16 |
| M3 | **Two Check tiles**, Scanner mode and Serial stack, both with `item:bulk_lookup`. | User decision; SRS FR-SCN-01, FR-STK-01 |
| M4 | **Profile lists the permissions** by their SRS names. | SRS FR-ACC-15 |
| M5 | **Request access looks like the other sign-in screens**: the navy header with its subtitle, labels above the fields. | Design tokens (Section 14) |
| N1 | **One header style for pushed screens and History**: the navy gradient app bar (`NavyAppBar`) with white title and Back, on History, Result, Stack of serials, Report incident, My reports and Session checks; the sign-in screens keep the tall `GradientHeader`; the camera screens keep their dark camera layout. | User decision 2026-11-17 |
| N2 | **The History tracking log is the official's own**: a searched serial shows "Your checks of serial X", never suggesting other officials' checks. | User decision 2026-11-17; backend D61 |
| N3 | **Report incident links one of the official's own checks** through a picker of the own history (search by serial or reference); offered only with `history:own`. | User decision 2026-11-17; SRS UC-08 |
| N4 | **Bangla drafts** for the strings added with D56–D63 and the screen fixes are in `app_bn.arb`, listed for the client in `docs/bangla-drafts-for-review.md`. | User decision 2026-11-17 |
| N6 | **The app follows the backend plan at 4ec8318 (2026-11-18) in full**: a stack's unreadable 200 counts as recorded; an unknown code on any status shows the server's message; Request access's texts follow guide §3.9; no photo over 2,048 px; History rows show the official and the session (SRS FR-HIS-04). ("Not now" was later removed: M1.) | User decision 2026-11-19; `docs/backend-alignment-2026-11-19.md` |
| N5 | **The language switch ships with every text drafted in Bangla**, all marked for the client's review in `docs/bangla-drafts-for-review.md`. The first start is English; Bangla digits in a serial are read as 0–9 (the app's answers to open questions 18 and 19A, sent to the client). | User decision 2026-11-19 |

## 20. Remaining dependencies

See `docs/release-backlog.md` for the test server's remaining data (QR values, a retail user, an item with a picture), the code-point lengths on the test server (DEC-429), the client's review of the Bangla texts, release signing, Firebase/Crashlytics and iOS schemes. The architecture is not evidence that manual/staging acceptance has run. Record actual tool results in the migration report.

### 20.0 The backend plan of 2026-11-18

The plan at commit 4ec8318 changed two things the app meets, and neither needs an app change: the Scanner sessions routes are final (built and tested), and a photo's `503` also means the storage did not take it within 10 seconds (the app already offers "Tap to send again"). The app was checked against it line by line on 2026-11-19 (`docs/backend-alignment-2026-11-19.md`).

### 20.1 Backend questions (2026-11-17)

Four points went to the backend team in `docs/backend-requests/data-flow-questions.md`. **All four are answered in ProtectB-DOCS e163a52**, and the app follows the answers (Section 17):

- `from`/`to` of `GET checks` and `GET lookups/sessions`: whole UTC days; the app asks for the UTC days a Bangladesh day overlaps and keeps the rows inside it (Section 10, "Dates").
- QR case: read in capitals; the app accepts a QR in either case and sends it as read.
- `auth/refresh` during a forced change: a 200 with `must_change_password: true` again, as the app handles it.
- A route without a body: no body and no JSON `Content-Type`, as the app sends it.

### 20.2 The Postman mock (2026-11-18)

The mock build talks to a Postman mock made from the 2026-11-17 collection with `tool/postman/ziska-mock.postman_environment.json` (steps in `docs/postman-mock-setup.md`). The mock-only `PostmanMockRouting` (`POSTMAN_MOCK_ROUTING`) picks the example where the mock cannot: a single check by the value's last digit (1 genuine, 2 needs attention, 3 not found, 4 not in a batch), scanner-mode scans, sessions under the app's own ID, and History's next page. Staging and live refuse the flag.

Scanner mode on the mock build runs as a server does: each scan's result follows the QR value's last character (1 genuine, 2 needs attention, 3 not found, 4 not in a batch, anything else genuine); each different QR of a session gets its own reference and serial; the same QR again is a repeat with its first answer; the counts add up per session. `docs/test-qr-sheet.pdf` page 2 has 8 such products for a phone.
