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
