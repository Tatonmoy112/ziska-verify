# Track & Trace - Flutter Application Architecture

| Field | Value |
|---|---|
| Version | 2.0 |
| Date | 2026-11-16 |
| Platforms | Flutter Android and iOS |
| Backend | ProtectB mobile-app-api, `/v1/clients/{slug}/` |
| Contract baseline | ProtectB mobile guide dated 2026-11-16; mobile decisions D1-D63, including D56 and D58-D63 |
| Evidence | `docs/protectb-api/` is the app-owned contract snapshot; its Postman examples drive contract and flow tests |

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

Flutter 3.41.9 and Dart 3.11.5 are pinned through `.fvmrc`; Android uses JDK 17. Use the locked dependency versions. Existing packages provide BLoC/Cubit, Dio, go_router, GetIt, Freezed/JSON generation, secure storage, QR scanning, photos, and localization. Every plugin remains behind a core wrapper.

PDF and image dependencies are development-only for the manual QR-sheet generator. Printing and certificate sharing are not application dependencies.

## 3. Engineering principles

Use small constructor-injected interfaces and feature-first layering. Domain entities, validators, and repository interfaces are pure Dart. Repositories return `Result<T>` and typed `Failure` objects rather than throwing through presentation. Unknown response fields are ignored; unknown verification outcomes are never shown as valid.

Generated JSON, Freezed, and localization files are regenerated and committed, never edited by hand.

## 4. Architecture and data flow

Presentation calls domain use cases or repository interfaces. Data implements those interfaces, calls API services, parses DTOs, and maps them into domain entities. API services use the shared API client and its envelope/error handling.

- `lib/app/` owns composition, session/profile wiring, route guards, and cross-feature callbacks.
- `lib/features/authentication/` owns login/password and public access requests.
- `lib/features/verification/` owns serial/QR lookup, active scanner sessions, serial stacks, and session summaries/listing.
- `lib/features/history/` owns paginated check records and filters, including session-filtered checks.
- Incidents own report filing/uploading; retail users expose only the incident picker.
- `lib/core/` contains infrastructure and plugin interfaces, and never imports a feature.
- Features do not import one another's internals. The app-wide profile entity/Cubit is the existing exception.
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
- Concurrent expired requests wait for one renewal. Store both replacement passes before retrying each original request once. Stale responses never end a newer login or restore ended credentials.
- Authenticated `401 unauthenticated` ends the login, except the documented wrong-old-password response from `me/password`.
- Public code/password/access-request errors stay in their respective forms and do not clear another session.
- Whoever makes an account decides whether its first password must be changed (backend D59): the portal and the staff panel tick it by default, an approved access request leaves it off. The app follows `must_change_password` as `logged_in`, `GET me` and renewals send it. Only profile, change password, and logout remain available until it is changed.
- **Not now** on a forced change: when the answer also carries `password_change_skippable: true`, the change screen offers **Not now** under **Save password**. It sends `POST me/password/later`, which returns a normal access pass (the refresh pass stays), and the app continues to the Check tab. `GET me` then says `password_change_pending: true` and Profile shows a reminder card with **Change password**; the next login asks again. Without the field the change stays required. A `403 forbidden` hides Not now and says it is not available. The route and fields are requested from the backend team (`docs/backend-requests/password-change-later.md`), who will deliver them; until then the mock build plays them locally (`DEMO_PASSWORD_LATER`, mock only, Section 17).
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

Read permissions from `GET me`, not role names or tokens. Empty sets are valid; unknown keys grant no capabilities. Reload profile after `403 forbidden` and remove inaccessible routes. Guard parameterized session-check paths as well as menu entry points.

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

A result route restored without its in-memory extra returns to Check. A session-check route can rebuild from its session ID and the backend. Secrets never enter URLs, navigation logs, or route extras. Retired retail routes are unavailable.

## 10. Pagination and time

Pass opaque cursors back unchanged; a full last page can be followed by an empty page. Keep totals from the first checks page; later-page `totals: null` does not erase them. Profile totals come from `GET checks?limit=1`, with no additional endpoint.

