# Ziska Verify — Flutter Application Architecture

| Field | Value |
|---|---|
| Document | Flutter application architecture specification |
| Version | 1.6 |
| Date | 2026-11-10 |
| Platform | Flutter (Android, iOS) |
| Backend | ProtectB `mobile-app-api` (`/v1`) |
| Backend source of truth | `ProtectB-DOCS-initial/`, provided by the backend team: `mobileApp/app-api-guide.md` (the contract), `mobileApp/00-decisions.md`, `mobileApp/app-build-guide.md`, the Postman collection, and ProtectB's system rules (`implementation-plan/02-decision-log.md`). Where this document and the backend documents differ, the backend documents win. |
| Scope rule | v1 uses only routes and behaviour the backend documents. Anything the backend has not documented is listed as future (Section 20.4) and is not built in v1. |
| Backend decisions | Aligned with ProtectB `mobileApp/00-decisions.md` D1–D55 (2026-11-10) |
| Status | Architecture baseline |

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Engineering Principles (SOLID)](#3-engineering-principles-solid)
4. [Architecture](#4-architecture)
5. [Service Layer](#5-service-layer)
6. [Authentication and Session](#6-authentication-and-session)
7. [Permissions](#7-permissions)
8. [State Management](#8-state-management)
9. [Navigation](#9-navigation)
10. [Pagination](#10-pagination)
11. [Project Structure](#11-project-structure)
12. [Security Architecture](#12-security-architecture)
13. [Feature Specifications](#13-feature-specifications)
14. [UI Component Architecture](#14-ui-component-architecture)
15. [API Contract](#15-api-contract)
16. [Localization](#16-localization)
17. [Environments](#17-environments)
18. [Testing Strategy](#18-testing-strategy)
19. [Decision Log](#19-decision-log)
20. [Pending Decisions](#20-pending-decisions)

---

## 1. Project Overview

Ziska Verify is the client's mobile app for its officials: field inspectors, supervisors, and retail sellers who check whether products on sale are the client's genuine products. The official scans a QR code or types a serial or hidden code, the app sends it to the ProtectB backend, and the app displays the backend's result.

- The backend is the single source of truth for authenticity. The app never decides authenticity locally.
- The ProtectB team provides the backend (`mobile-app-api`). This project builds and owns the app.
- One app, one client. The API base address and the client slug are fixed per build.
- Every feature requires an authenticated session. Login is the entry point of the app.
- The app is online only. No scans are queued and no item data is stored on the phone.
- The codebase is production grade: layered architecture, secure coding, and a reusable component library.

### 1.1 Users

| User | Description |
|---|---|
| Official | Any account created by the client's office. Logs in with email and password. |
| Inspector / supervisor | An official whose role allows lookups, bulk lookups, history, and reports. |
| Retail user | An official in a role the client's office marks as a retail role (a shop owner or seller). Looks items up and, with `history:own` (ticked by default for retail roles, backend D53), sees the history of their own checks. |

What each user can do is decided by the permissions of their role (Section 7). The app is not for consumers.

### 1.2 Feature Scope

| Feature | Description |
|---|---|
| Authentication | Login, new-phone code, forced password change, forgotten password, logout |
| Home | Entry point showing the features the official's role allows |
| Single lookup | Scan a QR code, type a serial, or type a hidden code; view the result |
| Bulk lookup | Up to 500 items in one request with a summary |
| Certificate | PDF of a lookup result, generated in the app, carrying the check's reference number |
| History | The official's own checks, or every official's checks, with filters |
| Incident reports | A note and up to 3 photos sent to the client's office; the official's own report list |
| Retail users | Pick a retail user for a report; add retail users; email a new first password |
| Profile | Name, role, organisation, support contact, change password, language, app version, logout |
| Request access | Opens an email to the client's office or shows its phone number (backend D27) |

Future features that need a backend route first (dashboard data, product list, in-app access request form) are listed in Section 20.4.

### 1.3 Out of Scope

| Excluded | Reason |
|---|---|
| Consumer verification | The app serves officials only. Consumers use the client's verification website. |
| Self sign-up | Accounts are created by the client's office. Request access opens an email or a call to that office (backend D27); it never creates an account. |
| Dashboard data, product list, access request form | No backend route exists. Future (Section 20.4). |
| Offline mode | Checks require a connection. Nothing is stored for later sending. |
| Barcode scanning | Only QR codes are scanned. Serials and hidden codes are typed. |
| GPS / phone location | The backend records network address and city only. No location permission. |
| Push notifications | Incidents are shown only in the client portal. |
| App attestation | The backend does not verify attestation tokens. |
| Consumer scan data | The app never shows consumer checks or consumer counts. |

### 1.4 Screens

| Screen | Purpose | Permission |
|---|---|---|
| Splash | Restore the session, load the profile. The look follows the Figma Landing Page: a dot pattern, the logo on a white card, "Track & Trace" and "Product Verification System", and a navy glow at the bottom holding "Verify genuine products instantly" and the progress (or the error with **Try again**, a white button). No page dots: there are no intro pages | — |
| Login | Email and password | — |
| Verify code | 6-digit code emailed for a new phone; resend with countdown | — |
| Change password | Forced after a first or admin-set password; also voluntary from Profile | — |
| Forgot password | Request an emailed reset code | — |
| Reset password | Code and new password | — |
| Request access | Shows the client's office email and phone; opens the mail app or the dialler (backend D27) | — |
| Verify (tab 1) | Welcome header, serial and hidden code entry, Scan QR, entry points to the features the role allows | — |
| History (tab 2) | The official's checks with filters, search, and totals; searching a serial shows every check of that item | `history:own` or `history:all` |
| Profile (tab 3) | Profile details, change password, support contact, app version, language, logout | — |
| QR scanner | Camera scan of the QR code (manual entry is on the Verify tab; **Enter manually** goes back to it) | `item:lookup` |
| Lookup result | Result, reasons, item details, reference number | `item:lookup` |
| Certificate | PDF preview and share | `item:lookup` |
| Bulk lookup | Build a list of up to 500 items, view summary and per-item results | `item:bulk_lookup` |
| Report incident | Note, optional check reference, optional retail user, up to 3 photos | `incident:report` |
| My reports | The official's own filed reports | `incident:report` |
| Retail users | Add a retail user; email a new first password | `retail_user:add` |

Item tracking (every check of one item) is the History tab searched by a serial (`GET checks?search=<serial>`, Section 13.4).

---

## 2. Technology Stack

### 2.1 Confirmed Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart) |
| Architecture | Clean Architecture, feature-first, with a dedicated service layer |
| State management | BLoC / Cubit (`flutter_bloc`), event transformers (`bloc_concurrency`) |
| Navigation | `go_router` (declarative routes, redirect guard, named routes) |
| HTTP client | Dio |
| Data access | Repository pattern with typed models |
| Pagination | Cursor-based (`limit` + opaque `cursor` / `next_cursor`) |
| Localization | English (`en`) and Bangla (`bn`) via ARB files |
| Component library | Material 3 (built into the Flutter SDK) |
| Theming | Design tokens in `shared/design_system/` (single source of truth) |
| Icons | `lucide_icons_flutter` |
| Loading skeletons | `skeletonizer` |
| Animations | `flutter_animate` |

### 2.2 Packages

Every plugin is wrapped by a core service (Section 5); features never import a plugin directly. Exact versions are fixed in `pubspec.lock` when the project is created and are upgraded on purpose, never automatically.

| Concern | Package | Wrapped by / used in |
|---|---|---|
| State management | `flutter_bloc`, `bloc_concurrency` | Presentation layer |
| Navigation | `go_router` | `app/router/` |
| Dependency injection | `get_it` (manual registration, no code generation) | `app/bootstrap.dart` only |
| HTTP | `dio` | `core/network/` |
| Data models | `freezed`, `json_serializable` (with `build_runner`) | DTOs, entities, BLoC events and states |
| Secure storage | `flutter_secure_storage` (Keychain / Keystore) | `SecureStorageService` |
| Preferences | `shared_preferences` | `PreferencesService` |
| Connectivity | `connectivity_plus` | `ConnectivityService` |
| QR scanner | `mobile_scanner`, limited to the QR format | `ScannerService` |
| Permissions | `permission_handler` 12.x (13.x needs Android Gradle Plugin 9; the project uses AGP 8) | `PermissionService` |
| Photo picking | `image_picker` | `PhotoService` |
| Photo compression | `flutter_image_compress` (2048 px, JPEG quality 85, HEIC → JPEG, orientation applied, EXIF not kept) | `PhotoService` |
| PDF | `pdf` 3.12 (generation), `printing` (preview); `image` pinned to 4.5.4 so `pdf` builds with this Dart SDK. The certificate embeds a bundled TTF font: the PDF's built-in fonts have no Unicode (no Bangla, no "…"). | `PdfService` |
| Temporary files | `path_provider` | `PdfService`, `PhotoService` |
| Sharing | `share_plus` | `ShareService` |
| Mail and phone links | `url_launcher` | `LauncherService` |
| App version | `package_info_plus` | `AppInfoService` |
| Crash reporting | `firebase_core`, `firebase_crashlytics` | `CrashReportingService` |
| Logging | `logger` | `LoggerService` (redaction, Section 12.2) |
| Localization | `flutter_localizations`, `intl` (Flutter `gen-l10n`) | `lib/l10n/` |
| Time zone | `timezone` (`Asia/Dhaka`) | `core/utils/` date formatting (Section 16) |
| Current time | `clock` (`clock.now()` instead of `DateTime.now()`, so tests can move time) | `Retry-After` countdowns, resend wait, photo window, date pickers |
| Icons, skeletons, animations | `lucide_icons_flutter`, `skeletonizer`, `flutter_animate` | `shared/design_system/` |
| Fonts | Bundled font files with Bangla support (from the client's brand assets), no runtime download | `shared/design_system/tokens/app_typography.dart` |

No local database is used (Section 1.3, offline mode excluded). No analytics SDK is used in v1.

### 2.3 Development Tooling

| Concern | Choice |
|---|---|
| Flutter SDK version | Pinned with FVM (`.fvmrc`) to the latest stable release at project creation |
| Code quality | `very_good_analysis` lint rules; `dart format`; zero analyzer warnings in CI |
| Code generation | `build_runner`; generated files are committed |
| Testing | `flutter_test`, `bloc_test`, `mocktail`, `http_mock_adapter` (Dio), `integration_test` |
| App identity | "Track & Trace"; ID `com.ziskapharma.trackandtrace` (`.mock`, `.staging` suffixes) |
| Environments | Flavors `mock`, `staging`, `live` (separate app IDs, so builds install side by side; Android forbids flavor names starting with `test`, so the build for the backend's test server is `staging`) with `--dart-define-from-file=config/<flavor>.json` for the base URL and slug (Section 17) |
| CI/CD | GitHub Actions: format, analyze, test, and build on every pull request; release builds signed in CI |
| Release builds | `--obfuscate --split-debug-info`; debug symbols uploaded to Crashlytics |
| Backend documents | The API guide, build guide, Postman collection, and environments are copied into `docs/protectb-api/` in the app repository (backend build guide) |

---

## 3. Engineering Principles (SOLID)

| Principle | Rule in this codebase |
|---|---|
| Single Responsibility | Each class has one reason to change (one BLoC per feature flow, one use case per action, one service per external system or backend resource). |
| Open / Closed | Classes are open for extension and closed for modification. New behavior is added through new implementations, not by editing existing ones. |
| Liskov Substitution | Any repository or service implementation (real, mock, fake) can replace its interface without changing behavior expected by callers. |
| Interface Segregation | Repository and service interfaces are small and focused. No class depends on methods it does not use. |
| Dependency Inversion | High-level layers depend on abstractions (interfaces), never on concrete implementations or plugins. |

---

## 4. Architecture

### 4.1 Clean Architecture Layers

| Layer | Contains | Depends on |
|---|---|---|
| Presentation | Screens, widgets, BLoC / Cubit | Domain, core service interfaces |
| Domain | Entities, repository interfaces, use cases, domain services, business rules | Nothing (pure Dart) |
| Data | Repository implementations, API services, DTO models, mappers | Domain, core |
| Core (cross-cutting) | Core services, Dio client, errors, security, constants, utils | Nothing from `features/` |

### 4.2 Dependency Rule

Dependencies point inward, toward the domain.

```
presentation ──► domain ◄── data ──► backend
      │                       │
      └──────► core ◄─────────┘
```

- The domain layer is pure Dart. It does not import Flutter, Dio, plugins, JSON code, or core services. It imports only the pure-Dart parts of core: `core/errors/` (`Result`, `Failure`) and `core/pagination/` (`CursorPage`, `PageRequest`).
- The data layer implements the repository interfaces defined in the domain layer.
- The presentation layer depends on the domain layer and never imports from the data layer.
- DTOs (`data/models/`) are converted to entities (`domain/entities/`) by mappers (`data/mappers/`) inside the repository implementation.
- Features never import a plugin directly. Every plugin is wrapped by a core service interface.
- `core/` never imports from `features/`.
- The composition root (`app/bootstrap.dart`) is the only place that wires implementations to interfaces.
- Features do not import each other's internals. Cross-feature code lives in `core/` or `shared/`.
- `app/router/` is the only place that imports feature screens to build routes. Features navigate by route name constants from `core/navigation/` (Section 9).
- One exception to feature isolation: the profile feature's `ProfileCubit` and `Profile` entity are the app-wide "current official" (Section 5.9). Other features, `shared/` widgets such as `PermissionGate`, and the router guard may read them. Any other cross-feature action is passed in by the router as a callback (for example Logout on Home).

### 4.3 Request Flow

Every feature follows the same request flow:

```
Screen / Widget
      │  dispatches event (BLoC) / calls method (Cubit)
      ▼
BLoC / Cubit ───────────────────► Core Service (app-wide: connectivity, scanner, permission, photo, PDF)
      │  calls
      ▼
Use Case ───────────────────────► Domain Service (pure Dart, e.g. CodeParser)
      │  calls
      ▼
Repository Interface              (domain)
      │  implemented by
      ▼
Repository Implementation ──────► Core Service (SessionService, LoggerService)
      │  (data)                   maps DTO → Entity, AppException → Failure
      │  calls
      ▼
API Service                       (data/services) — returns DTOs, throws AppException
      │
      ▼
Dio HTTP Client                   (core/network) — envelope parsing, auth, renewal, errors, timeouts, cancellation
      │  HTTPS
      ▼
mobile-app-api  {base}/v1/clients/{slug}/…
```

The result travels back up the same path. The BLoC / Cubit emits a new state and the UI rebuilds automatically.

---

## 5. Service Layer

### 5.1 Definition

A service is a class that communicates with exactly one external system: the backend, the device platform, storage, or a third-party SDK. Services contain no business logic and no UI state. Every service is defined as an interface (`abstract interface class`) with a separate implementation.

### 5.2 Service Types

| Type | Location | Responsibility |
|---|---|---|
| API service | `features/<name>/data/services/` | HTTP calls for one backend resource through the Dio client. Returns DTOs and throws `AppException` subtypes. |
| Core service | `core/services/` | App-wide infrastructure. Wraps one plugin or SDK. Feature-agnostic. |
| Domain service | `features/<name>/domain/services/` | Pure Dart business logic shared by multiple use cases. No I/O. |

### 5.3 Call Rules

| Caller ↓ / Callee → | Use case | Repository | Domain service | API service | Core service |
|---|---|---|---|---|---|
| Widget | ✗ | ✗ | ✗ | ✗ | ✗ |
| BLoC / Cubit | ✓ | ✗ | ✗ | ✗ | ✓ (app-wide only: connectivity, scanner, permission, photo, PDF, share) |
| Use case | ✗ | ✓ | ✓ | ✗ | ✗ |
| Repository implementation | ✗ | ✗ | ✗ | ✓ | ✓ |
| API service | ✗ | ✗ | ✗ | ✗ | ✗ (Dio client only) |
| Core service | ✗ | ✗ | ✗ | ✗ | ✓ (e.g. `LoggerService`) |

Forbidden patterns:

- A service calling a repository.
- A service holding UI state.
- Business rules inside an API service.
- A single shared `ApiService` for all endpoints.
- A core service importing from `features/`.
- A domain service depending on any core service.

### 5.4 Error Flow

```
HTTP error / DioException / plugin exception
      │  converted inside the Dio client or the core service
      ▼
AppException subtype (core/errors)        ← one type per API error.code (Section 15.4)
      │  caught inside the repository implementation
      ▼
Result: Success(entity) | Failure(type)   ← repositories never throw
      │
      ▼
BLoC / Cubit maps Failure → state → localized message + "Reference: {request_id}"
```

- Every `AppException` carries the HTTP status, `error.code`, the server message, `request_id`, and for `429` the `Retry-After` seconds.
- Decisions are made on `error.code`, `data.status`, `data.result`, and `data.reasons`, never on message text.

### 5.5 Session Handling

`SessionService` (`core/services/session/`) owns the authenticated session so that `core/network` does not depend on the authentication feature. The full rules are in Section 6.

- Reads, writes, and clears the access and refresh passes through `SecureStorageService`.
- Renews the access pass on `401 token_expired` only, on a separate Dio instance without the auth interceptor.
- Renewal is single-flight, app-wide: concurrent `token_expired` responses wait for one renewal; each failed request is retried once.
- On `401 unauthenticated` (any route, including renewal) clears both passes, keeps the phone ID, and emits `unauthenticated`.
- Exposes the session state stream (Section 6.7) consumed by the router guard (Section 9.4).

### 5.6 Core Services

| Service | Wraps | Used by |
|---|---|---|
| `SecureStorageService` | Secure storage plugin (Keychain / Keystore) | `SessionService`, `PhoneIdService` |
| `PreferencesService` | Key-value storage | Profile (language, theme) |
| `SessionService` | Passes, renewal, session state stream | Auth interceptor, router guard, auth repository |
| `PhoneIdService` | Secure random generator + secure storage | Auth repository (login, verify code) |
| `ConnectivityService` | Connectivity plugin | `NetworkStatusBanner` cubit |
| `ScannerService` | QR scanner plugin | Lookup and bulk lookup BLoCs (start, stop, torch, scan stream) |
| `PermissionService` | Camera and photo library permissions | Lookup BLoC, report BLoC |
| `PhotoService` | Image picker + compression (2048 px, JPEG quality 85, HEIC → JPEG, all metadata removed) | Report BLoC |
| `PdfService` | PDF generation | Certificate cubit |
| `ShareService` | Platform share sheet | Certificate cubit |
| `LauncherService` | URL launcher plugin, limited to `mailto:` and `tel:` | Request access cubit |
| `LoggerService` | Logging with sensitive-data redaction (Section 12.2) | All layers except domain |
| `CrashReportingService` | Monitoring SDK | Bootstrap, `LoggerService` |
| `AppInfoService` | App version and build information | Profile |

### 5.7 Feature Services

| Feature | API service | Routes | Domain service |
|---|---|---|---|
| authentication | `AuthApiService` | `auth/login`, `auth/verify-phone`, `auth/resend-code`, `auth/logout`, `auth/password/forgot`, `auth/password/reset`, `me/password` | `PasswordPolicy` |
| profile | `ProfileApiService` | `GET me` | — |
| verification | `VerificationApiService` | `GET formats`, `POST lookups`, `POST lookups/bulk` | `QrLinkParser`, `CodeNormalizer`, `InputFormatValidator` |
| certificate | — (uses `PdfService`, `ShareService`) | — | `CertificateComposer` |
| history | `HistoryApiService` | `GET checks` | — |
| incidents | `IncidentApiService` | `POST incidents`, `POST incidents/{id}/photos`, `GET incidents` | — |
| retail_users | `RetailUserApiService` | `GET retail-users`, `GET retail-roles`, `POST retail-users`, `POST retail-users/{id}/password` | — |
| home | — | — (permissions from `GET me` via `ProfileCubit`) | — |

`auth/refresh` is called only by `SessionService` (Section 5.5), never by a feature.

### 5.8 Naming Convention

- Interface: `<Name>Service` — e.g. `SecureStorageService`.
- Implementation: named after its technology — e.g. `FlutterSecureStorageService implements SecureStorageService`. The `Impl` suffix is not used for services.
- API service implementation: `Dio<Name>ApiService implements <Name>ApiService` — e.g. `DioVerificationApiService`.
- File names: `<name>_service.dart` for the interface, `<technology>_<name>_service.dart` for the implementation.

### 5.9 Registration and Lifecycle

All registration happens in the composition root (`app/bootstrap.dart`).

| Type | Lifetime |
|---|---|
| Core services | Lazy singleton. Services that require setup (preferences, crash reporting, phone ID, session restore) are initialized before `runApp`. |
| API services | Singleton |
| Domain services | Singleton (stateless) |
| Repositories | Singleton |
| Use cases | Factory |
| BLoCs / Cubits | Factory, scoped to the screen (created in the route builder, Section 9.5) |
| `ProfileCubit` | App-scoped, provided above `MaterialApp.router`: read by the router guard and `PermissionGate` |
| `GoRouter`, `RouteGuard` | Singleton, created after session restore starts |

Services that expose streams (`ConnectivityService`, `ScannerService`, `SessionService`) implement `dispose()`.

---

## 6. Authentication and Session

### 6.1 Phone ID

- Generated once, on the first run: 32 bytes from a secure random source, encoded base64url (43 characters of `A–Z a–z 0–9 _ -`).
- Stored in secure storage by `PhoneIdService`.
- Sent with every `auth/login` and `auth/verify-phone`.
- Never regenerated on logout, app update, or error. A new phone ID is a new phone and requires an emailed code.
- An official has at most 3 trusted phones; logging in on a 4th forgets the one used longest ago.

### 6.2 Login Flow

```
Login screen
   │  POST auth/login { email, password, phone_id }
   ▼
data.status
   ├── "logged_in" ──► store both passes ──┐
   │                                        │
   └── "code_sent" ──► keep challenge_id    │
                        │                   │
                        ▼                   │
                 Verify code screen         │
                   POST auth/verify-phone   │
                   { challenge_id, code, phone_id }
                        │  200: logged_in   │
                        └──► store passes ──┤
                                            ▼
                               must_change_password?
                                 ├── true  ──► Change password screen (only screen allowed)
                                 └── false ──► GET me ──► Home
```

| Rule | Detail |
|---|---|
| Branching | Decided by `data.status`, never by the message (identical for both). |
| Failed login | One message for every `401 unauthenticated`: "Email or password is incorrect." (unknown email, wrong password, blocked, and locked accounts answer the same on purpose). |
| Lockout | 5 wrong passwords lock the account for 15 minutes; the answer stays the same `401`. |
| Code | Exactly 6 digits; lives 5 minutes; 5 tries. A wrong, expired, or used code is `401`. 10 wrong codes in an hour lock the account for 15 minutes. |
| Resend code | `POST auth/resend-code { challenge_id }`: at most once a minute (countdown from `Retry-After`), 3 times in total, then back to Login. |
| Rate limit | `429 rate_limited` shows a countdown from `Retry-After`. |

### 6.3 Passes

| Pass | Lifetime | Sent in | Stored in |
|---|---|---|---|
| `access_token` | 15 minutes | `Authorization: Bearer` header of every request | Secure storage |
| `refresh_token` | 30 days unused; replaced at every use; a login lasts at most 1 year | Body of `auth/refresh` only | Secure storage |

No cookies are sent or read. Passes are never written to plain storage or logs.

### 6.4 Renewal Rules

1. A request answers `401 token_expired`.
2. `SessionService` starts one renewal (`POST auth/refresh { refresh_token }`, no `Authorization` header). Concurrent failures wait for the same renewal.
3. On `200`, both new passes are stored before anything else.
4. Each waiting request is retried once.
5. On `401 unauthenticated` from renewal: clear both passes, keep the phone ID, emit `unauthenticated`.

A refresh pass works exactly once. Sending a used refresh pass ends the login on the server.

### 6.5 Session End Events

The next request answers `401 unauthenticated` and the app returns to Login when:

- 30 days pass without a renewal, or a year passes since login;
- the official logs out (`POST auth/logout`: delete both passes; the phone stays trusted);
- the client's admin blocks the official, logs out all phones, changes the role, or sets a new password;
- the official resets a forgotten password (every phone);
- the official changes the password (every other phone).

### 6.6 Password Flows

| Flow | Routes | Rules |
|---|---|---|
| Forced change | `POST me/password` | While `must_change_password` is true, every route except `me`, `me/password`, and `auth/logout` answers `403 password_change_required`. |
| Voluntary change | `POST me/password { old_password, new_password }` | `200` returns a new access pass only; the refresh pass stays. Other phones are logged out. Wrong old password is `401`. |
| Forgotten password | `POST auth/password/forgot { email }` → `POST auth/password/reset { email, code, new_password }` | Forgot always answers `200` with "If the address has an account, a code was sent." Reset ends every login and forgets every trusted phone; the app returns to Login. |
| First password | Typed by whoever creates the account; emailed by the backend or handed over in person (`send_email`) | Must be changed at first login. Has no end date: it works until it is used. A new phone still needs the emailed code. |

Password rule (backend D54), applied to every password an official chooses: the forced change, a voluntary change, and the forgotten-password reset. `PasswordPolicy` (domain service) checks it before sending; the server is final.

| Rule | Fails | Passes |
|---|---|---|
| 8 to 128 characters | `abc123` | `abcd1234` |
| At least one letter (any alphabet, Bangla included) | `12345678` | `a2345678` |
| At least one number (any digit) | `password` | `password1` |

- Spaces, symbols, and capitals are allowed and never required. There is no common-password list and no check against the email.
- Line breaks, tabs, and other control characters are refused.
- Length is counted in characters, never in bytes.
- Every new-password screen shows the three rules under the field before typing starts, each with a mark that turns to ✓ when met: "8 characters or more", "a letter", "a number". The submit button stays disabled until all three are met.
- `AppPasswordField` offers "show password". A repeat-password field, when the design has one, is matched in the app; the API receives the password once.
- `403 policy_denied` does not say which rule failed. It means the app's check and the server's differ: the app shows the three rules again and logs the `request_id`.
- A first password typed when creating an account (a retail user, Section 13.6) is not checked against this rule: it needs only 1 to 128 characters with no control characters.

### 6.7 Session States and Routing

| State | Meaning | Screens allowed |
|---|---|---|
| `unauthenticated` | No valid session | Login, Verify code, Forgot password, Reset password, Request access |
| `awaitingCode` | `code_sent` received; holds `challenge_id` and the email | Verify code ("Back to login" cancels the code first) |
| `passwordChangeRequired` | Logged in with `must_change_password: true` | Change password, Logout |
| `authenticated` | Logged in, password accepted | Every screen the role's permissions allow (Section 7) |

The router guard listens to `SessionService` and redirects whenever the state changes (Section 9.4). Screens never navigate to Login themselves: login, logout, and every `401 unauthenticated` move the official through the guard. `GET me` is called at start: `401` means the login ended.

---

## 7. Permissions

### 7.1 Permission Catalogue

| Permission | Opens |
|---|---|
| `item:lookup` | Single lookup (scan, serial, hidden code), result, certificate |
| `item:bulk_lookup` | Bulk lookup |
| `history:own` | History of the official's own checks |
| `history:all` | Every official's checks (`scope=all`) and the names of earlier checkers (`count.by`) |
| `incident:report` | Report incident, photos, My reports, retail user picker |
| `retail_user:add` | Add retail users, email a new first password, retail user picker |

### 7.2 Rules

- Permissions come from `GET me` (`data.permissions`). They are held in memory by the profile state.
- A feature's entry point and screen are shown only when its permission is listed.
- The profile is loaded at start, after login, and after any `403 forbidden`.
- A role change takes effect on the server within a minute.
- An empty permission list is valid: the official can log in and sees no features.
- A retail role normally has `history:own` (backend D53): the retail user (Retail seller, Senior seller) then has the History tab with their own checks only, without "Everyone's checks" or other officials' names. When the client's admin unticks it, the tab is hidden; no check is kept on the phone instead (Section 1.3).
- The server enforces every permission; the UI gating hides what the role cannot use.

---

## 8. State Management

State management uses BLoC / Cubit exclusively.

| Type | Used for |
|---|---|
| BLoC | Event-driven flows (login, lookup, bulk lookup, report filing, paginated lists: history, my reports, retail user picker) |
| Cubit | Method-driven simple state (profile, settings, certificate, connectivity, local UI state) |

### 8.1 Lifecycle

```
Event  ──►  Logic  ──►  State  ──►  UI
```

| Step | Examples |
|---|---|
| Event | User presses login, user scans a QR code, data requested |
| Logic | API calls, validation, business rules (executed through use cases) |
| State | Loading, success, failure |
| UI | Rebuilds automatically from the emitted state |

### 8.2 State Categories

Loading, success, failure, session state, pagination, async API data.

### 8.3 Event Concurrency

| Event | Transformer | Reason |
|---|---|---|
| Lookup, bulk lookup, report filing, login | `droppable` | Every lookup is a recorded check and every report is a new record: duplicates are never sent. |
| First page (open, filter change, refresh) | `restartable` | Only the latest query matters; an older request in flight is cancelled. |
| Search text (history, retail user picker) | debounce 400 ms + `restartable` | One request after typing pauses. |
| Next page | `droppable` | One page request at a time (Section 10). |

### 8.4 Lookup Example

```
User scans QR
      │
      ▼
Event: LookupRequested(way: qr, value)
      │
      ▼
State: LookupInProgress            → loading indicator shown
      │
      ├──► State: LookupCompleted(result)   → valid / warning / not_found / unassigned
      └──► State: LookupFailed(failure)     → error message + reference
```

### 8.5 File Convention

Each BLoC is split into three files inside `presentation/bloc/`:

```
lookup_bloc.dart
lookup_event.dart
lookup_state.dart
```

---

## 9. Navigation

Navigation uses `go_router`. One `GoRouter` instance is created in the composition root and lives in `app/router/`.

### 9.1 Router Files

| File | Responsibility |
|---|---|
| `app/router/app_router.dart` | Builds the `GoRouter`: route tree, `redirect`, `refreshListenable`, `errorBuilder`, observers |
| `app/router/route_paths.dart` | Path constants, used only inside `app/router/` |
| `app/router/route_guard.dart` | `RouteGuard`: pure redirect decision from session state, profile permissions, and location (Section 9.4) |
| `app/router/router_refresh.dart` | `Listenable` that merges the `SessionService` state stream and profile permission changes |
| `app/router/app_navigation_observer.dart` | Logs route names through `LoggerService` and adds crash-reporting breadcrumbs |
| `core/navigation/route_names.dart` | Route name constants used by features (`RouteNames.lookup`, …) |

### 9.2 Route Tree

After login the app shows a bottom navigation bar with three tabs: Verify, History, Profile. The tabs are a `StatefulShellRoute.indexedStack`: each tab keeps its own navigation stack and scroll position. Full-screen flows open on the root navigator, above the bar.

```
/splash                              Splash
/login                               Login
   └── verify-code                   Verify code
/forgot-password                     Forgot password
   └── reset                         Reset password
/request-access                      Request access
/change-password                     Change password (forced or voluntary)

Bottom navigation (StatefulShellRoute, one branch per tab)
├── /home                            Tab 1  Verify
├── /history                         Tab 2  History
└── /profile                         Tab 3  Profile

Full-screen flows (root navigator, bottom bar hidden)
/home/scan                           QR scanner
/home/result                         Lookup result
   └── certificate                   Certificate
/home/bulk-lookup                    Bulk lookup
/home/reports                        My reports
   └── new                           Report incident
/home/retail-users                   Retail users
```

The retail user picker is a modal bottom sheet opened from Report incident. It is not a route.

### 9.3 Route Table

| Name | Path | Session state | Permission | Parameters |
|---|---|---|---|---|
| `splash` | `/splash` | any | — | — |
| `login` | `/login` | `unauthenticated` | — | — |
| `verifyCode` | `/login/verify-code` | `awaitingCode` | — | — (`challenge_id` and the email come from the session state) |
| `forgotPassword` | `/forgot-password` | `unauthenticated` | — | — |
| `resetPassword` | `/forgot-password/reset` | `unauthenticated` | — | `extra`: the email entered on Forgot password |
| `requestAccess` | `/request-access` | `unauthenticated` | — | — |
| `changePassword` | `/change-password` | `passwordChangeRequired`, `authenticated` | — | — (forced or voluntary is read from the session state) |
| `home` | `/home` (tab 1, Verify) | `authenticated` | — (its sections are gated, Section 13.7) | — |
| `history` | `/history` (tab 2) | `authenticated` | `history:own` or `history:all` | query `search` (a serial or a reference number, optional) |
| `profile` | `/profile` (tab 3) | `authenticated` | — | — |
| `scan` | `/home/scan` | `authenticated` | `item:lookup` | — |
| `lookupResult` | `/home/result` | `authenticated` | `item:lookup` | `extra`: `LookupResult` |
| `certificate` | `/home/result/certificate` | `authenticated` | `item:lookup` | `extra`: `LookupResult` |
| `bulkLookup` | `/home/bulk-lookup` | `authenticated` | `item:bulk_lookup` | — |
| `myReports` | `/home/reports` | `authenticated` | `incident:report` | — |
| `reportIncident` | `/home/reports/new` | `authenticated` | `incident:report` | query `check_ref` (from a lookup result) |
| `retailUsers` | `/home/retail-users` | `authenticated` | `retail_user:add` | — |

#### 9.3.1 Bottom Navigation

| Tab | Icon | Shown when | Content |
|---|---|---|---|
| Verify | shield-check | always | Welcome header; serial and hidden code entry, Scan QR; entry points to bulk lookup, report incident, my reports, retail users, each gated by its permission (Section 13.7) |
| History | clock | `history:own` or `history:all` | The official's checks with filters, search, and totals; a serial search is the item's tracking log (Section 13.4) |
| Profile | user | always | Profile details, change password, support contact, app version, language, logout (Section 13.8) |

- A tab whose permission the profile lacks is not shown; the remaining tabs keep their order.
- Tapping the current tab returns it to its first screen.
- Android back on a tab's first screen leaves the app; on another tab's first screen it returns to Verify.
- `MainShell` (`app/shell/main_shell.dart`) builds the bar from the profile's permissions.

### 9.4 Route Guard

`RouteGuard` runs on every navigation and every time `refreshListenable` fires. It returns the location to redirect to, or `null` to stay.

| Session state | Requested location | Result |
|---|---|---|
| Not yet emitted (start-up) | any | `/splash` |
| `unauthenticated` | `/login`, `/forgot-password`, `/forgot-password/reset`, `/request-access` | stay |
| `unauthenticated` | any other | `/login` |
| `awaitingCode` | `/login/verify-code` | stay |
| `awaitingCode` | any other | `/login/verify-code` |
| `passwordChangeRequired` | `/change-password` | stay |
| `passwordChangeRequired` | any other | `/change-password` |
| `authenticated`, profile not loaded | any | `/splash` |
| `authenticated` | `/splash` or a pre-login route | `/home` |
| `authenticated` | a route whose permission the profile does not list | `/home` |
| `authenticated` | a permitted route | stay |

- `RouteGuard` is a pure class with no Flutter navigation calls: `redirect(sessionState, permissions, location)` → `String?`.
- `refreshListenable` fires on every session state change and on every permission change (a role change or a `403 forbidden` profile reload, Section 7.2). An official whose role loses a permission is moved to Home.
- Permissions are read from `ProfileCubit`, which is app-scoped (Section 5.9).

### 9.5 Navigation Rules

| Rule | Detail |
|---|---|
| Named routes | Features navigate with `context.goNamed` / `context.pushNamed` and `RouteNames` constants. No raw path string is used outside `app/router/`. |
| `go` and `push` | `pushNamed` drills down (Home → feature, Lookup → Result → Certificate); `pop` returns. `goNamed` replaces the stack (back to Home from the end of a flow). |
| Session moves | Only the guard moves between session areas (Login, Verify code, Change password, Home). Screens never navigate after login, logout, or a session error. |
| BLoC and navigation | BLoCs and Cubits never navigate and hold no `BuildContext`. A screen navigates in a `BlocListener` when its state changes (for example `LookupCompleted` → `lookupResult`). |
| Screen scope | Each route builder creates its screen's BLoC with `BlocProvider` from the composition root. The BLoC closes when the route is removed. |
| Parameters | Path and query parameters carry only non-sensitive values (`check_ref`, a serial search). Entities travel in `extra` as typed classes. Hidden codes, passwords, emailed codes, passes, and the phone ID never appear in a path, a query, or `extra`. |
| Missing `extra` | A route whose required `extra` is missing (the system restored the app) redirects to its parent route. |
| Back | Android back pops the current route; on Home it leaves the app. On a forced Change password, back is blocked (`PopScope(canPop: false)`); Logout is the only way out. |
| Unknown route | `errorBuilder` shows `AppErrorState` "Not available" with a Home action. |
| Deep links | No deep links or app links are registered. QR links belong to the client's verification website and are never opened by the app (Section 12.1). |
| Observer | `AppNavigationObserver` logs route names only — never parameters or `extra`. |

---

## 10. Pagination

Every list loaded from the backend uses cursor-based pagination. Offsets and page numbers are not used.

### 10.1 Paginated Lists

| List | Route | Screen | BLoC | Filters | Extra data |
|---|---|---|---|---|---|
| History | `GET checks` | History | `HistoryBloc` | `result`, `way`, `from`, `to`, `search`, `scope` | `totals` on the first page only |
| My reports | `GET incidents` | My reports | `MyReportsBloc` | — | — |
| Retail user picker | `GET retail-users` | Retail user picker (bottom sheet) | `RetailUserPickerBloc` | `search` | — |

### 10.2 Contract Rules

| Item | Rule |
|---|---|
| `limit` | 1 to 100. The app sends 50 (`PageRequest.defaultLimit`). |
| `cursor` | Not sent on the first page. On every later page: the previous page's `next_cursor`, sent back unchanged. |
| `next_cursor` | An opaque string. Never parsed, compared, built, or stored outside the list's state. A numeric-looking value (`"3255"`) stays a string. |
| End of list | `next_cursor: null`. A full page always returns a cursor, so the last request can return an empty page with `next_cursor: null`. |
| Filters and cursor | A cursor belongs to the filters that produced it. Any filter, search, or scope change discards the loaded items and the cursor and starts again from the first page. |
| Query parameters | Only documented parameters are sent. Empty filters are omitted (no empty `search=`). A malformed parameter answers `400 validation_failed`, an app defect that is logged. |
| Response key | The list key differs per route: `checks` (`GET checks`), `reports` (`GET incidents`), `retail_users` (`GET retail-users`). Each DTO reads its own key. |

### 10.3 Types per Layer

| Layer | Type | Location |
|---|---|---|
| Data | Page DTO per list (`ChecksPageDto`, `ReportsPageDto`, `RetailUsersPageDto`) with `next_cursor` | `features/<name>/data/models/` |
| Data | Mapper DTO → `CursorPage<T>` | `features/<name>/data/mappers/` |
| Domain | `PageRequest { limit, cursor }` | `core/pagination/page_request.dart` |
| Domain | `CursorPage<T> { items, nextCursor, hasMore }` (`hasMore` = `nextCursor != null`) | `core/pagination/cursor_page.dart` |
| Domain | `CheckPage { CursorPage<Check> page, CheckTotals? totals }` | `features/history/domain/entities/` |
| Domain | Repository method, for example `Future<Result<CheckPage>> getChecks(CheckQuery query, PageRequest page)` | `features/<name>/domain/repositories/` |
| Presentation | `PaginatedState<T> { items, nextCursor, status, hasReachedEnd, failure }` | `core/pagination/paginated_state.dart` |
| Presentation | `AppPaginatedList<T>` | `shared/widgets/app_paginated_list.dart` |

### 10.4 Pagination Status

| `PaginationStatus` | Meaning | UI |
|---|---|---|
| `initial` | Nothing requested yet | — |
| `loadingFirst` | First page in flight | `AppSkeleton` list |
| `success` | Items shown | List; end marker when `hasReachedEnd` |
| `loadingMore` | Next page in flight | List with a loading footer |
| `empty` | First page returned no items | `AppEmptyState` (filter-aware text on History) |
| `failureFirst` | First page failed | `AppErrorState` with `ReferenceText` and Retry |
| `failureMore` | Next page failed | Loaded items kept; footer with Retry, or `RetryCountdown` for `429` |

### 10.5 Flow

```
Screen opens / filter or search changes / pull to refresh
      │  FirstPageRequested(query)                          restartable
      ▼
cursor = null, totals = null                       → loadingFirst
      │  GET <route>?limit=50&<filters>
      ▼
success: items = page.items
         nextCursor = next_cursor
         totals = page totals (History only)
         hasReachedEnd = next_cursor == null
      │
      │  list scrolled to within 5 items of the end
      ▼
NextPageRequested                                         droppable
      │  ignored when hasReachedEnd, loadingFirst, or loadingMore
      ▼
GET <route>?limit=50&<same filters>&cursor=<nextCursor>   → loadingMore
      │
      ├── success: append items; nextCursor = next_cursor; next_cursor null → hasReachedEnd
      └── failure: failureMore; items kept; Retry sends the same cursor again
```

### 10.6 Rules

- `totals` (History) come from the first page, stay unchanged while later pages load, and are cleared with every new first page. They count every check matching the filters, not only the loaded items.
- A filter or search change clears the list at once. Pull to refresh keeps the current list visible until the new first page arrives, then replaces it.
- One next-page request at a time; no page is fetched before the official scrolls near the end.
- A `429` on any page shows `RetryCountdown`; the page is never retried in a loop.
- Pages live only in the BLoC state for the screen's lifetime. Nothing is cached or stored on the phone (Section 1).
- `AppPaginatedList<T>` builds every status in Section 10.4 and dispatches next-page, retry, and refresh through callbacks. Feature screens do not build pagination UI themselves.

---

## 11. Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── route_paths.dart
│   │   ├── route_guard.dart
│   │   ├── router_refresh.dart
│   │   └── app_navigation_observer.dart
│   ├── shell/
│   │   └── main_shell.dart            # bottom navigation (Section 9.3.1)
│   └── config/                        # base URL and client slug per environment
├── core/
│   ├── navigation/
│   │   └── route_names.dart
│   ├── pagination/
│   │   ├── page_request.dart
│   │   ├── cursor_page.dart
│   │   └── paginated_state.dart
│   ├── network/                       # Dio client, interceptors, envelope parsing, endpoints
│   ├── security/                      # input sanitizers, security configuration
│   ├── errors/                        # AppException types, Failure types, error codes
│   ├── constants/
│   ├── utils/
│   └── services/
│       ├── storage/
│       │   ├── secure_storage_service.dart
│       │   └── preferences_service.dart
│       ├── session/
│       │   ├── session_service.dart
│       │   └── session_state.dart
│       ├── device/
│       │   ├── phone_id_service.dart
│       │   └── app_info_service.dart
│       ├── connectivity/
│       │   └── connectivity_service.dart
│       ├── scanner/
│       │   └── scanner_service.dart
│       ├── permission/
│       │   └── permission_service.dart
│       ├── media/
│       │   └── photo_service.dart
│       ├── document/
│       │   ├── pdf_service.dart
│       │   └── share_service.dart
│       ├── launcher/
│       │   └── launcher_service.dart
│       ├── logging/
│       │   └── logger_service.dart
│       └── monitoring/
│           └── crash_reporting_service.dart
├── shared/
│   ├── widgets/
│   │   ├── app_scaffold.dart
│   │   ├── app_dialog.dart
│   │   ├── app_error_state.dart
│   │   ├── app_empty_state.dart
│   │   ├── app_paginated_list.dart
│   │   ├── network_status_banner.dart
│   │   ├── permission_gate.dart
│   │   ├── retry_countdown.dart
│   │   └── reference_text.dart
│   ├── extensions/
│   └── design_system/
│       ├── tokens/
│       │   ├── app_colors.dart
│       │   ├── app_spacing.dart
│       │   ├── app_radius.dart
│       │   └── app_typography.dart
│       ├── components/
│       │   ├── buttons/
│       │   │   ├── app_button.dart
│       │   │   └── app_icon_button.dart
│       │   ├── inputs/
│       │   │   ├── app_text_field.dart
│       │   │   ├── app_search_field.dart
│       │   │   ├── app_password_field.dart
│       │   │   └── app_otp_field.dart
│       │   ├── cards/
│       │   │   ├── app_card.dart
│       │   │   └── app_product_card.dart
│       │   └── loading/
│       │       ├── app_loading.dart
│       │       └── app_skeleton.dart
│       └── theme/
│           ├── app_theme.dart
│           └── component_themes.dart
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   └── auth_api_service.dart
│   │   │   ├── models/
│   │   │   ├── mappers/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   ├── services/
│   │   │   │   └── password_policy.dart
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── screens/
│   │       └── widgets/
│   ├── verification/
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   └── verification_api_service.dart
│   │   │   ├── models/
│   │   │   ├── mappers/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   ├── services/
│   │   │   │   ├── qr_link_parser.dart
│   │   │   │   ├── code_normalizer.dart
│   │   │   │   └── input_format_validator.dart
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/                  # lookup_bloc, bulk_lookup_bloc
│   │       ├── screens/               # verify_screen (tab 1), scanner_screen, lookup_result_screen
│   │       └── widgets/
│   ├── certificate/                   # domain/services/certificate_composer.dart
│   ├── history/
│   ├── incidents/
│   ├── retail_users/
│   ├── profile/
│   └── home/                          # future dashboard (Section 20.4)
└── l10n/
    ├── app_en.arb
    └── app_bn.arb

test/                  # mirrors lib/
├── app/               # includes router/ (RouteGuard tests)
├── core/              # includes pagination/
├── shared/            # includes design_system/
├── features/
└── fakes/             # fake implementations of every service interface

integration_test/
```

### 11.1 Folder Rules

| Folder | Responsibility |
|---|---|
| `app/` | Root app widget, bootstrap, routing, configuration. Dependency wiring (composition root) lives in `bootstrap.dart`. No theme code. |
| `app/shell/` | `MainShell`: the bottom navigation bar around the three tabs, built from the profile's permissions (Section 9.3.1). |
| `app/router/` | `GoRouter` configuration, route paths, route guard, refresh listenable, navigation observer (Section 9). The only folder that imports feature screens. |
| `app/config/` | Base URL and client slug per environment (Section 17), and the client office's email and phone for Request access (Section 13.9). Nothing else is hard-coded: formats and limits come from the API. |
| `core/navigation/` | Route name constants used by features. No widgets, no feature imports. |
| `core/pagination/` | Pure-Dart pagination types: `PageRequest`, `CursorPage<T>`, `PaginatedState<T>`, `PaginationStatus` (Section 10). |
| `core/` | Non-UI infrastructure shared by all features (network, security, errors, services). Never imports from `features/`. |
| `core/services/` | Core services. One subfolder per external system, each holding the interface and its implementation. |
| `shared/design_system/` | Tokens, theme, and primitive UI components. The only location for theme code. |
| `shared/widgets/` | Composite widgets reused across features. |
| `features/<name>/` | One folder per feature, each with `data/`, `domain/`, `presentation/`. Every feature follows the `authentication/` structure. |
| `features/<name>/data/services/` | API services for the feature's backend resources. |
| `features/<name>/domain/services/` | Domain services. Present only in features that have shared pure business logic. |

### 11.2 Naming Rules

- Folder and file names use `snake_case` with no spaces.
- Folders that collect many items of the same kind are plural (`features/`, `screens/`, `widgets/`, `services/`, `buttons/`, `inputs/`, `cards/`, `entities/`, `usecases/`).
- Folders named after a concern or module are singular (`network/`, `security/`, `theme/`, `router/`, `navigation/`, `pagination/`, `bloc/`, `loading/`).
- `test/` and `integration_test/` are lowercase, as required by Flutter tooling.
- Service naming follows Section 5.8.

---

## 12. Security Architecture

### 12.1 Coverage

| Area | Coverage |
|---|---|
| Transport | HTTPS / TLS to `mobile-app-api` behind Cloudflare, validated by the platform's trust store. Cleartext traffic is disabled (Android network security configuration, iOS App Transport Security). No certificate pinning in v1: Cloudflare manages and rotates the edge certificates. |
| Authentication | Email and password, emailed code per new phone, phone ID, forced password change (Section 6) |
| Session | 15-minute access pass, single-use refresh pass, single-flight renewal — managed by `SessionService` |
| Authorization | Every route except the login, code, renewal, and password-reset routes requires a valid access pass. The server enforces permissions; the UI hides what the role lacks (Section 7). |
| Input safety | Input normalized and checked against `GET formats`; values limited to 64 characters with no control characters |
| QR link safety | The QR link is never opened in the app. Only the value after the last `/q/` is sent. No deep links or app links are registered. |
| Navigation | Sensitive values never appear in route paths, query parameters, or `extra`; the navigation observer logs route names only (Section 9.5). |
| Hidden code protection | A typed hidden code is never stored, logged, or shown beyond the input screen. The API returns it masked (`*7K2`). |
| API protection | Server-side rate limits; the app honours `Retry-After` and never retries in a loop |
| Duplicate protection | Lookups and reports use `droppable` events; a report is never re-filed after a photo failure |
| Verification integrity | Results come from the backend only and are displayed unaltered. Unknown values fail safe (Section 13.1.5). |
| Local data | Only the phone ID, the two passes (secure storage), and preferences (language, theme) are stored. No item data, no check data, no queued scans. The product picture is kept in memory only, never on storage. |
| Product picture | Loaded over HTTPS only, without the access pass (not through the API client); a `picture_url` that is not `https://` is not requested (Section 13.1.4). |
| Logging | No sensitive data in logs or analytics (Section 12.2) |
| Photos | Compressed in the app; all metadata (EXIF: location, time, phone model) is removed before upload. Orientation is applied to the pixels first. |
| Device integrity | No root or jailbreak detection in v1. The API is protected server-side by login, the trusted-phone code, and rate limits (backend D35). Secrets stay in Keychain / Keystore. |
| External links | Only `mailto:` and `tel:` links to the client's office are opened (Request access, through `LauncherService`). QR links and every other link are never opened. |
| Reverse engineering | Release builds are obfuscated; no secrets are embedded in the app |
| Supply chain | Dependency safety |

### 12.2 Never Logged or Sent to Analytics

- access and refresh passes;
- passwords;
- emailed codes;
- hidden codes;
- the phone ID.

Logged instead: `request_id`, the route, and the HTTP status.

---

## 13. Feature Specifications

### 13.1 Single Lookup

#### 13.1.1 Lookup Ways

| `way` | `value` | Source |
|---|---|---|
| `qr` | The 12 characters after the last `/q/` in the QR link | Scanned QR code |
| `serial` | Digits only, as text (for example `"1000001"`) | Printed on the label, typed |
| `hidden_code` | The code under the scratch layer | Scratched off, typed |

#### 13.1.2 Lookup Flow

```
1. Input                                       (ScannerService / manual entry)
   - scan QR, or type serial, or type hidden code
        │
        ▼
2. Parse                                       (QrLinkParser)
   - QR: take the part after the last "/q/" (any host); never open the link
        │
        ▼
3. Normalize                                   (CodeNormalizer)
   - remove spaces and "-"; lowercase letters read as capitals
        │
        ▼
4. Validate                                    (InputFormatValidator, rules from GET formats)
   - reject input that matches no format of this client
        │
        ▼
5. Send                                        (VerificationApiService)
   - POST lookups { way, value }; droppable event; access pass attached
   - VerifyingView covers the screen when the answer takes over 300 ms
        │
        ▼
6. Backend checks the item and records the check
        │
        ▼
7. Display result                              (LookupResultScreen)
   - VerificationResultCard, item details, ProductPictureCard,
     reference number; for not_found: what was entered and hints
```

The verification loader (`VerifyingView`, decision 48) is a full-screen layer over the whole app (the root overlay, above the bottom bar and hidden from TalkBack underneath), shown by the Verify tab and the scanner when a lookup is still running after 300 ms; a faster answer goes straight to the result. It shows a filled navy shield with a white tick in a progress ring, "Checking the item…", and three steps: **Code format** is ticked from the start with a white tick in a filled green circle, since the input was checked on the phone against `GET formats` before sending, **Item record** and **Check count** show a navy dot in a pale circle until the answer arrives. The result opens and the loader goes; nothing is delayed to show the steps. A failure, or input refused before sending, closes the loader, and the error shows on the screen underneath (Section 13.1.6), the `429` countdown included. Back waits while the one request runs.

The scanner screen follows the Figma "scan by barcode", with QR wording (only QR codes are scanned, decision 38):

- The camera fills the screen. Around a square scan window (at most 280 px, smaller on short screens) it is dimmed in the scanner navy (`scannerBackground`) under a faint grid. The window has green corners (`scanAccent`) and a green scan line moving up and down; the line holds still when the phone's "Remove animations" is on.
- Above the window: **PLACE THE QR CODE INSIDE THE FRAME**. Below it: "Looking for a QR code · hold steady" with a green dot, or a spinner with "Verifying…" while a lookup runs. A refused code or failed lookup shows the error banner there instead.
- At the top: back and "Scan QR code". At the bottom: **Enter manually**, which goes back to the Verify tab with the code field focused, and the torch (the only torch control).
- When the camera fails (access refused, no camera), its message fills the screen with no frame over it; **Enter manually** stays and the torch is hidden.

#### 13.1.3 Input Formats

- `GET formats` returns the client's formats: one or more hidden code formats (length, characters), serial `max_digits`, and the QR format.
- Formats are loaded after login and kept in memory for the session.
- Lengths and character sets are never hard-coded: they differ between clients and can change.

#### 13.1.4 Results

| `result` | Meaning | Data returned |
|---|---|---|
| `valid` | Genuine, first check by any official, nothing wrong | `ref`, `item`, `count` |
| `warning` | Genuine but needs attention | `ref`, `item`, `count`, `reasons` |
| `not_found` | No item of this client matches | `ref` only |
| `unassigned` | The item exists but is in no batch | `ref` only |

There is no `invalid` result: an item can pass between sellers and be checked again.

| Reason (with `warning`) | Meaning |
|---|---|
| `checked_before` | Officials checked this item before; `count.this_check` and `count.last_at` show how often and when |
| `recalled` | The batch was recalled |
| `expired` | The batch's expiry date has passed (judged by the Bangladesh date, ProtectB DEC-330) |
| `damaged` | The item was marked damaged |
| `switched_off` | The item's batch is switched off |

Result display rules:

- Every result and every reason has its own distinct display.
- `ref` is shown on every result, including `not_found` and `unassigned`.
- `item.code` is shown as received (masked).
- `count.by` (names of earlier checkers) is shown only when present (`history:all`).
- `product.picture_url`, `product.short_name`, `batch.made`, and `batch.expires` can be `null`.

Result screen (`LookupResultScreen`, decisions 46 and 49). Every path opens the same screen: a typed lookup, a scanned QR code, and a row of the Bulk lookup results. The client's Figma gives the look; the words follow this section and the backend: no network address, no uses limit (backend D16, D31), no "do not purchase", and no fixed code lengths (backend D41).

| `result` | Top card (`VerificationResultCard`) | Then |
|---|---|---|
| `valid` | `success` round icon, "Genuine product", badge "GENUINE", the result text, reference with copy | **PRODUCT DETAILS**, **PRODUCT IMAGE**, actions |
| `warning` with `checked_before` | `warning` round icon, "Genuine, needs attention", badge "CHECKED BEFORE", "This is check number N of this item. Last check: <time>.", every other reason as its own row | **TRACKING DETAILS** (a "Check N" pill, serial, masked code, batch, product, generic name, the previous check time, "Checked before by" when `count.by` is sent), **PRODUCT IMAGE**, actions |
| `warning` without `checked_before` | `warning` round icon, "Genuine, needs attention", badge "NEEDS ATTENTION", one row per reason | **PRODUCT DETAILS**, **PRODUCT IMAGE**, actions |
| `not_found` | `danger` round icon, "Not found", badge "NOT FOUND", the result text, reference | **WHAT YOU ENTERED**, **HINTS**, actions **Try again**, **Contact support**, **Back to Verify** |
| `unassigned` | `textLabel` round icon, "Not in a batch", badge "NOT IN A BATCH" | **WHAT YOU ENTERED** and the actions, as `not_found`; no hints (the item exists) |
| unknown | `textLabel` round icon, "Unable to verify", badge "UNABLE TO VERIFY" (Section 13.1.5) | **WHAT YOU ENTERED** and the actions, as `not_found`; no hints |

The round icon stands in a soft halo of its colour (12 %) with a light shadow, as in the Figma result.

- **PRODUCT DETAILS** lists the product name, generic name, short name, batch, made and expiry dates, serial, and the masked hidden code; a `null` field is left out.
- **WHAT YOU ENTERED** shows the way, the value (a hidden code only as `*****` and its last 3 characters, never in full), the check time in Bangladesh time, the result, and the reference.
- **HINTS** are built from `GET formats`: the serial's digits and maximum length, each hidden code length, "Scratch the panel off fully", and "Scan the QR code instead" when the way was not a QR code.
- **Try again** returns to where the lookup started (the Verify tab, the scanner, or the Bulk lookup results); a typed hidden code is already cleared. **Contact support** is shown only when the profile has a support email or phone (Section 13.8): it opens an email to the support address with the reference, the way, the value (a hidden code masked), and the check time, or calls the phone when only a phone is set; without a mail app the address is shown. **Back to Verify** returns to the Verify tab.
- **Report incident** (with `incident:report`) follows every result. **Verify another item** follows a genuine result; on the others **Try again** takes its place.

Product picture (`ProductPictureCard`, decision 47). The backend sends `item.product.picture_url`: a public, read-only, cached HTTPS address of one JPEG, PNG or WebP picture of at most 5 MB, about 1600 px on its long side, or `null` (ProtectB DEC-333, DEC-344, DEC-351).

| State | Card |
|---|---|
| Loading | A skeleton in the picture box |
| Loaded | The picture, whole (`BoxFit.contain`, 4:3 box on `surfaceMuted`); a tap opens it full screen with pinch zoom |
| Failed | The placeholder, "The picture could not be loaded", and **Try again** (the picture is loaded again) |
| `null` | The placeholder and "No picture for this product" |
| Not `https://` | Treated as `null`; nothing is requested |

- The picture is loaded through `PictureImages` (an injected service): never through the API client, so the picture host never receives the access pass.
- It is kept in Flutter's memory image cache only, decoded at the size shown; it is never written to the phone's storage (Section 12.1, backend D21).
- It is read by TalkBack as "Picture of <product name>".

#### 13.1.5 Fail-Safe Rules

- An unknown `result` value is displayed as "Unable to verify" — never as `valid`.
- An unknown reason is displayed as a generic "Needs attention" warning.
- Parsing never fails on unknown fields.

#### 13.1.6 Lookup Errors

| Answer | Display |
|---|---|
| `400 validation_failed` | General error with reference (an app defect; logged) |
| `503 app_preparing` | "The app is being prepared. Try again later." |
| `429 rate_limited` | Countdown from `Retry-After` |
| Network failure | "Unable to verify. Check the connection and try again." |

### 13.2 Bulk Lookup

- `POST lookups/bulk { items: [ { way, value }, … ] }`, 1 to 500 items, ways mixed.
- Results come back in the order sent and are matched by position. Input is never echoed back.
- The summary shows `total`, `valid`, `warning`, `by_reason`, `not_found`, and `unassigned`.
- Every item is its own check with its own `ref`, including duplicates in one request.
- `503 service_unavailable`: nothing was checked; the app offers "Send again" with the same list.
- `429 rate_limited`: nothing was checked; the app waits `Retry-After`, then allows sending the same list.
- Limit: 3,000 items a minute per official.

App rules for building and sending the list:

| Rule | Detail |
|---|---|
| Building | QR codes are scanned one after another with the camera open on the screen; serials and hidden codes are typed and added. Every item is parsed, normalized, and checked against `GET formats` before it is added (Section 13.1.2). |
| Duplicates | The same item (way and value) is not added twice: every item sent is its own recorded check. |
| Size | At most 500 items; the 501st is refused. |
| Hidden codes | Shown masked in the list (`*****` and the last 3 characters). The typed values are dropped once the results arrive; result rows keep the masked label only. |
| Sending | One request for the whole list (`droppable`). After `503` or `429` the same list stays and is sent again ("Send again"; after `429`, once `Retry-After` has passed). |
| Results | The summary (total, valid, warning with each reason, not found, not in a batch), then one row per item in the order sent; "Only items that need attention" hides valid rows; a row opens the full result (Section 13.1.4). A results count different from the items sent is a broken answer and is never shown. |
| Entry point | "Bulk lookup" on the Verify tab, shown only with `item:bulk_lookup` (Section 13.7). |

### 13.3 Certificate

- Generated in the app as a PDF from a lookup result (`valid` or `warning`) by `CertificateComposer` and `PdfService`.
- Content: product, batch, dates, result, reasons, check time, official name, and the reference number (`ref`).
- The client's office confirms a certificate by looking up its reference number in the portal.
- Shared through `ShareService`. The PDF is a temporary file, removed after sharing.
- The check time is printed with its UTC offset (for example `2026-11-10 14:30 +06:00`).
- Layout, branding, and final content: provided by the client later (Section 20.3). Until then, a plain layout built from the design tokens.

### 13.4 History

`GET checks` — the official's own checks (`history:own`), or every official's checks (`history:all` with `scope=all`), newest first.

| Query | Meaning |
|---|---|
| `limit` | 1 to 100, default 50 |
| `cursor` | `next_cursor` from the previous page |
| `result` | `valid`, `warning`, `not_found`, `unassigned` |
| `way` | `serial`, `qr`, `hidden_code` |
| `from`, `to` | Dates (`YYYY-MM-DD`), both included. The time zone that defines a day is a backend question (Section 20.2). |
| `search` | A serial or a reference number |
| `scope` | `own` (default) or `all` (needs `history:all`) |

- Paging follows Section 10: `totals` arrive on the first page only (`null` on later pages); `next_cursor` is `null` when the page is not full, and a full page always returns a cursor, so the next page can be empty.
- `scope=all` is sent only when the profile lists `history:all`; the scope switch is hidden otherwise.
- `serial`, `product`, and `batch` are `null` for `not_found`; `product` and `batch` are `null` for `unassigned`.
- Item tracking is History with `search` set to a serial (Section 13.4.1).

Screen:

| Part | Detail |
|---|---|
| Search | One field for a serial or a reference number; sent 400 ms after typing stops (Section 8.3) |
| Result chips | Under the search, scrolling sideways (the Figma "product history"): **All · Valid · Warning · Not found · Not in a batch**, each with its count. The chosen chip is navy with white text (decision sheet Q21, option A). A chip sets `result` and starts again from the first page; the other filters and the search stay. The counts are every check matching the search and the other filters, whatever chip is chosen: with All they are the first page's `totals`; with a result chosen, the page's `totals` count that result only, so the counts are asked for once more without `result`, with `limit=1`, and kept while only the chip changes. Unknown counts (loading, failed) are left out; the chips still work |
| Filters | A sheet with way, dates (from–to, both included), and "Everyone's checks" (`scope=all`, shown only with `history:all`); a reset action clears them and keeps the search and the chosen chip |
| Row | A white card: the serial (or the reference when there is no serial) with the result badge; product and batch; the day and time in Bangladesh time ("Today · 4:02 PM", "Yesterday · …", or the date); a grey box saying what the result means (for `warning`, its reasons); the way and the reference. The official's name follows the way for everyone's checks. At a large font the way and the reference stack |
| List | `AppPaginatedList`: skeleton, empty state, error with Retry, loading footer, retry footer, pull to refresh (Section 10) |

#### 13.4.1 Item Tracking

- Searching a serial in History lists every check of that item, newest first (`GET checks?search=<serial>`; with `scope=all` every official's checks of it, Section 7).
- Each row shows time, way, result, reasons, product and batch, and the official's name when present.
- The look follows the Figma "batch details by id" without its IP, uses, and batch fields (backend D16, D31; a check carries only `serial`, `product`, and `batch`): an **ITEM** card with the product, batch, serial, and the number of checks (`totals.total`), then **TRACKING LOG** with the checks numbered 01, 02, … newest first. TalkBack reads the log title as "Every check of serial N".
- Hidden codes cannot be searched: `search` takes a serial or a reference number only.

### 13.5 Incident Reports

#### 13.5.1 Report Flow

```
1. File the report        POST incidents { note, check_ref?, retail_user_id? }   → 201 { id }
        │
        ▼
2. For each photo (max 3, one at a time, within 1 hour of filing):
   pick → compress (PhotoService) → POST incidents/{id}/photos (raw file body)   → 201 { n }
        │
        └── on 503 or network loss: keep the photo and send it again (never counted twice)
```

#### 13.5.2 Rules

| Rule | Detail |
|---|---|
| Note | 1 to 1,000 characters, required |
| `check_ref` | Optional; one of the official's own checks (a lookup result's `ref`) |
| `retail_user_id` | Optional; a retail user from the picker (Section 13.6) |
| Photo body | The file itself, not JSON and not a form; `Content-Type: image/jpeg` or `image/png`; `Content-Length` required |
| Compression | 2048 px on the longer side, JPEG quality 85, at most 1 MB; HEIC converted to JPEG; all metadata removed after the orientation is applied |
| Re-filing | A report is never filed again after a photo failure; that creates a second report |
| Limit | 50 reports an hour per official |
| When not needed | A lookup warning (`recalled`, `expired`, `damaged`, `switched_off`) already informs the client's office |

App rules:

| Rule | Detail |
|---|---|
| Entry points | "Report incident" on a lookup result (carries its `ref` as `check_ref`) and on the Verify tab; "My reports" on the Verify tab. All need `incident:report`. |
| Photos before filing | Picked and prepared at once (`PhotoService`); sent one at a time right after the report is filed |
| Photos after filing | May still be added within the hour, up to 3 in all; each is sent at once |
| Retry | A photo that failed on a lost connection, `503`, `429`, or `5xx` is kept and offered again (same file, same report). A refused photo (`400`, `404`, `409`) is not. |
| Filing failure | A lost connection while filing means the report may exist: the app says so and points to My reports before the official files it again. A `404` (check or retail user not found) asks to remove the link and try again. |
| Retail user | Chosen in the picker (Section 13.6) or left empty |

#### 13.5.3 Photo Errors

| Answer | Display |
|---|---|
| `400 validation_failed` | Photo too large, not JPEG/PNG, or empty |
| `404 not_found` | Report not found |
| `409 conflict` | The report has 3 photos already, or the hour has passed |
| `503 service_unavailable` | Keep the photo and send it again shortly |

#### 13.5.4 My Reports

`GET incidents` (`limit`, `cursor`, paged as in Section 10) lists the official's own reports with `photos` count, `check_ref`, and `retail_user`. No other query parameter is accepted. Photos cannot be downloaded in the app.

### 13.6 Retail Users

| Action | Route | Permission | Rules |
|---|---|---|---|
| Pick a retail user | `GET retail-users?search=&limit=&cursor=` | `incident:report` or `retail_user:add` | Active (not blocked) retail users, ordered by name. Search by part of a name or a whole email. Emails arrive masked (`ra***@gmail.com`) and are shown as received. |
| List retail roles | `GET retail-roles` | `retail_user:add` | `data` is a list of `{ id, name }`. An empty list means no retail user can be added yet. |
| Add a retail user | `POST retail-users { name, email, role_id, password, send_email }` | `retail_user:add` | `201`. `409 conflict`: the email is already used by any official of the client. `404 not_found`: the role is not a retail role. |
| Email a new first password | `POST retail-users/{id}/password` (no body) | `retail_user:add` | Always emailed; the old first password stops working at once. `409 conflict`: the retail user has set their own password. `404 not_found`: unknown, blocked, or not a retail user. |

#### 13.6.1 Add Retail User Form

| Field | Rule |
|---|---|
| `name` | 1 to 100 characters |
| `email` | The address the retail user logs in with and reads mail at |
| `role_id` | One of `GET retail-roles` |
| `password` | The first password: 1 to 128 characters, no control characters, no other rule (Section 6.6) |
| `send_email` | Switch "Email the login details", on by default; sent as `true` or `false` |

| `email_sent` in the answer | Display |
|---|---|
| `true` | The login details were emailed. |
| `false` | The mail could not be sent; the account exists. The official gives the typed password in person, or uses "Email a new first password" later. |
| `null` | Not sent, as asked (`send_email: false`): "Give the password to the retail user yourself." and the typed password shown once more. |

- The typed first password is held only in the form state and is cleared when the screen closes. It is never stored or logged (Section 12.2).
- A first password has no end date; it works until it is used.

#### 13.6.2 Screens

| Screen | Detail |
|---|---|
| Retail users (`/home/retail-users`) | Entry point on the Verify tab with `retail_user:add`. The client's retail users with a debounced search and cursor paging (Section 10); each row offers "Email a new first password" after a confirm. `409`: the retail user has set their own password; `404`: not found or blocked. |
| Add retail user (`/home/retail-users/new`) | Roles from `GET retail-roles`; an empty list explains that no retail user can be added yet. One request per press. `409`: the email is already used; `404`: the role is no longer a retail role. |
| Added | `email_sent: true`: emailed to the address. `false` or `null`: the typed password is shown once more with a copy action, to hand over in person. The password is forgotten on "Add another" and when the screen closes. |

The picker is a bottom sheet with a debounced search (Section 8.3) and cursor paging (Section 10). `search` is up to 100 characters; a new search starts again from the first page.

Limit: 30 retail users added or passwords emailed an hour per official.

### 13.7 Verify Tab (Home)

The first tab and the screen after login.

| Section | Shown when | Content |
|---|---|---|
| Header | always | Organisation, "Welcome back," and the official's name (`GET me`) |
| Verify an item | `item:lookup` | Serial and hidden code entry checked against `GET formats` (Section 13.1.3); Scan QR opens `/home/scan` |
| Entry points | per feature | Bulk lookup (`item:bulk_lookup`), Report incident and My reports (`incident:report`), Retail users (`retail_user:add`) |
| No features | the role allows none of the above | An empty state; an empty permission list is valid (Section 7.2) |

The look follows the Figma "Home page" without its barcode tiles and Batch tab (only QR codes are scanned, decision 38; item tracking is in History): a faint honeycomb on the navy header, strongest at the end, and a large faint QR corner on the **Scan QR code** card, both decoration hidden from TalkBack. A hidden code is shown with a tag icon (the Figma "Label ID") wherever it appears (the Verify field, Bulk lookup, History), a serial with `#`. The fields keep the names **Serial** and **Hidden code**.

The backend has no dashboard route. Dashboard data is future (Section 20.4).

### 13.8 Profile Tab

`GET me` returns `id`, `name`, `email`, `role`, `permissions`, `organisation`, `support` (`email`, `phone`), and `must_change_password`. `organisation` and either support field can be `null`.

| Section | Content |
|---|---|
| Header | The navy band with "Profile"; the white identity card reaching up into it, the initials in a round navy avatar standing over the card's top edge, the name, and the role as a green pill with a dot (the Figma "Profile") |
| Details | Organisation, email, role, in the identity card |
| Check counts | Three cards under the identity card: **Checks** (`total`), **Valid** (`valid`, green), and **Not verified** (`not_found` + `unassigned`, red). From the first page of `GET checks` with no filters and `limit=1` (own checks); no other endpoint. Shown only when the profile lists `history:own` or `history:all`; nothing is asked for otherwise. Grey bars while the first counts load; "Your counts couldn't load." with **Try again** when the request fails or the page has no `totals`. Asked for again each time the tab comes back into view and on pull to refresh; the last counts stay shown meanwhile. At a large font the cards stack, label on the left and count on the right |
| Account | Change password (opens `/change-password`), support contact (opens mail or the dialler; "Not set" when both fields are `null`), app version (`AppInfoService`), language (English / Bangla) |
| Log out | Confirm, then `POST auth/logout`; the session ends and the router shows Login (Section 6.5) |

The Figma's last login, "last changed" under Change password, the user ID under the name, and the menu at the top right are not shown: `GET me` sends no last login, password date, or user name (the user ID is the email, backend D13), and the menu would hold nothing that is not already on the screen.

### 13.9 Request Access

Follows backend D27: access requests do not go through the backend. The admin creates the account in the client portal.

- The screen opens from Login and needs no login.
- The look follows the Figma "Request for id". Under the header, a white **How it works** card lists three numbered steps:
  1. **Send your request:** email or call the office with the details below ("email" only when no phone is configured).
  2. **Your office checks it:** an administrator checks the request and creates the account.
  3. **Receive your login:** the first password is emailed or given in person, and it is changed at the first login (backend D55).

  The steps give no time for the check: the backend makes no such promise. Below the card, **Please include** lists the six details in two columns (one column at large font sizes).
- It shows the client office's email and phone from `app/config/`. The client supplies both values (Section 20.3). `GET me`'s `support` contact is not available before login.
- "Email" opens the mail app (`mailto:`) with the subject "Access request" and a body listing what the office needs: name, phone, organisation, email, job title, and reason (backend decisions §2.2).
- "Call" opens the dialler (`tel:`).
- Both go through `LauncherService`. No data is sent to the backend, and nothing is stored or logged.
- An in-app form sent to the backend is future (Section 20.4).

---

## 14. UI Component Architecture

### 14.1 Reusable Components

| Component | Location |
|---|---|
| `AppButton`, `AppIconButton` | `shared/design_system/components/buttons/` |
| `AppTextField`, `AppSearchField`, `AppPasswordField`, `AppOtpField` | `shared/design_system/components/inputs/` |
| `AppCard`, `AppProductCard` | `shared/design_system/components/cards/` |
| `AppLoading`, `AppSkeleton` | `shared/design_system/components/loading/` |
| `AppScaffold`, `AppDialog`, `AppErrorState`, `AppEmptyState`, `NetworkStatusBanner` | `shared/widgets/` |
| `AppPaginatedList<T>` | `shared/widgets/` — cursor-paged list built from `PaginatedState<T>`: skeleton, empty, error, loading footer, retry footer, pull to refresh (Section 10) |
| `PermissionGate` | `shared/widgets/` — shows its child only when the profile lists a permission |
| `RetryCountdown` | `shared/widgets/` — countdown from `Retry-After` (rate limits, resend code) |
| `ReferenceText` | `shared/widgets/` — "Reference: {request_id}" on every error |
| `VerificationResultCard` | `features/verification/presentation/widgets/` (variants: valid, warning, not_found, unassigned, unknown): the top card of the result screen, with its round icon and badge |
| `ProductPictureCard` | `features/verification/presentation/widgets/` (loading, loaded, failed, none; full-screen view) |
| `VerifyingView` | `features/verification/presentation/screens/` (the verification loader, Section 13.1.2) |
| `ReasonChip` | `features/verification/presentation/widgets/` |
| `BulkSummaryCard` | `features/verification/presentation/widgets/` |

### 14.2 UI States

Every data-driven screen handles these states:

| State | Component |
|---|---|
| Loading | `AppLoading` / `AppSkeleton` |
| Success | Feature content |
| Loading more | `AppPaginatedList` loading footer |
| Next page failed | `AppPaginatedList` retry footer (loaded items kept) |
| Empty | `AppEmptyState` |
| Error | `AppErrorState` with `ReferenceText` |
| Offline | `NetworkStatusBanner` (driven by `ConnectivityService`) |
| Warning | `VerificationResultCard` (warning variant, one `ReasonChip` per reason) |
| Rate limited | `RetryCountdown` |
| Preparing | `AppErrorState` — "The app is being prepared. Try again later." (`503 app_preparing`) |
| Not available | `AppErrorState` — "Not available" (`404 not_found` for the whole client) |
| Hidden | `PermissionGate` hides features the role lacks |

---

## 15. API Contract

The API guide (`app-api-guide.md`) and the Postman collection are the reference. Models are built field by field from the Postman example answers, including nullable fields.

### 15.1 Basics

| Item | Rule |
|---|---|
| Base path | `https://<app API host>/v1/clients/<slug>/…` |
| Client slug | Fixed per build (Section 17). A switched-off or unknown client answers `404 not_found` on every route. |
| Request body | JSON (`Content-Type: application/json`), at most 64 KB. Photo uploads send the raw file. |
| Request fields | Only documented fields are sent. Unknown, missing, or wrongly typed fields answer `400 validation_failed`, and so do undocumented query parameters. |
| Authorization | `Authorization: Bearer <access_token>` after login. No cookies. |
| Times | ISO 8601 UTC with offset; fractional-second digits vary. Parsed with a date library. |
| Dates | `YYYY-MM-DD` |
| Pagination | Cursor-based: `limit` (1–100, default 50) and opaque `cursor` / `next_cursor` on `GET checks`, `GET incidents`, `GET retail-users` (Section 10) |
| Versioning | Only `/v1/`. The API only grows: unknown fields and new values are ignored. Breaking changes come as `/v2/`. |

### 15.2 Response Envelope

```json
{ "success": true,  "message": "…", "data": { … } }

{ "success": false, "message": "…",
  "error": { "code": "…", "message": "…", "request_id": "…" } }
```

The Dio client returns `data` on success and throws one typed `AppException` on failure.

### 15.3 Routes

| Method | Path | Permission | API service |
|---|---|---|---|
| POST | `auth/login` | — | `AuthApiService` |
| POST | `auth/verify-phone` | — | `AuthApiService` |
| POST | `auth/resend-code` | — | `AuthApiService` |
| POST | `auth/refresh` | — | `SessionService` (core) |
| POST | `auth/logout` | logged in | `AuthApiService` |
| POST | `auth/password/forgot` | — | `AuthApiService` |
| POST | `auth/password/reset` | — | `AuthApiService` |
| GET | `me` | logged in | `ProfileApiService` |
| POST | `me/password` | logged in | `AuthApiService` |
| GET | `formats` | logged in | `VerificationApiService` |
| POST | `lookups` | `item:lookup` | `VerificationApiService` |
| POST | `lookups/bulk` | `item:bulk_lookup` | `VerificationApiService` |
| GET | `checks` | `history:own` / `history:all` | `HistoryApiService` |
| POST | `incidents` | `incident:report` | `IncidentApiService` |
| POST | `incidents/{id}/photos` | `incident:report` | `IncidentApiService` |
| GET | `incidents` | `incident:report` | `IncidentApiService` |
| GET | `retail-users` | `incident:report` / `retail_user:add` | `RetailUserApiService` |
| GET | `retail-roles` | `retail_user:add` | `RetailUserApiService` |
| POST | `retail-users` | `retail_user:add` | `RetailUserApiService` |
| POST | `retail-users/{id}/password` | `retail_user:add` | `RetailUserApiService` |

Future routes, not in the backend documents (Section 20.4). Nothing in v1 calls them; paths and shapes are fixed by the backend team when they add them:

| Purpose | Access | API service |
|---|---|---|
| Dashboard data | logged in | `DashboardApiService` |
| Product list | logged in | `ProductApiService` |
| Access request | public (no login) | `AccessRequestApiService` |

### 15.4 Error Codes

| HTTP | `error.code` | `AppException` | App action |
|---|---|---|---|
| 400, 413, 415 | `validation_failed` | `ValidationException` | Log with `request_id`; general error |
| 401 | `token_expired` | `TokenExpiredException` | Renew once, retry once (Section 6.4) |
| 401 | `unauthenticated` | `UnauthenticatedException` | Clear passes; Login screen |
| 403 | `password_change_required` | `PasswordChangeRequiredException` | Change password screen |
| 403 | `policy_denied` | `PolicyDeniedException` | Show the three password rules (Section 6.6); log `request_id` |
| 403 | `forbidden` | `ForbiddenException` | Reload profile; hide the feature |
| 404 | `not_found` | `NotFoundException` | "Not available", or the route's own case |
| 409 | `conflict` | `ConflictException` | Route-specific message |
| 429 | `rate_limited` | `RateLimitedException` (carries `Retry-After`) | Countdown, then allow retry |
| 503 | `app_preparing` | `AppPreparingException` | "The app is being prepared. Try again later." |
| 503 | `service_unavailable` | `ServiceUnavailableException` | "Try again shortly"; resend where the route allows |
| 5xx / other | `internal_error` | `InternalErrorException` | General error with reference |
| — | (no response) | `NetworkException` | Offline / connection message |

### 15.5 Rate Limits

| Limit | Value |
|---|---|
| Requests per official | 120 a minute |
| Looked-up items per official | 3,000 a minute (a bulk request counts its items) |
| Reports per official | 50 an hour |
| Retail users added / passwords emailed per official | 30 an hour |
| Requests per network address | 1,200 a minute |
| Login, code, and reset | Lower, separate limits |

The app never hard-codes these values: it acts on `429` and `Retry-After` only.

---

## 16. Localization

- Languages: English (`en`) and Bangla (`bn`) via ARB files in `lib/l10n/`.
- The API returns messages in English only. The app owns every user-facing text.
- Text is chosen by `error.code`, `data.status`, `data.result`, and `data.reasons`, with route context for `404` and `409` cases.
- The server `message` is used only as a fallback for an unknown code.
- The result screen's words come from this document, not from the client's Figma: a repeat check is "Checked before" with its check number, never a uses limit or "do not purchase"; hints quote the lengths of `GET formats` (Section 13.1.4).
- The reference line ("Reference: {request_id}") is shown in both languages.
- Times arrive in UTC and are always displayed in Bangladesh time (`Asia/Dhaka`, UTC+6), whatever the phone's time zone (ProtectB DEC-205: times are stored as exact instants; people see Bangladesh time). They are formatted per locale, including Bangla digits.
- The certificate prints the check time in Bangladesh time with its offset (`+06:00`).
- History `from` / `to` dates are picked on a Bangladesh-time calendar. ProtectB's portal routes read such a date as a whole UTC day (06:00 to 06:00 Bangladesh time); whether `GET checks` does the same is a backend question (Section 20.2).

---

## 17. Environments

| Environment | Base URL | Client slug | Purpose |
|---|---|---|---|
| Mock | Postman mock server address | Collection value | UI development without a server; error answers chosen with the `x-mock-response-name` header |
| Test (flavor `staging`) | ProtectB test server (waiting, Section 20.3) | `demo-pharma` | Integration with made-up data, test logins, and the mail page for emailed codes |
| Live | ProtectB live host | Client's slug | Production |

- Base URL and slug are the only per-environment values (`app/config/`).
- Live clients are never used for testing: every check is kept permanently.

---

## 18. Testing Strategy

### 18.1 Test Types

- Unit tests
- Widget tests
- API contract tests
- Integration tests
- Security tests
- Camera tests
- Network tests
- Performance tests
- Accessibility tests
- Device tests
- Release safeguards

### 18.2 Service Layer Testing

| Target | Approach |
|---|---|
| BLoCs, use cases, repositories | Use fakes from `test/fakes/`. Never touch real plugins or the network. |
| API services | Tested with a Dio mock adapter against the Postman example answers. These form the API contract tests. |
| Core service implementations | Tested against mocked plugins. |
| Domain services (`QrLinkParser`, `CodeNormalizer`, `InputFormatValidator`, `PasswordPolicy`, `CertificateComposer`) | Table-driven unit tests with full branch coverage. |
| `RouteGuard` | Table-driven unit tests: one case per row of Section 9.4. |
| Router | Widget tests with a fake `SessionService` and `ProfileCubit`: session changes move the official to the right screen; missing permissions redirect to Home. |
| Paginated BLoCs | `bloc_test` with fake repositories: first page, next page, end of list, empty page after a full page, filter change resets the cursor, next-page failure keeps items, totals kept from the first page. |

### 18.3 Acceptance Checks

| Area | Check |
|---|---|
| Phone ID | Made once; survives restarts and logouts |
| Errors | Every error becomes one typed exception carrying `code` and `request_id` |
| Renewal | Two requests failing with `token_expired` at the same moment cause one renewal, and both are retried once |
| Rate limits | A `429` exposes `Retry-After` and shows a countdown |
| Login | New phone → code → logged in; the next login on the same phone needs no code |
| Resend code | At most once a minute, with countdown |
| Forced change | `must_change_password: true` shows only Change password, then continues to Home |
| Failed login | Wrong password and unknown email show the same message |
| Forgotten password | Always the same confirmation message; then code and new password; back to Login |
| Session | Returning after 20 minutes renews silently; logout keeps the phone ID; any `401 unauthenticated` lands on Login |
| Permissions | Home and menus show only what `GET me` allows |
| Navigation | Every session state lands on its own screen; a route without its permission redirects to Home; forced Change password cannot be left with back; no sensitive value in any route |
| Lookup | QR sends only the value after `/q/`; typed input checked against `formats`; every result and reason displayed; `ref` shown |
| Bulk | Up to 500 items; results matched by position; `503` offers resend of the same list |
| History | Filters, cursor paging until `null`, totals from the first page; `scope=all` only with `history:all` |
| Pagination | `next_cursor` sent back unchanged; a filter change starts from the first page; an empty last page ends the list; a next-page failure keeps loaded items |
| Reports | `check_ref` carried from a result; photos compressed, sent raw, retried, never duplicated; report never re-filed |
| Photo metadata | An uploaded photo carries no EXIF (no location, time, or phone model) and keeps its correct orientation |
| Transport | Cleartext HTTP is refused on both platforms |
| Time display | Times shown in Bangladesh time (`Asia/Dhaka`) on a phone set to another time zone; the certificate shows `+06:00` |
| Retail users | Picker search with masked emails; "Email the login details" switch on by default; `email_sent` `true` / `false` / `null` each explained; `409` shown |
| Request access | Email opens the mail app with the subject and the field list; Call opens the dialler; nothing is sent to the backend |
| Password rule | Rules shown with live ticks before typing; button disabled until met; `abcd1234` accepted; `12345678`, `password`, and `abc123` stopped before sending |

---

## 19. Decision Log

| # | Decision | Sections |
|---|---|---|
| 1 | State management uses BLoC / Cubit exclusively. | 2.1, 8 |
| 2 | Theming is built from design tokens on Material 3. No third-party theming or form-builder packages. | 2.1, 11 |
| 3 | A dedicated service layer wraps the backend and every plugin. Features never import plugins directly. | 4, 5 |
| 4 | Feature data-access classes live in `data/services/` (renamed from `data/datasources/`). | 5.2, 11 |
| 5 | Dashboard data is loaded from a dedicated dashboard endpoint (`DashboardApiService`) once the backend adds one. Future (Section 20.4); v1 Home shows entry points only. | 1.4, 13.7, 20.4 |
| 6 | Login is required before any feature is accessible, including product verification. There is no public verification. | 1, 6 |
| 7 | The app serves the client's officials (inspectors, supervisors, retail users), not consumers. | 1.1 |
| 8 | ProtectB `mobile-app-api` is the backend; `app-api-guide.md` and the Postman collection are the reference contract. | 15 |
| 9 | One app per client: base URL and client slug are fixed per build. | 1, 17 |
| 10 | Online only. No local database, no offline queue, no item or check data stored on the phone. | 1.3, 2.2, 12.1 |
| 11 | Only QR codes are scanned. Serials and hidden codes are typed. | 1.3, 13.1 |
| 12 | No app attestation, no GPS, no push notifications (backend decisions D35, D19, D24). | 1.3 |
| 13 | Session has four states; renewal happens only on `401 token_expired`, single-flight, app-wide. | 5.5, 6 |
| 14 | A phone ID is generated once and never regenerated. | 6.1 |
| 15 | Features are shown only when the role's permissions from `GET me` allow them. | 7 |
| 16 | Input formats come from `GET formats`; nothing is hard-coded. | 13.1.3 |
| 17 | Unknown result or reason values fail safe and are never shown as valid. | 13.1.5 |
| 18 | The certificate PDF is generated in the app. | 13.3 |
| 19 | The Settings screen is replaced by Profile; language and theme are local preferences inside Profile. | 1.4, 13.8 |
| 20 | The app owns all user-facing text; server messages are fallbacks only. | 16 |
| 21 | Device attestation service removed; `PhoneIdService`, `PhotoService`, `PdfService`, and `ShareService` added to core services. | 5.6 |
| 22 | Navigation uses `go_router` with named routes and one redirect guard driven by the session state and profile permissions. | 2.1, 9 |
| 23 | Only the router guard moves between session areas; BLoCs never navigate. | 6.7, 9.5 |
| 24 | No deep links or app links are registered. | 9.5, 12.1 |
| 25 | Every backend list uses cursor-based pagination (`limit` 50, opaque `next_cursor`); no offset or page-number paging. | 2.1, 10 |
| 26 | Pagination types live in `core/pagination/`; one shared `AppPaginatedList<T>` renders every paged list. | 10.3, 14.1 |
| 27 | The password rule is 8 to 128 characters with at least one letter and one number (backend D54), shown with live ticks on every new-password screen. Replaces the earlier 12-character, common-password, and email-part rule. | 6.6 |
| 28 | First passwords have no end date, and adding a retail user offers "Email the login details" (`send_email`, backend D55). Replaces the earlier 7-day expiry. | 6.6, 13.6 |
| 29 | Pending items are split into open decisions, backend questions, and waiting items. | 20 |
| 30 | The product list is future: it needs a backend route first (Section 20.4). Not in v1. | 1.3, 15.3, 20.4 |
| 31 | Request access follows backend D27 in v1: email or call to the client's office, contact from the build configuration. An in-app form is future: it needs a public backend route and a change to D27. | 1.4, 13.9, 20.4 |
| 32 | No certificate pinning in v1; platform TLS validation with cleartext traffic disabled. | 12.1 |
| 33 | Times are displayed in Bangladesh time (`Asia/Dhaka`, UTC+6), following ProtectB DEC-205; the certificate prints the `+06:00` offset. | 13.3, 16 |
| 34 | All photo metadata is removed before upload. | 12.1, 13.5 |
| 35 | No root or jailbreak detection in v1. | 12.1 |
| 36 | The certificate's layout and content come from the client later; a plain layout is used until then. | 13.3 |
| 37 | The backend team's documents (`ProtectB-DOCS-initial/`) are the backend source of truth; v1 uses only documented routes and behaviour. | Header, 20.4 |
| 38 | Packages and tooling are fixed (Sections 2.2, 2.3): `get_it` without code generation, `freezed` models, `mobile_scanner` for QR only, `flutter_image_compress` for compression and EXIF removal, Firebase Crashlytics, FVM, GitHub Actions, three flavors. No analytics SDK in v1. | 2.2, 2.3 |
| 39 | App identity from the Figma: name "Track & Trace" (Ziska Pharma); application and bundle ID `com.ziskapharma.trackandtrace`, with `.mock` and `.staging` suffixes for those flavors. The Dart package is `ziska_verify`. | 2.3 |
| 40 | After login the app uses a bottom navigation bar with three tabs (Verify, History, Profile) in a `StatefulShellRoute.indexedStack`; full-screen flows open above the bar; tabs the role cannot use are hidden. Item tracking is History searched by a serial. The `figma/` exports are a visual reference only: screens and content follow this document and the backend documents. | 9.2, 9.3.1, 13.4.1, 13.7 |
| 41 | The Verify tab (tab 1) is built by the verification feature (`VerifyScreen`), because it holds the lookup form; `home/` is kept for the future dashboard. The QR scanner and the lookup result open above the bottom bar, each with its own `LookupBloc`. | 9.2, 13.1, 13.7 |
| 42 | Bulk lookup builds its list by continuous QR scanning and typing, refuses duplicates and a 501st item, masks hidden codes, drops typed values after the results, and keeps the same list for "Send again" after `503` or `429`. | 13.2 |
| 43 | A report is filed once and never filed again; its photos are prepared on the phone and sent one at a time after it, retried only after a lost connection or a busy service, within the hour. A lost connection while filing points the official to My reports before filing again. | 13.5 |
| 44 | Adding a retail user shows the typed first password again only when it was not emailed (`email_sent` `false` or `null`), and forgets it when the screen closes or another retail user is added. | 13.6 |
| 45 | Retail and senior sellers see the history of their own checks through the role permission `history:own` (the default for retail roles, backend D53), never through checks stored on the phone. Without it, History is hidden. | 1.1, 7.2, 13.4 |
| 46 | The result screen follows the client's Figma look (a top card with a round icon, a title and a badge; detail cards) for every lookup path, with words from Section 13.1.4 and the backend: no network address, no uses limit, no "do not purchase", no fixed lengths. | 13.1.4, 16 |
| 47 | The product picture has its own card on genuine results: loading, loaded, failed with Try again, and a placeholder when `null`; full screen with pinch zoom on a tap; HTTPS only, without the access pass, kept in memory only. | 13.1.4, 12.1 |
| 48 | A lookup still running after 300 ms shows the full-screen verification loader with three steps; only "Code format" is ticked before the answer, and nothing is delayed to show the steps. | 13.1.2 |
| 49 | A `not_found`, `unassigned`, or unknown result shows what was entered (a hidden code masked), hints from `GET formats`, and Try again, Contact support (when set), and Back to Verify. | 13.1.4 |

---

## 20. Pending Decisions

Checked against the ProtectB `mobileApp` documents of 2026-11-10 (decisions D1–D55).

### 20.1 Open Decisions

None. Every earlier item is decided (Decisions 30–36) or listed below.

### 20.2 Questions for the Backend Team

| # | Question | Affects |
|---|---|---|
| 1 | Does `GET checks` read `from` / `to` as whole UTC days (06:00 to 06:00 Bangladesh time), as ProtectB's portal routes do, or as Bangladesh days? The app API guide does not say. | 13.4, 16 |

### 20.3 Waiting On

| # | Item | From | Until then | Affects |
|---|---|---|---|---|
| 1 | Test server, the `demo-pharma` test sheet (10 test logins, items for every result), and the mail page for emailed codes. No date given. | Backend team | Postman mock server (fixed answers, no emails) | 17 |
| 2 | The client office's email and phone for Request access | Client | Placeholder values in the development configuration | 13.9 |
| 3 | Certificate layout, branding, and content | Client | Plain layout from the design tokens | 13.3 |
| 4 | Firebase project for Crashlytics (Android and iOS apps registered) | Project owner | Crash reporting off in the `mock` flavor | 2.2 |
| 5 | iOS flavor schemes and build configurations (`mock`, `staging`, `live`) | Project owner (needs a Mac with Xcode) | iOS builds the `live` configuration only | 2.3 |

### 20.4 Future (Needs the Backend First)

Not in v1. Each item starts only after the backend team documents its route in `app-api-guide.md` and the Postman collection.

| # | Feature | Backend work needed | App work then |
|---|---|---|---|
| 1 | Dashboard data on Home | A dashboard route | `DashboardApiService`, Home dashboard section (Decision 5) |
| 2 | Product list | A product list route | `products` feature, `/home/products` route, `ProductApiService` |
| 3 | In-app access request form (name, phone, organisation, email, job title, reason) | A public route without login, its abuse protection, and a change to backend decision D27 | `access_request` feature, `AccessRequestApiService`; the form replaces the email and call buttons |
