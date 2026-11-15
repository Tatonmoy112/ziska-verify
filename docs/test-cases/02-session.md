# SESS: Staying Logged In

| Field | Value |
|---|---|
| Spec | final.md §6.1, §6.3–6.5, §6.7, §9.4 |
| API | `auth/refresh`, `auth/logout`, `GET me` |
| Automated in | `test/flow/auth_flow_test.dart`, `phone_id_service_test`, `session_renewal_test`, `auth_repository_test` |
| Format | [Case format and type tags](README.md#3-case-format) |

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-SESS-001 | Phone ID made once | STATE | P1 | AUTO | ✅ `phone_id_service_test` | Fake backend | First run; restart; log out; restart | Same 43-character ID every time | §6.1, §18.3 Phone ID |
| TC-SESS-002 | Session survives a restart | STATE | P1 | MOCK | ✅ `flow/auth_flow_test` | Mock build | Log in; close the app fully; open it | Splash, then Home without logging in | §6.7 |
| TC-SESS-003 | Silent renewal after 20 minutes | STATE | P1 | STAGE | ✅ `session_renewal_test` | Staging build, backend test sheet | Log in; leave the app 20 min; open History | Data loads; no Login screen | §6.4, §18.3 Session |
| TC-SESS-004 | One renewal for two failing requests | WORST | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | Two requests fail `token_expired` together | One `auth/refresh`; each request retried once | §6.4, §18.3 Renewal |
| TC-SESS-005 | Logout | POS | P1 | MOCK | ✅ `flow/auth_flow_test` | Mock build | Profile → **Log out** → confirm | Login screen; passes deleted; phone ID kept | §6.5, §18.3 Session |
| TC-SESS-006 | Logout cancel | POS | P3 | MOCK | ✅ `flow/auth_flow_test` | Mock build | Profile → Log out → **Cancel** | Still on Profile, logged in | §13.8 |
| TC-SESS-007 | Next login after logout needs no code | POS | P1 | STAGE | ✋ | Staging build, backend test sheet | Log out, log in again on the same phone | No code screen | §6.5, §18.3 Session |
| TC-SESS-008 | Ended login lands on Login | STATE | P1 | AUTO + STAGE | ✅ `session_renewal_test` | Fake backend; Staging build, backend test sheet | Admin blocks the official or logs out all phones; use the app | Next request → Login screen | §6.5 |
| TC-SESS-009 | Logout works offline | NET | P2 | AUTO | ✅ `auth_repository_test` | Fake backend | Log out with no connection | Login screen anyway; passes deleted | §6.5 |
| TC-SESS-010 | Profile failure at start | NET | P2 | MOCK | ✋ | Mock build | Start the app with no connection while logged in | Splash shows the error and **Try again**; retry works once online | §9.4 |
| TC-SESS-011 | Renewal refused: Login, phone ID kept | STATE | P1 | AUTO | ✅ `flow/session_edge_flow_test`, `session_renewal_test` | Fake backend | A request answers `401 token_expired`; `auth/refresh` answers `401 unauthenticated` | Login screen; both passes deleted; the phone ID unchanged | §6.4 |
| TC-SESS-012 | Renewal offline keeps the login | NET | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | A request answers `401 token_expired`; `auth/refresh` has no connection; then the connection returns and the official opens History again | Still logged in, passes kept; "No connection. Check the internet and try again."; the next request renews and loads (only `401 unauthenticated` ends a login) | §6.4, §6.5 |
| TC-SESS-013 | Renewal answered 503 | NET | P2 | AUTO | ✅ `session_renewal_test` | Fake backend | `auth/refresh` answers `503 service_unavailable` | Still logged in; "The service is busy. Try again shortly." | §6.4, §15.4 |
| TC-SESS-014 | Three requests expire together | WORST | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | Three requests at once answer `401 token_expired` | One `auth/refresh`; each of the three retried once | §6.4 |
| TC-SESS-015 | A retry that expires again | WORST | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | After a renewal, the retried request answers `401 token_expired` again | Not retried a second time and no second renewal loop; an error is shown | §6.4, §12.1 API protection |
| TC-SESS-016 | New passes stored before the retry | STATE | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | Renewal answers `200` | Both new passes are in secure storage before the retried request is sent; the retry carries the new access pass | §6.4 |
| TC-SESS-017 | A refresh pass is sent only once | SEC | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | Two expiries one after the other | The second `auth/refresh` carries the refresh pass from the first renewal's answer, never the first one again | §6.4 |
| TC-SESS-018 | Renewal has no Authorization header | SEC | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | A renewal | `auth/refresh` has no `Authorization` header; its body holds `refresh_token` only | §6.4 |
| TC-SESS-019 | Login routes carry no pass | SEC | P2 | AUTO | ✅ `flow/session_edge_flow_test` | Fake backend | Requests to `auth/login`, `auth/verify-phone`, `auth/resend-code`, `auth/password/forgot`, `auth/password/reset` | No `Authorization` header on any | §12.1 Authorization |
| TC-SESS-020 | An expired lookup is checked once | WORST | P1 | AUTO | ✅ `session_renewal_test` | Fake backend | `POST lookups` answers `401 token_expired`; the renewal works; the retry answers `200` | Exactly one retry (two `POST lookups` in all, the first refused); one result screen | §6.4, §8.3 |
| TC-SESS-021 | Back after 20 minutes in the background | STATE | P2 | STAGE + DEVICE | ✋ | Staging; real phone | Log in; put the app in the background 20 minutes; return and open History | Data loads after a silent renewal; no Login screen | §6.4, §18.3 Session |
| TC-SESS-022 | App killed during a renewal | WORST | P3 | STAGE + DEVICE | ✋ | Staging; real phone | Let the access pass expire; open History and kill the app at once; open it | Home (the new passes were stored) or Login (the used refresh pass ended the login); never a crash or an endless loading | §6.4 |
| TC-SESS-023 | No passes stored at start | STATE | P1 | AUTO | ✅ `flow/session_edge_flow_test` | Fake backend; storage holds the phone ID only | Start the app | Login screen; the phone ID unchanged | §6.7, §9.4 |
| TC-SESS-024 | One pass missing at start | WORST | P2 | AUTO | ✅ `flow/session_edge_flow_test` | Fake backend; only the refresh pass stored, then only the access pass | Start the app | Never Home without a working session: Login, or a renewal that works | §6.7 |
| TC-SESS-025 | Secure storage cannot be read | WORST | P2 | AUTO | ✅ `phone_id_service_test` | Fake backend; storage read throws | Start the app | Spec gap 8 for the screen. No crash; the phone ID is not replaced by a new one (never regenerated on error) | §6.1 |
| TC-SESS-026 | `GET me` answers 401 at start | STATE | P1 | AUTO | ✅ `flow/session_edge_flow_test` | Fake backend; logged in | Start the app; `GET me` answers `401 unauthenticated` | Login screen; both passes deleted | §6.7 |
| TC-SESS-027 | Admin changes the role or sets a new password | STATE | P2 | STAGE | ✋ | Staging; portal access | Logged in; in the portal change the role, use the app; log in again; in the portal set a new password, use the app | Each time the next request lands on Login | §6.5 |
| TC-SESS-028 | Logout with a request in flight | WORST | P2 | AUTO | ✅ `flow/session_edge_flow_test` | Fake backend; slow `GET checks` | Open History; log out before it loads | Login screen; the late answer brings back no screen or data; no crash | §6.5, §9.5 Session moves |
| TC-SESS-029 | Logout answered 500 | NET | P2 | AUTO | ✅ `flow/session_edge_flow_test` | Fake backend | `auth/logout` answers `500` | Login screen anyway; both passes deleted | §6.5 |
| TC-SESS-030 | Logout tapped twice | WORST | P3 | AUTO | ✅ `flow/session_edge_flow_test` | Fake backend | Confirm **Log out**, and tap it again at once | One `auth/logout`; Login screen | §6.5 |
| TC-SESS-031 | Phone clock wrong | EDGE | P2 | DEVICE | ✋ | Real phone, mock or staging | Set the phone clock 2 days ahead, then 2 days behind; use the app 30 minutes each | The app works; a renewal happens only when the server answers `token_expired`; no extra Login | §6.4 |
| TC-SESS-032 | Session survives an app update | STATE | P2 | DEVICE | ✋ | Real phone; two builds | Logged in; install a newer build over the old one; open; log out and log in | Home without logging in; the next login needs no code (phone ID kept) | §6.1 |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 8 (secure storage that cannot be read).