Checks support result, way, inclusive date strings, search, and `session_id`. No history/session request sends `scope`. Clearing ordinary filters in a session detail keeps its session restriction.

Session lists support status, dates, limit and cursor, with both QR and serial kinds in the returned rows. Omitted dates use the server's last-seven-days default. There is no undocumented kind query.

Render times in Asia/Dhaka using the existing utilities and injectable clock. Date-picker strings retain existing behavior; the backend day-boundary question remains in the release backlog.

## 11. Configuration and organization

Use mock/staging/live flavors and matching JSON configuration. API base addresses are HTTPS; the slug is fixed per build. Office contact configuration is used for the empty-access-role fallback; authenticated support comes from `GET me`.

Register implementations in `app/bootstrap.dart`; feature widgets receive interfaces/callbacks. Tests mirror the feature layers and use the fake backend, secure storage, camera, photo, launcher, and image wrappers. No automated tests call real services or plugins.

## 12. Security and privacy

Never log passwords, emailed codes, phone IDs, passes, lookup values, request bodies, query values, or photos. Do not cache products/pictures on disk. No cookies or CSRF machinery is added to the mobile API.

Only the active scanner UUID is persisted for a session, under a client/official-specific storage key. Lists, results, serial drafts, access passwords and codes remain in memory. Logout/account changes remove recovery state; late responses cannot repopulate it.

Show backend request references on API errors. Never open QR links. Show `item.code` already masked by the backend, without reconstructing a hidden code. Reports and photos retain their existing raw-upload and metadata-removal rules. Preserve native backup exclusions and dependency scanning in CI.

## 13. Feature behavior

### 13.1 Single lookup

Load `formats` once per login and validate only serial/QR inputs using that response. Keep serials as text, including leading zeros. Reuse normalization and QR parsing; take the value after the last `/q/` without opening the URL.

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

- session_full/session_ended: create/persist a new UUID, clear the old in-memory session, retry the current scan once.
- session_not_yours: discard the ID, create a new session, require another scan.
- 429 with usable Retry-After: pause further submissions, wait, retry the current scan while foregrounded.
- Network failure or 503 service_unavailable: show Scan again; do not queue it.
- Both back actions send end without waiting for its reply, clear rows/UUID, and leave immediately. The backend also expires idle sessions.
- Recovery with history permission reads the summary and paginated checks. It rebuilds summary rows, not full lookup details absent from the history response. An ended/missing session starts fresh.
- Without history permission, retain the recovered UUID and obtain counters on the next scan; never call protected history reads.

Only the latest full live response opens full result details. Older/recovered summary rows do not pretend to contain full product data.

### 13.3 Serial stacks

Type or paste serials separated by comma/whitespace/newlines. Normalize, validate, preserve first occurrence order and leading zeros, and deduplicate. Accept 1-50 distinct serials. Reject overflow without truncation or splitting.

`POST lookups/serials` sends `{serials: [...]}`. Match the serial-tagged answers to the expected order, check their count, and display backend session totals plus each result/reference. A successful request is already an ended serial session; no end call is made.

Lock the submitted payload through retries. A confirmed 503 service_unavailable retries once after one second; subsequent failures require manual retry. A valid 429 waits the server header. Transport loss is uncertain: never replay it automatically, because a committed response may have been lost. Explain that an explicit retry may create additional checks. Clear drafts/results on exit; clear the submitted draft after success.

### 13.4 Own history and sessions

Search serial/reference, filter, and page through own checks. Session details use `checks?session_id=...` and retain that filter when changing other controls. Legacy history can still display/filter `way: hidden_code`; it is not a submission option.

The History tab has a **Checks | Sessions** switch under its title (a segmented control, navy for the chosen segment). **Checks** is the own-checks list. **Sessions** lists the official's own sessions, scanner sessions and serial stacks alike, newest first, with status (all, open, ended) and date filters; without dates the backend answers the last 7 days. Each row shows the kind, the status, the first and last scan times, and the backend totals. A row opens **Session checks**, the checks of that session (`/history/sessions/{id}`), without the switch; back returns to the Sessions view. Returning to the retained History tab refreshes it. Profile totals refresh when the profile tab returns.

