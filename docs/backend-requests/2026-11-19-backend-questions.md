# Backend Questions and Requests (2026-11-19)

> **Status 2026-11-19: ready to send.** Each item says what the app does now; an answer changes only that item.

**From:** the mobile app team. **To:** the ProtectB backend team. **Contract checked:** `docs/protectb-api/` (app API guide, build guide, Postman collection of 2026-11-17).

The app is built against the contract and runs against the Postman mock. These points need the backend team before the app can be tested against a real server and released.

## B1. A test server

> **Answered 2026-11-22:** `https://testapp.protecb.com`, client `ziska-test`, with a test login. The app is being checked against it step by step (`docs/staging-integration-2026-11-22.md`). Still wanted: items for every result, **the QR values of some test items** (none is known, so a scanner session on the server has only seen `not_found`, 2026-11-22), at least one retail user (the server has none, 2026-11-22; a sign-up request as a Retail seller, "Test Signup mobile app check", waits for the office: approving it gives one), and the mail page or office access.

**Request:** a test server for the mobile app, separate from any live client:

- its HTTPS address and the client slug (the app calls `<address>/v1/clients/<slug>/`);
- test logins, one for each case the app handles: an inspector, a supervisor (all features), a trainee (few features), a retail user, one with a forced password change, one locked;
- for every result and reason, a serial, a QR value and a hidden code: genuine, checked before, recalled, expired, damaged, switched off, not found, not in a batch;
- a way to read the emailed codes (a mail page or a shared inbox);
- office-portal access to set a new password and to approve a sign-up.

**What the app does now:** the `staging` build is ready for it; it needs only the address and the slug in `config/staging.json`. 35 manual cases wait for it ("Session C" in `docs/manual-test-checklist.md`).

## B2. Change the first password later

**Request:** already sent on 2026-11-16 (`password-change-later.md`): the route `POST me/password/later` and the fields `password_change_skippable` and `password_change_pending`, in the guide, the Postman collection and the test server.

**What the app does now:** **Not now** and the Profile reminder are built. The mock build plays the route itself (`DEMO_PASSWORD_LATER`); staging and live builds refuse that switch. One case (TC-AUTH-095) waits for the route on the test server.

## B3. Five open contract points

Four were sent on 2026-11-17 (`data-flow-questions.md`); none is answered yet:

1. Are `from` and `to` of `GET checks` and `GET lookups/sessions` UTC days or Bangladesh days? The app sends the Bangladesh date the official picked.
2. Is a QR value matched without regard to case? The app sends it as read and refuses one outside the `characters` of `GET formats`.
3. During a forced change, does `auth/refresh` answer 200 with `must_change_password: true`, or `403 password_change_required`? The app handles both.
4. Is an empty logout body fine? The app sends no body and no `Content-Type`. **Answered by the test server, 2026-11-22:** a bare request is accepted (200); an empty body sent as `application/json` is refused (`400 validation_failed`). The app's way is right.

One more:

5. **May a new password be the same as the current one?** `POST me/password` and `auth/password/reset` do not say. The app sends it and shows the server's refusal if there is one; it does not refuse it itself.

Also still open (decision sheet, Part 1): are emails matched without regard to case at login (Q4B), and does the server accept only the digits 0–9 in a serial or hidden code (Q19B)? The app sends emails as typed, and turns Bangla digits (০–৯) typed by an official into 0–9 before sending.

## B5. Rules seen on the test server (2026-11-22)

1. **Leading zeros.** A lookup of the serial `0000000000000000001` found item `1`, and the answer's `item.serial` is `"1"`. A stack of `001` and `1` was answered with **one** row (`001`, `scanned: 1`): the server takes them for one serial, a repeat. Are serials compared as numbers, so that leading zeros never count? The app now does the same (since 2026-11-22): it sends the first typed of such serials once, and the row matches. If the rule ever changes to comparing text, the app must change back. The guide (§4.7) should say which.
2. **Letters in a serial.** A lookup with `way: "serial"` and `value: "12AB"` answered **200 `not_found` and was recorded** (a check with a reference). The guide says a serial is "digits only". Should it answer 400? The app never sends letters (it checks against `GET formats` first), so this only affects other clients.

3. **How characters are counted.** `GET retail-users?search=` and an access request's `name` (§3.9) count their 100 characters in **UTF-16 units**: 98 letters and an emoji (100 units) are taken, 99 letters and an emoji (100 code points, 101 units) answer 400. The same for a name: 99 letters and an emoji answer 400. A report's `note` counts **code points**: an emoji and 999 letters (1,001 units) were filed. So does a password: 128 code points that are 129 units pass the rule. Which is meant? The guide says "Count characters, not bytes" (§3.6). The app counts a note and a password in code points, and keeps a search and a name within 100 units so they pass either way.

**Also wanted for the tests:** one item with a `picture_url`. The test items have none, so the product picture has not been seen from the real server.

## B4. The passes in the Postman examples

**Problem:** the examples' `access_token` and `refresh_token` are shortened with "…" (for example `eyJhbGciOi…`). An HTTP header cannot carry "…", so an app that uses an example's pass, as it would a real one, cannot send any request after logging in. Against the mock it said "No connection" until we worked around it.

**Request:** use plain ASCII placeholders in the examples, for example `example-access-token-1`.

**What the app does now:** the mock build alone replaces such a pass with a stand-in (`mock-access-1`; `docs/postman-mock-setup.md`). Real servers are not affected.
