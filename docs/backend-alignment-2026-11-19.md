# The app against the backend plan: what matches, what is left, what differs

**Date:** 2026-11-19. **Backend plan audited:** `ProtectB-DOCS-initial` at commit `4ec8318` (2026-11-18 15:42), the latest on `main`. **App:** branch `feature/backend-plan-alignment` at `93ada90`.

**How it was checked:**
1. The backend's latest guide, Postman collection and examples were put in place of the app's copy, and the app's 1053 CI tests were run against them. **All passed.**
2. Three reviews read the guide (`mobileApp/app-api-guide.md`), the build guide, decisions D1–D64 and SRS v1.2 line by line against the app's code.
3. Every difference below was checked again against the document text and the code.

## Summary

| | Count | In short |
|---|---|---|
| **Match** | about 90 items | Every route, field, status, error code, rate limit and SRS requirement the app uses |
| **Mismatch, app to fix** | 4 (all small) | A stack answer that cannot be read; two error texts; one wording; one photo size case |
| **Deliberate differences** | 2 | "Not now" on a forced password change; History rows without the official's name |
| **Left: owned by others** | 13 | 4 with the backend team, 6 with the client, 3 that need a real phone |
| **Small open questions** | 3 | Points the guide does not settle |

Nothing found blocks testing or release. The app follows the backend's contract.

## What changed in the backend plan since the app was aligned (2026-11-17 → 2026-11-18)

| Change | What it means for the app |
|---|---|
| Postman: the "Scanner sessions" folder is now **built and tested** (it said "changing, not built yet") | Scanner mode's routes are final. The app already uses them as built. |
| Guide §6.2: a photo's `503` now also means the storage **did not take the photo within 10 seconds** (review R1, fixed) | The app already treats `503` as "Not sent. Tap to send again", and resending the same photo is never counted twice. Its timeouts (send 60 s, answer 30 s) wait longer than the server's 10 s, so the server's `503` arrives rather than a phone timeout. **No change needed.** |
| Review of 2026-11-18, R3: a stack refused with `503` still counts its serials toward the 500-a-minute limit | The app resends a `503` stack once after a second, as the guide says. An official whose stacks keep getting `503` may reach the limit sooner and gets a `429`, which the app counts down. Backend-side; nothing for the app. |
| Review R7: stacks of 50 under a burst need a test on the real server | Backend-side. |
| Fix of 2026-11-18: dropped database connections no longer end a server program | Backend-side; no contract change. |

The app's copy of the docs (`docs/protectb-api/`, from `ebff1d9`) differs from the latest only in those two text lines. Refreshing it changes no behaviour.

## Match

| Area | What matches | Where in the app |
|---|---|---|
| Address and passes | `https://…/v1/clients/<slug>/`; `Authorization: Bearer`; passes only in secure storage, never in logs; the phone ID only in the login and code bodies | `app_config.dart`, `auth_interceptor.dart`, `flutter_secure_storage_service.dart`, `logging_interceptor.dart` |
| Login (§3.1–3.5) | Decided by `data.status`; one message for every failed login; 6-digit code; one resend a minute, three in all; one renewal at a time, both passes stored first; `401` → Login; logout keeps the phone trusted | `auth_repository_impl.dart`, `verify_code_bloc.dart`, `dio_session_service.dart` |
| Password (§3.6–3.7, D54, D64) | Forced change blocks everything else; the rule (8–128 characters, a letter, a number, no control characters, counted in characters); forgot always says the same; the reset code's guess ceiling shown as "wrong or expired" | `password_policy.dart`, `change_password_screen.dart`, `reset_password_screen.dart` |
| Sign up (§3.9) | Roles without a login; the order name → role → password → email → code; `409` uses the code up; `404` reloads the roles; no roles → "Ask the office" | `request_access_cubit.dart`, `request_access_screen.dart` |
| Profile and permissions (§3.8, §4) | `GET me` fields; the four permissions decide what shows; a `403` reloads the profile | `profile_dto.dart`, `main_shell.dart`, `route_guard.dart` |
| One check (§4.1–4.2) | `GET formats` decides the input (nothing built in); only the part after the last `/q/` is sent; every result, reason, count, item and batch field | `qr_link_parser.dart`, `input_format_validator.dart`, `verification_mappers.dart` |
| Scanner mode (§4.3–4.6) | A UUID v4 per session, saved before the first scan; each QR sent at once; `repeat` adds no row; the counts are the server's; `session_full` / `session_ended` → new session and the scan sent again; `session_not_yours` → new session; at most 2 scans a second; `503` → "scan again", nothing queued; end sent without waiting; crash resume reads the session; Finish ends with a summary | `scan_session_cubit.dart`, `active_scan_store.dart` |
| Serial stacks (§4.7) | 1–50 different serials, more refused, never split; all or nothing; `503` sent again once after a second; a lost answer never sent again by itself | `serial_stack_cubit.dart` |
| History (§5) | Filters, 50 a page, cursor until `null`, totals, no `scope`; a session's checks by `session_id` | `history_api_service.dart`, `history_bloc.dart` |
| Reports and photos (§6) | Note 1–1,000; optional check and retail user; the photo as the raw file; 2,048 px, quality 85, at most 1 MB, no metadata; at most 3 within an hour; never filed twice by itself; My reports | `incident_*`, `photo_service.dart`, `report_incident_bloc.dart` |
| Retail users (§7) | Search by part of a name or a whole email; masked emails shown as sent; only with `incident:report` | `retail_user_*` |
| Errors (§1) | The envelope read into one typed error; all 15 codes mapped; "Reference: …" shown; `Retry-After` in seconds or as a date; none → "Try again later"; `app_preparing` | `error_mapper.dart`, `failure_message.dart` |
| SRS v1.2 | ACC, PRM, LKP, SCN, HIS-01–03 and -05, INC, RTL, REQ, STK, GEN requirements and use cases UC-01–UC-11; NFR security, privacy (no location permission), usability, capacity, reliability; Bangladesh time; English and Bangla; offline (nothing queued) | the screens of each feature |

