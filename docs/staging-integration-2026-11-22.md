# The app against the backend's test server

**Server:** `https://testapp.protecb.com/v1/clients/ziska-test` (base `https://testapp.protecb.com`, client `ziska-test`), ready 2026-11-22 (backend request B1). **Build:** the staging flavour (`config/staging.json`, app "Track & Trace Staging"). **Test login:** given by the project owner; never written in the repo.

**How each step runs:**
1. Write the cases first: normal, edge and worst. Run them offline.
2. Run the checker against the server (`dart run tool/staging_check/staging_check.dart <step> --out <dir>`). It uses the app's own API services and parsers.
3. Keep the server's real answers as fixtures (`test/fixtures/staging/`, with passes, emails and references removed) and replay them in tests (`test/staging/`).
4. Check the screens on the emulator.
5. Commit, then wait for the go-ahead before the next step.

Cases: [17-test-server.md](test-cases/17-test-server.md).

| Step | Area | State |
|---|---|---|
| 1 | Connection and errors | **Done** 2026-11-22 |
| 2 | Login and staying logged in | Next |
| 3 | Profile and permissions | |
| 4 | One check | |
| 5 | History and the sessions list | |
| 6 | Serial stacks | |
| 7 | Scanner sessions | |
| 8 | Reports, photos, retail users | |
| 9 | Sign up | |
| 10 | Password reset and change | |
| 11 | Records | |

## Step 1. Connection and errors (2026-11-22)

**Cases first:**
- The error answers were already well covered: every `error.code`, `Retry-After` as seconds or a date, HTML pages without the envelope, timeouts and a refused certificate (`error_mapper_test`, `errors_edge_flow_test`).
- **Gap found and closed:** the address rules. The server's address is given as the whole API root (`…/v1/clients/ziska-test`). Put in `API_BASE_URL` as it is, every request would have gone to `…/ziska-test/v1/clients/ziska-test/…` and failed.
  - `AppConfig.validateBaseUrl` now takes the host alone (spaces, extra slashes and capitals tidied, a port kept). It refuses a path, a query, a fragment, a login or a placeholder, and names the host to use (TC-STG-005).
  - `AppConfig.validateClientSlug` accepts lower-case letters, digits and `-`, and refuses anything else at start, since the server answers 404 for it (TC-STG-006).

**Against the server** (the checker's `connect` step):

| Route | Answer | Read by the app as |
|---|---|---|
| `GET roles/requestable` (no login) | 200: Distributor (2), Retail seller (1) | The two roles, in that order |
| `GET formats` without a login | 401 `unauthenticated`, with a `request_id` | "Not logged in", with the reference |
| `GET no-such-route` | 404 `not_found`, with a `request_id` | "Not available", with the reference |

All three follow the guide's envelope, over HTTPS, with the security headers (`nosniff`, `DENY`). **No difference from the contract.**

**Real-answer tests** (`test/staging/step1_connection_test.dart`, TC-STG-001 … -004): the three answers replayed through the app's client and parsers, and the roles through the whole app (Login → Sign up → the role list).

**On the emulator** (staging release build, Pixel 7, 2026-11-22): **TC-STG-007 passed.** Login shows, and Sign up's role list shows Distributor and Retail seller, loaded from the server.

**Note:** the emulator window now crashes at start on this PC (its software OpenGL library fails to load), so it runs without a window (`-no-window`); screenshots come through `adb`.
