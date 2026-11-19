# The Postman mock for the mock build

The mock build (`config/mock.json`) talks to a Postman mock server made from the backend's collection. The mock answers each request with its saved example (build guide §6). It has no emails, accepts every code, and gives every lookup a fixed answer.

The mock must be made from the **current** collection (`docs/protectb-api/ProtectB-mobile-app.postman_collection.json`, backend commit ebff1d9, 2026-11-17). A mock made from an older copy lacks:
- Request access (`roles/requestable`);
- Scanner mode and Sessions (`lookups/sessions`);
- Serial stacks (`lookups/serials`).

## Make the mock (about 5 minutes, in your Postman account)

1. **Import the collection.** In Postman, click **Import**, choose `docs/protectb-api/ProtectB-mobile-app.postman_collection.json`, and import it. It arrives as a new collection, "ProtectB mobile app API". If an older one has the same name, rename the new one "ProtectB mobile app API 2026-11-17".
2. **Import the environment.** **Import** again and choose `tool/postman/ziska-mock.postman_environment.json`. It holds the values the examples' addresses need:

   | Variable | Value |
   |---|---|
   | `mobileSlug` | `ziska` (the mock build's client) |
   | `mobileSessionId` | the session ID in the examples |
   | `mobileIncidentId` | `1042`, the report ID in "201 Filed" |

3. **Make the mock.** On the new collection, open **⋯ (More) ▸ Mock collection**, then:
   - Name: `ProtectB mobile mock 2026-11-17`.
   - Environment: **ziska mock**.
   - Leave **Make mock server private** unticked. The app cannot send a Postman key, and the examples hold only made-up data.
   - Click **Create Mock Server**.
4. **Copy the mock's address**, which looks like `https://<id>.mock.pstmn.io`, and send it to the app team. It goes into `API_BASE_URL` in `config/mock.json`; the mock build is then built again.
5. **Optional:** delete the old mock and the old collection.

**Postman limits:** Postman's plans allow a set number of mock calls a month. Scanner mode spends one call per scan.

## What the mock build adds (mock build only)

A fixed mock cannot tell some requests apart, and it scores a body unlike the saved one by how close it is to each example. The mock build's `PostmanMockRouting` (`lib/core/network/demo/postman_mock_routing.dart`, on through `POSTMAN_MOCK_ROUTING` in `config/mock.json`) tells it which example to answer. Staging and live builds refuse the flag.

| Case | What the mock answers |
|---|---|
| Check one item: the serial or QR value ends in 1 | Genuine |
| … ends in 2 | Genuine, needs attention |
| … ends in 3 | Not found |
| … ends in 4 | Not in a batch |
| … ends in anything else | Genuine |
| Scanner mode: a QR value ending in 3 | Not found |
| Scanner mode: any other QR | The "first scan" example (needs attention) |
| History, next page | "A later page" |
| A session (open one, end one) | The example session, shown under the app's own session ID |
| Log in | "New phone: a code was emailed"; any 6 digits log in |
| The code `111111` | A login that must set a new password (to try **Not now**) |
| A photo | Numbered 1, 2, 3 per report (the example always says 1) |
| A login's passes | The examples' passes are shortened with "…", which no HTTP header may carry (the app could not send anything after logging in, and said "No connection"); each is replaced by a stand-in such as `mock-access-1`, new on every renewal |
| Every other route | Its success example by name; the mock scores a body unlike the saved one closer to an error example |

The "Not now" demo (`DEMO_PASSWORD_LATER`) still plays `me/password/later`, which the collection does not have yet.

## Checking it

After the new address is in `config/mock.json`, each of these answers its example, not `mockRequestNotFoundError`:
- `GET formats`, `GET roles/requestable`, `GET lookups/sessions`;
- `POST lookups`, with and without `session_id`;
- `POST lookups/serials`;
- `GET checks`;
- `POST incidents`, `POST incidents/1042/photos`.
