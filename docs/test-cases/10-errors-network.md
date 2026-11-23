# ERR: Errors, Limits, and Network

> **2026-11-16 baseline:** [16-mobile-migration.md](16-mobile-migration.md) replaces conflicting cases for hidden-code input, bulk submission, everyone scope, retail administration, certificates, and email-only access requests. Historical IDs/counts below remain for traceability; do not execute retired cases as release requirements. Current architecture: ../../final.md.


| Field | Value |
|---|---|
| Spec | final.md §14.2, §15.2, §15.4–15.5 |
| API | every route |
| Automated in | `error_mapper_test`, `session_renewal_test`, `test/flow/lookup_flow_test.dart` |
| Format | [Case format and type tags](README.md#3-case-format) |

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-ERR-001 | One typed error per code | NET | P1 | AUTO | ✅ `error_mapper_test` | Fake backend | Every `error.code` | The matching error type with `code` and `request_id` | §15.4, §18.3 Errors |
| TC-ERR-002 | Reference on every error | NET | P1 | MOCK | ✅ `login_screen_test` | Mock build | Any error screen | "Reference: …" shown and selectable | §14.1 |
| TC-ERR-003 | No connection | NET | P1 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Airplane mode; Check a serial | "Unable to check. Check the connection and try again." | §13.1.6 |
| TC-ERR-004 | Rate limit countdown | NET | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | Any `429 Retry-After` | Seconds counted down from the header | §18.3 Rate limits |
| TC-ERR-005 | Proxy HTML error page | WORST | P2 | AUTO | ✅ `error_mapper_test` | Fake backend | `503` with HTML body | "The service is busy…" | §15.4 |
| TC-ERR-006 | Unknown route | NEG | P3 | AUTO | ✅ `flow/role_nav_flow_test` | Fake backend | Open an unknown path | "Not available." with Try again | §9.5 |
| TC-ERR-007 | `400` on every request | NET | P2 | AUTO | ✅ `flow/error_matrix_flow_test` | Fake backend | Each request of the matrix below answers `400 validation_failed` | "Something went wrong. Try again." with "Reference: …", or the route's own text where the matrix names one; logged with its `request_id` | §15.4 |
| TC-ERR-008 | `413` and `415` | NET | P3 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `POST incidents` answers `413`, a photo answers `415`, both with `validation_failed` | Handled as `400` | §15.4 |
| TC-ERR-009 | `401 unauthenticated` on every logged-in request | STATE | P1 | AUTO | ✅ `flow/error_matrix_flow_test` | Fake backend | Each request of the matrix below that needs a login answers `401 unauthenticated` | Login screen; both passes deleted (except where the matrix names its own `401` text) | §6.5, §15.4 |
| TC-ERR-010 | `403 forbidden` on every gated request | STATE | P1 | AUTO | ✅ `flow/error_matrix_flow_test` | Fake backend | Each request of the matrix below that needs a permission answers `403 forbidden` | The profile reloads; a feature whose permission is gone is hidden | §7.2, §15.4 |
| TC-ERR-011 | `404 not_found` on every request | NET | P2 | AUTO | ✅ `flow/error_matrix_flow_test` | Fake backend | Each request of the matrix below answers `404 not_found` | "Not available.", or the route's own text where the matrix names one | §14.2, §15.4 |
| TC-ERR-012 | `409` where the route has no 409 case | WORST | P3 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `GET checks` and `GET formats` answer `409 conflict` with a message | History shows the server's message (guide §1: "Show the message"), with its reference; formats show their own text; no crash | §15.4; guide §1 |
| TC-ERR-013 | `429` on every request | NET | P1 | AUTO | ✅ `flow/error_matrix_flow_test` | Fake backend | Each request of the matrix below answers `429` with `Retry-After: 30` | "Too many attempts. Try again in 30 s." counting down; never retried by itself | §15.5, §12.1 API protection |
| TC-ERR-014 | `503 app_preparing` outside lookups | NET | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `GET checks` and `GET incidents` answer `503 app_preparing` | "The app is being prepared. Try again later." | §15.4 |
| TC-ERR-015 | `503 service_unavailable` on every request | NET | P2 | AUTO | ✅ `flow/error_matrix_flow_test` | Fake backend | Each request of the matrix below answers `503 service_unavailable` | "The service is busy. Try again shortly."; resent only where the route allows (bulk **Send again**, a photo) | §15.4 |
| TC-ERR-016 | `500`, `502`, and `504` | NET | P2 | AUTO | ✅ `flow/error_matrix_flow_test`, `flow/errors_edge_flow_test` | Fake backend | `GET checks` answers `500 internal_error`, then `502` and `504` without an envelope | "Something went wrong. Try again." with "Reference: …" (no reference line when the answer has none) | §15.4 |
| TC-ERR-017 | Unknown error code | EDGE | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `POST lookups` answers `400` with `error.code: "brand_new"` and a server message | The server message is shown (the fallback for an unknown code) with the reference; never a result | §16 |
| TC-ERR-018 | Error without a reference | EDGE | P3 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | An error envelope without `request_id` | The message without a reference line (never "Reference: null" or an empty one) | §14.1 |
| TC-ERR-019 | Server text never replaces the app text | I18N | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | Login answers `401 unauthenticated` with the server message "Some other text" | "Email or password is incorrect." (chosen by `error.code`) | §16 |
| TC-ERR-020 | Success answer without `data` | WORST | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `GET me`, `POST lookups`, `GET checks` answer `200` with `success: true` and no `data` | An error each time; never a blank screen, a crash, or a result | §15.2, §13.1.5 |
| TC-ERR-021 | `success: false` with `200` | WORST | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `POST lookups` answers `200` with `success: false` and an error object | Treated as an error (with its reference); never a result | §15.2 |
| TC-ERR-022 | Empty or cut-off body | WORST | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `GET checks` answers `200` with an empty body, then with `{"success": tr` | An error with Try again; no crash | §15.2 |
| TC-ERR-023 | Captive portal page | WORST | P1 | AUTO + DEVICE | ✅ `flow/errors_edge_flow_test` | Fake backend; a phone on a hotel or shop Wi-Fi with a login page | Every request answers `200` with an HTML login page; then the network works again | An error each time, never a result and never a logout; everything works again on a real network | §15.2 |
| TC-ERR-024 | Proxy HTML page with 403 or 404 | WORST | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `GET checks` answers `403` with an HTML page (no envelope); then `404` the same way | 403: a general error; 404: "Not available." (decided by the status, guide §1); no profile reload loop; no logout | §15.4 |
| TC-ERR-025 | `Retry-After` missing | EDGE | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `POST lookups` answers `429` with no `Retry-After` | Spec gap 12. Never retried by itself | §12.1 API protection |
| TC-ERR-026 | `Retry-After: 0` | BVA | P3 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `429` with `Retry-After: 0` | A retry is possible at once; no countdown stuck at 0 | §15.5 |
| TC-ERR-027 | `Retry-After` as a date | EDGE | P3 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `429` with `Retry-After: Wed, 21 Oct 2026 07:28:00 GMT` (past) | A past date is no wait: a manual retry; nothing sent by itself; no crash. A date still to come counts down (TC-ERR-048) | §15.5 |
| TC-ERR-028 | `Retry-After` very large | BVA | P3 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | `429` with `Retry-After: 86400` | The countdown text fits the screen; nothing sent before it ends | §15.5 |
| TC-ERR-029 | Leaving and returning during a countdown | STATE | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | Lookup answers `429` with `Retry-After: 60`; open History; return after 10 s; Check again (answered `429` again) | No request loop; the new answer shows its own countdown | §15.5 |
| TC-ERR-030 | Countdown while in the background | STATE | P3 | DEVICE | ✋ | Real phone | `429` with `Retry-After: 60`; put the app in the background 70 s; return | The countdown has ended; a retry is possible | §15.5 |
| TC-ERR-031 | Request timeout | NET | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend; no answer | Open History; no answer comes | "No connection. Check the internet and try again." with Try again after the timeout; no endless loading | §15.4 |
| TC-ERR-032 | Unknown host or no internet behind Wi-Fi | NET | P2 | DEVICE | ✋ | Real phone; Wi-Fi with no internet | Log in; open History; look up | The connection message each time | §15.4 |
| TC-ERR-033 | Untrusted certificate | SEC | P1 | DEVICE | ✋ | Real phone; a proxy with a certificate the phone does not trust | Use the app through the proxy | Every request fails with the connection message; nothing readable in the proxy | §12.1 Transport |
| TC-ERR-034 | Connection lost during a next page | NET | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend | History page 2 fails with no connection | Page 1 rows kept; a footer with Retry | §10.4 |
| TC-ERR-035 | Back online | STATE | P2 | DEVICE | ✋ | Real phone | Airplane mode; open History (error); airplane mode off; **Try again** | Loads without restarting the app | §14.2 |

## Offline Banner

**Blocked until built** (`final.md` §14.2). Entry criteria: `ConnectivityService` (core, `connectivity_plus`) with a status stream, and `NetworkStatusBanner` (shared) above every screen. Test fake to add with it: `FakeConnectivityService` with a stream the test sets online and offline. The case plan: [remaining-work-test-plan.md §4.3](../remaining-work-test-plan.md#43-offline-banner).

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-ERR-036 | Offline banner | NET | P2 | DEVICE | ✋ | Real phone | Airplane mode on any screen; then off | The offline banner shows, then goes | §14.2 |
| TC-ERR-037 | The banner on every main screen | NET | P2 | AUTO | ✅ `flow/offline_banner_flow_test` | `FakeConnectivityService` | Set offline on Check, a result, Bulk lookup, History, Report incident, My reports, Retail users, Profile | The banner shows on each | §14.2 |
| TC-ERR-038 | The banner goes when back online | NET | P2 | AUTO | ✅ `flow/offline_banner_flow_test` | Fake backend; `FakeConnectivityService` | Set offline, then online | The banner shows, then goes | §14.2 |
| TC-ERR-039 | The banner on the login screens | NET | P3 | AUTO | ✅ `flow/offline_banner_flow_test` | logged out | Set offline on Login, Check your email, Forgot password | The banner shows on each | §14.2 |
| TC-ERR-040 | The banner never blocks | STATE | P2 | AUTO | ✅ `flow/offline_banner_flow_test` | offline | Type a serial; Check | The lookup is tried and shows its own connection message; every button still works | §13.1.6, §14.2 |
| TC-ERR-041 | Back online sends nothing by itself | WORST | P1 | AUTO | ✅ `flow/offline_banner_flow_test` | Fake backend; `FakeConnectivityService` | A lookup fails offline; set online | No request is sent until the official asks again | §12.1 API protection |
| TC-ERR-042 | Wi-Fi without internet | EDGE | P3 | AUTO | ✅ `flow/offline_banner_flow_test` | connectivity "online", requests fail | Open History | No banner (it follows `ConnectivityService`); the connection message and Try again as today | §14.2 |
| TC-ERR-043 | A flapping connection | WORST | P3 | AUTO | ✅ `flow/offline_banner_flow_test` | Fake backend; `FakeConnectivityService` | Switch offline and online 10 times in 5 s; end online | No crash; no banner at the end | §14.2 |
| TC-ERR-044 | Read by TalkBack | A11Y | P2 | AUTO + DEVICE | ✅ `flow/offline_banner_flow_test` (the live region and its label); the spoken text on a phone: ✋ | Fake backend; `FakeConnectivityService` | Set offline | The banner is announced (a live region with a label) | §14 |
| TC-ERR-045 | Fits at 3× font and 320 px | A11Y | P3 | AUTO | ✅ `flow/offline_banner_flow_test` | text scale 3.0; 320 × 568 | Set offline on every main screen | No layout error | §14 |
| TC-ERR-046 | The banner in Bangla | I18N | P3 | AUTO | ✅ `flow/language_flow_test` | App in Bangla | Set offline | The banner text in Bangla | §14.2, §16 |
| TC-ERR-047 | A proxy page decided by its status | WORST | P2 | AUTO | ✅ `core/network/error_mapper_test` | An answer with no envelope | 400, 413, 415, 403, 404, 502 | A defect (logged) for 400/413/415; a general error for 403 and 502; "Not available." for 404 | Guide §1 |
| TC-ERR-048 | `Retry-After` as seconds or a date | EDGE | P3 | AUTO | ✅ `core/network/error_mapper_test` | — | `30`, `-1`, `soon`, a date 45 s ahead, a past date | 30 s; none; none; 45 s; none (a manual retry) | Guide §1 |
| TC-ERR-049 | A refused certificate | NET | P2 | AUTO | ✅ `core/network/error_mapper_test` | A TLS certificate error | Any request | Counted as not sent: safe to send again | §15.4 |
| TC-ERR-050 | An unknown code on a busy or wait answer | NET | P2 | AUTO | ✅ `flow/errors_edge_flow_test` | Fake backend: `503 storage_slow` and `429 daily_quota` with messages; `503 service_unavailable` | Look up | The server's message for the unknown codes, the app's "The service is busy…" for the known one; the reference on each; no result | final.md §16 |
| TC-ERR-051 | A `409 conflict` shows the server's message | NEG | P2 | AUTO | ✅ `shared/failure_message_test`, `flow/errors_edge_flow_test` | Unit; fake backend | A 409 `conflict` with a message, with a blank one, and without one; another known code (`forbidden`) with a message; an unknown code | The 409's message is shown; a blank or missing one falls back to "Something went wrong. Try again."; other known codes keep the app's text; an unknown code still shows the server's message | guide §1 (error table) |

## Request Matrix

ERR-007 … -016 run every request below. "Own handling" is where the route has its own text instead of the general one.

| # | Request | Screen | Own handling |
|---|---|---|---|
| 1 | `POST auth/login` | Login | `401`: "Email or password is incorrect." |
| 2 | `POST auth/verify-phone` | Check your email | `401`: the wrong-code text |
| 3 | `POST auth/resend-code` | Check your email | `401`: back to Login (AUTH-008) |
| 4 | `POST auth/password/forgot` | Forgot password | — |
| 5 | `POST auth/password/reset` | Reset password | `401`: the wrong-code text; `403 policy_denied` |
| 6 | `POST me/password` | Set a new password, Change password | `401`: "The current password is incorrect."; `403 policy_denied` |
| 7 | `GET me` | Splash; after a `403` | `401`: Login |
| 8 | `GET formats` | Check tab | "Could not load the code formats." |
| 9 | `POST lookups` | Check tab | `503 app_preparing`; no connection: "Unable to check…" |
| 10 | `POST lookups/bulk` | Bulk lookup | `503`, `429`: the same list again |
| 11 | `GET checks` | History | — |
| 12 | `POST incidents` | Report incident | `404`: remove the link; no connection: "The report may have been filed…" |
| 13 | `POST incidents/{id}/photos` | Report incident | `400`, `404`, `409`: refused; `429`, `503`, `5xx`, no connection: send again |
| 14 | `GET incidents` | My reports | — |
| 15 | `GET retail-users` | Retail users, the picker | — |
| 16 | `GET retail-roles` | Add retail user | — |
| 17 | `POST retail-users` | Add retail user | `409`: email used; `404`: role gone |
| 18 | `POST retail-users/{id}/password` | Retail users | `409`: own password set; `404`: not found or blocked |
| 19 | `POST auth/logout` | Profile | Any failure: Login anyway |
| 20 | `POST auth/refresh` | (renewal) | SESS-003, -004, -011 … -017 |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 12 (`Retry-After` missing or not in seconds), 13 (the offline banner, built 2026-11-19).