## Mismatches the app should fix (all small)

**1. A stack answer that cannot be read can be sent again.**
- **What the plan says:** guide §4.7: "All or nothing: when the answer is not 200, nothing was recorded." So a `200` means the stack *was* recorded. final.md §13.3: a recorded stack "is never sent again".
- **What the app does:** it treats a `200` as recorded only when the items' number or order is wrong. A `200` with a field of the wrong type becomes a general error, and **Submit** stays on (`serial_stack_cubit.dart:138-142`).
- **Effect:** if the server ever sends a malformed `200`, one more tap checks every serial twice, and the second answers say "checked before".
- **Fix:** treat any unreadable `200` from `lookups/serials` as recorded, as the count case already is.

**2. Some unknown error codes show the app's text instead of the server's.**
- **What the plan says:** final.md §16: an `error.code` the app does not know shows the server's message.
- **What the app does:** on a `503` (and a `429`) any code becomes "The service is busy. Try again shortly." or the countdown (`error_mapper.dart:185-191`).
- **Effect:** a new `503` code from the backend would lose its own explanation. The reference still shows.
- **Fix:** use the server's message when a `503` or `429` carries a code the app does not know.

**3. The Sign up ending promises the wrong email.**
- **What the plan says:** guide §3.9: "Your request was sent. You will get an email when it is answered."
- **What the app does:** "…email you when your account is ready" (`accessPending`).
- **Effect:** someone whose request is **refused** also gets an email, which the app's text does not lead them to expect.
- **Fix:** follow the guide's words (English and Bangla).

**4. One kind of photo can stay larger than 2,048 px.**
- **What the plan says:** SRS: "shrink each photo to 2,048 pixels on its longer side".
- **What the app does:** when the phone cannot read a photo's size (some HEIC photos), it asks the compressor for 2,048 × 2,048. Android keeps both sides at least that, so a 4:3 photo comes out about 2,731 px long (`photo_service.dart:116-120`).
- **Effect:** none for the server (the 1 MB limit still holds), but it misses the SRS's size.
- **Fix:** read the size from the compressed result and shrink again if it is still over 2,048 px.

## Deliberate differences (decided, documented)

**"Not now" on a forced password change.**
- **The SRS:** a password set by someone else "shall have to be changed before anything else can be done, unless whoever made the account chose otherwise".
- **The decision:** the client wants **Not now** for every official (final.md M1, 2026-11-16). It was requested from the backend (`docs/backend-requests/password-change-later.md`, question B2).
- **Today:** the app shows **Not now** only when the server sends `password_change_skippable`. Staging and live builds refuse the mock's demo switch, so on a real server the app follows the SRS until the backend ships the route.
- **To close it:** the backend ships the route and updates the SRS, or the client withdraws the request.

**History rows do not name the official.**
- **The SRS:** FR-HIS-04: each row shows "… the official, and the session if any".
- **The decision:** History shows only the official's own checks, so the name is left out, and a session shows as "In a session" (final.md N2, user decision 2026-11-17; backend D61 removed everyone's history).
- **To close it:** the backend notes the change in the SRS.

## Left: owned by others

| Owner | Item | What it unblocks |
|---|---|---|
| Backend | B1: a test server (address, slug, test logins, items for every result, the mail page) | 35 manual cases (Session C); the first run against a real server |
| Backend | B2: `me/password/later` and its fields | TC-AUTH-095; closes the first deliberate difference |
| Backend | B3: five contract points: History days in UTC or Bangladesh time; QR case; renewal during a forced change (200 or 403); empty logout body; a new password equal to the current one. Also open: emails matched without case, and Latin digits only | Each answer changes one small behaviour; the app works as written today |
| Backend | B4: plain placeholder passes in the Postman examples | The mock build's stand-in passes can go |
| Client | B5: review all 326 Bangla texts | The Bangla release |
| Client | B6: legal name; B7: icon artwork; B8: live server, slug, office contacts, store-key owner; B9: screenshots, dark mode, first-start language, Bangla digits; B10: Firebase | Release build, store listing, crash reports |
| Device | Sessions A and B on a real phone (camera, TalkBack, release build), and the scanner-mode run with the QR sheet (TC-MIG-055) | 117 manual cases |

The questions are in `docs/backend-requests/2026-11-19-backend-questions.md` and `docs/client-requests/2026-11-19-client-questions.md`.

## Small open questions (not mismatches)

1. **A `401` on a password change** always shows "The current password is incorrect." If the login itself had ended (the office logged out all phones), the official sees that text and is not sent to Login. The guide does not say how to tell the two apart. **To ask the backend.**
2. **Name length on Sign up:** the app counts 1–100 *characters* (code points), as the password rule does. The guide does not say how the server counts.
3. **"A number" in a password:** the app accepts any script's digits (D54). If the server's check is wider, the app is only stricter, never looser.

## Checked and sound
- The camera never sends a QR still in view again after a failed scan (`DetectionSpeed.noDuplicates`). **Scan again** restarts it.
- Every `401` from the backend carries a code. Only a non-backend page (a proxy) gives a codeless `401`, which shows the general error.
- Ending a session that was never used answers `404`, which the app ignores, as the guide allows.