### 13.5 Incident reports and photos

Keep note, optional own-check reference, optional retail user, and up to three photos. Filing returns the report ID. Upload each photo sequentially as raw image bytes with content type and length, after resizing to 2048 px/JPEG quality 85 and enforcing 1 MB. Reuse identical bytes when retrying; never re-file the report to retry a photo. Only the author may add photos within an hour. My reports shows own reports/photo counts; the app cannot download report photos.

### 13.6 Retail picker

Only `GET retail-users` remains. It requires incident permission, searches active users and pages masked-email results. Retail status defines picker membership; it does not grant any app permission. Account creation and password administration belong to the office portal.

### 13.7 Home and profile

Retain the current token-based visual design. Home shows serial entry/QR for single permission and separate Scanner mode/Serial stack tools for bulk permission, plus permitted reports. Empty permissions show an empty state.

Profile shows identity, role, organisation, support, version, voluntary password change and logout. While `GET me` says `password_change_pending: true` (after **Not now**), a warning card under the identity card reads "Your password was set by someone else. Change it to keep your account safe." with **Change password**. A **What you can do** card lists the official's permissions by their names in the SRS (FR-ACC-15): Check one item, Check many items, Own history, Report incidents; unknown keys are not shown, and an empty set shows "None. Ask your office.". Check totals require history permission. Language switching and Crashlytics provisioning remain separate release work.

### 13.8 Public access requests

Fetch requestable roles without authorization. If none exist, show Ask the office for an account with the configured contact fallback. Collect name (1-100 characters), role, chosen password and email before sending an email code. Then collect the six-digit code and submit exactly those five documented fields.

Always show the same code-sent confirmation, including for existing accounts. Email edits invalidate the local code step. Invalid/expired codes stay in the form; 403 policy and 404 role errors preserve its code and fields, refreshing roles on 404. A 409 consumes the code and returns to requesting another. Honor Retry-After and drop concurrent submissions. Success clears secrets and shows Pending; approval/refusal happens in the office and arrives by email.

### 13.9 Screen rules (2026-11-17)

