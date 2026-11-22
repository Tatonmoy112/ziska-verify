# STG: Integration with the backend's test server

| Field | Value |
|---|---|
| Spec | final.md §17 (environments), §15 (contract); app API guide |
| Server | `https://testapp.protecb.com`, client `ziska-test` (the staging build, `config/staging.json`) |
| Automated in | `test/staging/` (the server's real answers, saved by `tool/staging_check` and replayed offline from `test/fixtures/staging/`), `test/app/config/app_config_test.dart` |
| Record | [staging-integration-2026-11-22.md](../staging-integration-2026-11-22.md) |
| Format | [Case format and type tags](README.md#3-case-format) |

The integration runs one step at a time. For each step, the cases come first (normal, edge, worst), then the checker against the server, then tests on its real answers, then the screens on the emulator.

## Step 1. Connection and errors

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-001 | The public roles as the server sends them | POS | P1 | AUTO | ✅ `staging/step1_connection_test` | The server's real `roles/requestable` answer | Read it with the app's Sign up service | Distributor (2) and Retail seller (1), in the server's order | Guide §3.9 |
| TC-STG-002 | A route needing a login, asked without one | NEG | P1 | AUTO | ✅ `staging/step1_connection_test` | The server's real `401` answer for `formats` | Read it with the app's client | "Not logged in" (`unauthenticated`), status 401, with its reference | Guide §1 |
| TC-STG-003 | An unknown route | NEG | P2 | AUTO | ✅ `staging/step1_connection_test` | The server's real `404` answer | Read it with the app's client | "Not available" (`not_found`) with its reference | Guide §1 |
| TC-STG-004 | Sign up offers the server's roles | POS | P1 | AUTO | ✅ `staging/step1_connection_test` | The real roles answer through the whole app | Login → Sign up → open the role list | Distributor and Retail seller offered | Guide §3.9 |
| TC-STG-005 | The server address: host alone, https | WORST | P1 | AUTO | ✅ `app/config/app_config_test` | `API_BASE_URL` as the whole API address, with a path, a query, a fragment, a login, a placeholder, no scheme; with spaces, two slashes, capitals, a port | Start a build | The whole API address refused with a message naming the host to use and `CLIENT_SLUG`; the other bad ones refused; the good ones read as `https://host[:port]` | final.md §12.1, §17 |
| TC-STG-006 | The client name | WORST | P1 | AUTO | ✅ `app/config/app_config_test` | `CLIENT_SLUG` `ziska-test`, `ziska`; then with capitals, a space, `/`, `_`, a leading `-`, empty, a placeholder; with surrounding spaces | Start a build | Lower-case letters, digits and `-` accepted (spaces around removed); the rest refused at start (the server answers 404 for any other name) | Backend review 2026-11-18 |
| TC-STG-007 | The staging app on a phone reaches the server | E2E | P1 | DEVICE | ✋ | Staging build on the emulator or a phone | Open the app; Login → Sign up | Login shows; Sign up's role list comes from the server (Distributor, Retail seller) | final.md §17 |

## Step 2. Login and staying logged in

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-008 | A new phone: login, the emailed code, in | POS | P1 | AUTO | ✅ `staging/step2_login_session_test` | The server's real answers: login `code_sent`, verify-phone `logged_in`, `me`, `formats` | Log in; enter the code | The login sends email, password and phone ID only; the code goes with the server's challenge and the same phone ID; both passes stored; the Check tab with the official's name | Guide §3.1, §3.2 |
| TC-STG-009 | A trusted phone logs in without a code | POS | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real `logged_in` answer of a login on a trusted phone | Log in | Straight in: no code screen, no verify-phone | Guide §3.1 |
| TC-STG-010 | Renewal with the real answer | STATE | P1 | AUTO | ✅ `staging/step2_login_session_test` | A request answering `token_expired`; the real `auth/refresh` answer | Open History | One renewal; both new passes stored; the request sent once more with the new pass | Guide §3.4 |
| TC-STG-011 | Logout as the server accepts it | NET | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real logout answers: bare → 200, empty JSON body → `400 validation_failed` | Log out | Sent with no body and no type; Login; passes deleted, the phone ID kept; the 400 read as a validation error | Guide §3.5; data-flow Q4 |
| TC-STG-012 | A used refresh pass is refused | WORST | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real `401` for a refresh pass already used | A request expires | Login; passes deleted; the phone ID kept | Guide §3.4 |
| TC-STG-013 | A pass ended elsewhere | WORST | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real `401` after a logout | Open History | Login | Guide §3.3 |
| TC-STG-014 | Login, restart, logout and login again on a phone | E2E | P1 | DEVICE | ✋ | Staging build on the emulator or a phone; the test login; its inbox | Log in (code from the email); close and reopen the app; log out; log in again | In with the code; still in after the restart (the server's name and organisation shown); Login after logout; the next login needs no code | Guide §3 |