- A 429 countdown disables the primary action of the screen and shows the seconds (sign-in screens, Check, the Check tab's camera, Splash).
- A request that never left the phone (no connection) is safe to send again; a lost answer may have been recorded: a stack then warns before sending again, and a report is never filed again from its screen (**Check My reports**). A stack answer that was recorded but cannot be read is never sent again.
- The Check tab keeps its camera and the tools when the formats fail; only the serial form waits for them, and the camera says "Scanning waits for the code formats."
- After a failed single QR lookup, **Scan again** restarts the camera so the same QR can be read; nothing is sent again by itself.
- Scanner mode clears the previous card on a failure and says "No connection, scan again."; a `session_not_yours` restart says "A new session started."
- The result card shows every field of a found item, a missing one as "—", with the check count; from scanner mode or a stack, the result goes back to its list, never Home.
- History has its own empty text for "no checks yet"; one session's checks open under a summary of that session (`GET lookups/sessions/{id}`).
- Profile lists both support channels the office set, each with a fallback text when the phone has no mail or phone app.
- Scanner mode has the Check tab's camera look: dark, the frame and its hint; the counters show zeros before the first scan; **Scan again** shows only after a failure; the latest card names the serial and product.
- History rows show "In a session" for a session's check and never a checker's name; the way filter uses the same chips as the results. The Sessions view is a paged list like History's (skeleton, empty and error states, automatic paging).
- The stack shows "N of 50 serials" (repeats sent once) before sending, and Back waits while a stack is sent.
- A photo answered `409` says why ("No more photos: the report has 3, or its hour is over."); **Done** asks before leaving photos that are not sent; My reports opens a report in full.
- Profile's three stat cards add up: Checks = Valid + Needs attention (warning, not found, not in a batch).

### 13.10 Data-flow rules (2026-11-17)

- Every 429 waits its own `Retry-After`. Sign up counts codes and requests apart, each photo has its own wait, and the loop stops at a 429 photo. The formats' Retry, the list Retry buttons and a resumed session's scans wait out the countdown.
- History, Sessions, My reports and the retail user picker keep the filter or search tapped during a wait and load once when it ends; a pull during a wait sends nothing.
- `Retry-After` is read in seconds or as an HTTP date still to come. Without a usable value the screen says "Try again later" and allows a manual retry; no wait is made up.
- The report note takes at most 1,000 code points, and its counter counts code points (a flag counts two).
- The stack's live count counts serials as they are sent: each value prepared, so "1000-001" and "1000001" are one serial.
- The same photo picked twice keeps one place: the server answers its `n` again and the app says "That photo is already on the report."
- A report answered 2xx with a body that cannot be read may be filed: it is never filed again from the screen (**Check My reports**).
- A 404 names what is gone: "Check not found." the check, "Retail user not found." the retail user (taken off the report, so the picker is offered again), "Role not found." the role; any other 404 is "Not available". A page without the error envelope is decided by its status: 400/413/415 a defect, 403 a general error, 404 "Not available".
- A refused photo shows, under the photos, the server's message for a 409 and the reference.
- The QR value is sent as read, trimmed only, and checked against the `characters` of `GET formats`.
- A refused certificate means nothing was sent. A request sent without a pass carries no `Authorization`. A late 403 `password_change_required` for an older pass leaves the login of now as it is.
- Logout and Not now are sent with no body and no `Content-Type`; Log out spins until the login has ended.
- A phone ID that secure storage cannot read gives "Something went wrong. Try again." on Login and the email code screen.
- The app never says "verify" (SRS v1.2 glossary: an official's look-up is a **check**; "verification" is the consumer's public website, which the app never touches). The tab is **Check**, the card **Check authenticity** with its button **Check**, the loader **Checking…**, the result page **Check result**; the email code screens say **Code from the email** and **Continue**; the brand lines say **Product Authenticity Check** and **TRACK · TRACE · CHECK**. Code and route names keep their old words (`verify_screen.dart`, `auth/verify-phone`).
- **Login's Sign up is the access request** (user decision 2026-11-18): the screen of guide §3.9 under the name **Sign up**, with the same fields (name, role, password with the rule, email), the emailed code and the office's approval by email; only the words differ. Its texts say the office checks the account: "Create your account. Your office checks it and emails you when it is approved." and, once sent, "Thanks for signing up. Your office will check your details and email you when your account is ready." Code and API names keep the backend's term (`request_access_screen.dart`, `auth/access`).
- **Login ends with a copyright footer** (user decision 2026-11-18): under **Sign up**, "Only authorized users can access this system", a hairline, "© {year} Ziska Pharmaceuticals Ltd. All rights reserved." (the year from the clock) and "Version {version} ({build})" from the installed app. It rests at the bottom of a tall phone and scrolls after the form on a short one or at a large font; screen readers read the copyright and version as one item.
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

All routes are relative to `/v1/clients/{slug}/` and use the documented success/error envelope. Branch on HTTP status and codes, never message text.

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

Keep English/Bangla ARBs and generated accessors. New migration strings have English and Bangla entries. Existing incomplete Bangla coverage and persistent locale selection are separate release work; this migration does not claim them complete. Use the current Bangladesh date formatting and normalization policies.

## 17. Environments

Mock builds use the updated Postman snapshot and require its current mock server. Staging/live retain HTTPS and fixed client identity. The mock build sets `DEMO_PASSWORD_LATER: true`, which plays `me/password/later` and its fields until the backend ships them; staging and live builds refuse the flag.

No test server is promised by the current backend guide. Do not test recorded checks against a live client. Real-mail approval, device cameras, and backend transaction behavior require staging/device acceptance when access is supplied.

## 18. Verification

Run format, analysis, tests, supported-host goldens, and the mock APK build with the pinned SDK. Regenerate outputs after model/ARB changes. Contract/flow tests use the current Postman examples and locally scripted documented errors; no real networks or plugins.

New acceptance cases and manual steps are in `docs/test-cases/16-mobile-migration.md`. Retained tests cover authentication/renewal, reports/photos, result rendering, own history, permissions, security and accessibility. Retired capabilities' scenarios are superseded rather than retained as release requirements.

## 19. Migration decisions

Approved for this migration: full Flutter contract migration; serial entry limited to 50 rather than splitting; unrelated release completion tracked separately. No backend implementation or production rollout is performed by this repository change.

| # | Decision (2026-11-16) | Source |
|---|---|---|
| M1 | **Not now stays.** The backend team will add `me/password/later` and `password_change_skippable` (`docs/backend-requests/password-change-later.md`); D59 also lets the office skip the forced change per account. Until the route exists, the mock build plays it (`DEMO_PASSWORD_LATER: true` in `config/mock.json`); staging and live refuse the flag. | User decision 2026-11-17 |
| M2 | **Sessions live in the History tab**, behind a Checks / Sessions switch; one session's checks open above it. | User decision; SRS UC-06, FR-SCN-16 |
| M3 | **Two Check tiles**, Scanner mode and Serial stack, both with `item:bulk_lookup`. | User decision; SRS FR-SCN-01, FR-STK-01 |
| M4 | **Profile lists the permissions** by their SRS names. | SRS FR-ACC-15 |
| M5 | **Request access looks like the other sign-in screens**: the navy header with its subtitle, labels above the fields. | Design tokens (Section 14) |
| N1 | **One header style for pushed screens and History**: the navy gradient app bar (`NavyAppBar`) with white title and Back, on History, Result, Stack of serials, Report incident, My reports and Session checks; the sign-in screens keep the tall `GradientHeader`; the camera screens keep their dark camera layout. | User decision 2026-11-17 |
| N2 | **The History tracking log is the official's own**: a searched serial shows "Your checks of serial X", never suggesting other officials' checks. | User decision 2026-11-17; backend D61 |
| N3 | **Report incident links one of the official's own checks** through a picker of the own history (search by serial or reference); offered only with `history:own`. | User decision 2026-11-17; SRS UC-08 |
| N4 | **Bangla drafts** for the strings added with D56–D63 and the screen fixes are in `app_bn.arb`, listed for the client in `docs/bangla-drafts-for-review.md`. | User decision 2026-11-17 |

## 20. Remaining dependencies

See `docs/release-backlog.md` for the test server, backend day boundary, complete Bangla switch, offline banner, Firebase/Crashlytics and iOS schemes. The architecture is not evidence that manual/staging acceptance has run. Record actual tool results in the migration report.

### 20.1 Backend questions (2026-11-17)

Four points are with the backend team in `docs/backend-requests/data-flow-questions.md`; the app works as written there until they answer:

- `from`/`to` of `GET checks` and `GET lookups/sessions`: the app sends the picked Dhaka calendar date.
- QR case: the app sends the value as read and checks it against the formats' characters.
- `auth/refresh` during a forced change: a 200 with `must_change_password: true` opens the change screen; a 403 keeps the login and fails only the request that needed the renewal.
- An empty logout body: the app sends no body and no `Content-Type`.

### 20.2 The Postman mock (2026-11-18)

The mock build talks to a Postman mock made from the 2026-11-17 collection with `tool/postman/ziska-mock.postman_environment.json` (steps in `docs/postman-mock-setup.md`). The mock-only `PostmanMockRouting` (`POSTMAN_MOCK_ROUTING`) picks the example where the mock cannot: a single check by the value's last digit (1 genuine, 2 needs attention, 3 not found, 4 not in a batch), scanner-mode scans, sessions under the app's own ID, and History's next page. Staging and live refuse the flag.
