# Backend fix list after the test-server integration (2026-11-22)

**From:** the mobile app team. **To:** the ProtectB backend team.
**Server:** `https://testapp.protecb.com`, client `ziska-test`. **Your docs checked:** `ProtectB-DOCS` at commit 5d96a91.

## What this is

We connected the Track & Trace app to your test server and checked every route the app uses, step by step. The details are in `docs/staging-integration-2026-11-22.md`.

Every problem on the app's side is fixed (see "Already settled" at the end). The items below are on your side:
- data the test server is missing;
- three small server changes and one feature;
- rules your guide does not state yet.

**Order:** please fix them in the order below. Each item says:
- what we saw;
- what your docs say;
- how we suggest fixing it in your system;
- what the app does;
- how we will check it.

**Replying:** reply by item number. When a fix is on the test server, tell us and we retest it the same day.

| # | Problem | Kind | Priority | Status |
|---|---|---|---|---|
| 1 | The test server is missing test data | Data, no code | **High** | Open |
| 2 | Letters are counted two different ways | Code, small | **High** | Open |
| 3 | "Not now" (postpone the forced password change) has no route | Code, feature | **High** | Open (confirmed by the client) |
| 4 | The app's date filter may use UTC days, not Bangladesh days | Code or decision | Medium | Open: please confirm |
| 5 | Rules the server follows but the app guide does not state | Docs | Medium | Open |
| 6 | A new password may equal the current one | Decision, docs | Low | Open: please confirm |
| 7 | A bodiless request sent as JSON with an empty body is refused | Code, small | Low | Open |

---

## 1. The test server is missing test data

**What we saw** (2026-11-22). Client `ziska-test` has:
- one test login;
- items for the results `valid`, `checked_before`, `unassigned` and `not_found` only;
- **no QR value** we can scan;
- **no product picture**;
- **no recalled, expired, damaged or switched-off item**;
- **no retail user**.

Because of this, these checks could not be run against the server:
- a found item in a scanner session;
- the product picture;
- the warning reasons;
- the retail-user picker;
- the forced password change and "Not now";
- the cases that need a second phone.

**What your docs say:**
- `mobileApp/app-build-guide.md:333-340` promises a test client with "ten test logins" and, "for every result … a serial and a QR value".
- `mobileApp/00-decisions.md` D36 and `phase-6-ready-for-client.md:171-173` call it "a test client with made-up data … once a test server exists". The test server exists now.

**Please add, on `ziska-test`, using your existing routes:**

| Needed | How, in your system |
|---|---|
| The QR value of about 10 items, as a list `serial → QR value` | The staff export: `POST /v1/exports`, then `POST /v1/exports/{export_id}/download`. Once the QR fill is done, its file has the third column `qr_link` (`frontend-guide/api-guide.md:943-978`) |
| Fresh `valid` items (never checked), about 5 | New codes in a batch (`POST /v1/runs`, then assign them to a batch) |
| A recalled item | A batch recalled: `POST /v1/tenants/{id}/batches/{bid}/recall` (`frontend-guide/api-guide.md:1007`) |
| A switched-off item | A batch switched off: `POST /v1/tenants/{id}/batches/{bid}/deactivate` (`:1010`) |
| A damaged item | `POST /v1/tenants/{id}/serials/mark-damaged` (`:1137`) |
| An expired item | The portal's `PATCH batches/{id}` with an `expiry_date` in the past (`:2192`; expired from the next Bangladesh day, `:2246`) |
| One product with a picture | `POST product-pictures`, then the product's `picture` (`:2119-2149`) |
| Retail users, at least 3, with different names | Approve the two pending sign-up requests: "Test Signup mobile app check" (Retail seller), and a second one sent from the app on 2026-11-22 from another address of our test inbox (we will tell you which). `GET mobile-app/requests`, then `POST mobile-app/requests/{id}/approve` (`:2586-2589`). Until a request is approved its address has no account, and login answers 401 ("Email or password is incorrect"), as guide §3.1 says. Add more with `POST mobile-app/officials` in a retail role (`:2393`, `:2400`) |
| Extra test logins: a second supervisor; an account with a first password (`must_change_password: true`); a blocked account; a role with `item:lookup` only | `POST mobile-app/officials` and `POST mobile-app/roles` (`:2393`, `:2400`) |
| A way for us to read the emailed codes of the extra logins | Send them to addresses of our test inbox; we will send you the addresses separately, never in a document. Or give us a mail page |

**What the app does:** nothing to change. The app already handles every result, reason and picture (tested offline).

**How we will check it:**
- **What we run:** our checker's `lookup`, `scan` and `report` steps, and the app on a phone.
- **What we look at:** a QR scan in Scanner mode, each warning reason on the result screen, the product picture, the retail-user picker, and the forced change with "Not now" (after item 3).
- **The case IDs:** TC-STG-025, -040 and -046, then TC-AUTH-055 to -063, -080 and -095.

**Status:** Open.

---

## 2. Letters are counted two different ways

**What we saw** (2026-11-22). An emoji counts as **two** letters in some fields and **one** in others:

| Field | Sent | Answer | Counted as |
|---|---|---|---|
| `GET retail-users?search=` (up to 100) | 98 letters and an emoji | 200 | UTF-16 units: the emoji counts 2 |
| | 99 letters and an emoji | **400** | |
| `POST auth/access`, `name` (1 to 100) | 99 letters and an emoji | **400** | UTF-16 units |
| `POST incidents`, `note` (1 to 1,000) | An emoji and 999 letters | 201 | Code points: the emoji counts 1 |
| Password (8 to 128) | 128 characters ending in an emoji | passed the rule | Code points |

**What your docs say:**
- The guide gives lengths "in characters" and says "Count characters, not bytes" (`mobileApp/app-api-guide.md:287`, §3.6).
- DEC-422 says "characters are counted, not bytes" (`implementation-plan/02-decision-log.md:426`).
- Your docs do not say how a character is counted. The mobile routes check their input in hand-written parsers (`apps/mobile-app-api/src/http/body.ts`, review R4, `implementation-plan/reviews/2026-11-18-mobile-and-monitoring.md:144`).
- *Our reading:* `value.length` in JavaScript counts UTF-16 units, and that matches what we saw.

**Please fix it like this:**
- **Count code points:** in the length check of the mobile routes, count `[...value].length` (code points) instead of `value.length`. At least `name` of `POST auth/access` and `search` of `GET retail-users` need it.
- **Look for other uses:** every other text limit in `mobile-app-api` that uses `.length` should change the same way.
- **The database:** PostgreSQL's `char_length` already counts code points.
- **The guide:** add one line to §1: "A character is a Unicode code point: an emoji counts as one."
- **A test:** 99 letters and an emoji are accepted; 100 letters and an emoji are refused.

**What the app does:** it keeps a name and a search within 100 UTF-16 units, which passes either way. After your fix we will relax it to code points.

**How we will check it:** our checker's `lengths` and `signup-probe` steps (no real sign-up is sent), and the cases TC-MIG-065 and TC-REP-063.

**Status:** Open.

---

## 3. "Not now": postponing the forced password change has no route

**What we saw** (2026-11-22):
- `POST me/password/later` answers **404 "Not found."**;
- the login, verify-phone and `GET me` answers have no `password_change_skippable` and no `password_change_pending`.

**What your docs say:**
- You agreed to build it on 2026-11-17 (our request, `docs/backend-requests/password-change-later.md`).
- **The client has confirmed it is part of the system** (2026-11-22).
- It is not in `ProtectB-DOCS` yet, and `mobileApp/phase-2-accounts-login.md:205` still says "A forced password change cannot be skipped". D59 (`00-decisions.md:143`) lets whoever makes the account choose whether the change is forced.

**Please build it as agreed** (`password-change-later.md`):
- **`POST me/password/later`:**
  - no body;
  - allowed with the restricted pass of a forced change;
  - **200** gives a new access pass with full access for the role: `{ access_token, access_expires_in: 900, must_change_password: false, password_change_pending: true }`; the refresh pass is kept;
  - **403 `forbidden`** when this account may not postpone.
- **`password_change_skippable: true`:** next to `must_change_password: true` in the login, verify-phone, refresh and `GET me` answers, when the account may postpone.
- **`password_change_pending: true` in `GET me`:** after "Not now", until the password is changed (`POST me/password` or a reset clears it).
- **Later logins:** `auth/refresh` in the same login answers `must_change_password: false`. The next `auth/login` or verify-phone answers `true` again, until the password is changed.
- **Documentation:** update phase 2 ("cannot be skipped") and D59, the guide (§3.2, §3.6), the Postman collection and the test server.

**What the app does:** "Not now" and the Profile reminder are built.
- **The mock build** plays the route itself.
- **The staging and live builds** keep the change required, and hide "Not now", until the server sends `password_change_skippable`. No app update is needed when you ship it.

**How we will check it:** a first-password login on the test server (from item 1), "Not now", check an item, log out, log in again, then change the password. The case is TC-AUTH-095.

**Status:** Open.

---

## 4. The date filter may use UTC days instead of Bangladesh days

**What we saw:** the app sends `from` and `to` of `GET checks` and `GET lookups/sessions` as the **Bangladesh** date the official picked.
- In daytime both days are the same, so our tests could not tell them apart.
- Your other lists use whole **UTC** days, so these two routes may too.

**What your docs say:**
- The app guide says only "dates (`YYYY-MM-DD`)" (`mobileApp/app-api-guide.md:609`, `:709`).
- The portal's lists say "a whole UTC day" (`frontend-guide/api-guide.md:2303`).
- DEC-205: people see Bangladesh time (`implementation-plan/02-decision-log.md:265`). Reports already use Bangladesh days (`frontend-guide/api-guide.md:2081`).

**Why it matters:** an official checks an item at 01:00 Dhaka on 23 Nov, which is 22 Nov 19:00 UTC, then filters History by "today" (23 Nov). With UTC days the check is missing from "today" and appears under 22 Nov.

**Please tell us which it is, then:**
- **Recommended:** read the app's `from`/`to` as **Asia/Dhaka** days. That is, `at >= from 00:00 Asia/Dhaka` and `at < (to + 1 day) 00:00 Asia/Dhaka`. Write it in §4.5 and §5.
- **Or:** confirm UTC days in the guide. The app will then send UTC dates instead.

**How we will check it:** one check after 00:00 Dhaka, then History filtered by that day.

**Status:** Open: please confirm.

---

## 5. Rules the server follows but the app guide does not state

Each of these was seen on the test server or is in your other docs. Please copy them into `mobileApp/app-api-guide.md`, so app developers do not have to find them:

| Rule | Seen or written where | Where in the app guide |
|---|---|---|
| A serial is read without its leading zeros, at most 40 characters; `serial.max_digits` counts the serial's own digits | DEC-371 (`02-decision-log.md:375`). On the server, serial `1` padded to 20 and to 40 characters found item 1, and to 41 was not found | §4.1, §4.2, §4.7 |
| `0` is looked up like any serial (`not_found`), not refused | On the server: `0` and `000` gave `not_found` | §4.2 |
| Only ASCII digits `0`–`9` count; Bangla digits are not converted | `contracts/06-format-and-rules.md:78-80`. On the server, `১` (Bangla one) gave `not_found` | §4.2 |
| A QR value is read in capitals | `phase-4-lookups.md:59`; `phase-3-qr-values.md:66` | §4 |
| The email at login is matched regardless of case | `phase-2-accounts-login.md:66`. On the server, the email in capitals logged in | §3.1 |
| During a forced change, `auth/refresh` answers 200 with `must_change_password: true` | Inferred from §3.4 (refresh needs no access pass). **Please confirm** | §3.4 |

**What the app does:** it already follows each rule. It reads leading zeros away, turns Bangla digits into 0–9 before sending, sends QR values as read, and handles both refresh answers.

**Status:** Open.

---

## 6. A new password may equal the current one

**What we saw** (2026-11-22): a reset and a change to the **current** password both answered **200**.

**What your docs say:** this was planned and then skipped: "F7 (a new password may equal the current one) … accepted for now" (`implementation-plan/handoff.md:4943`, `:4954-4956`). The guide says "Nothing is required beyond the three rules" (`app-api-guide.md:272`).

**Please:**
- confirm it in §3.6 and §3.7: "a new password may equal the current one";
- if you later refuse it, answer **403 `policy_denied`**, as for the other rules.

**What the app does:** it sends the password and shows the server's answer, so it works either way.

**Status:** Open: please confirm.

---

## 7. A bodiless request sent as JSON with an empty body is refused

**What we saw** (2026-11-22):

| Request | Answer |
|---|---|
| `POST auth/logout` with `Content-Type: application/json` and an empty body | **400 `validation_failed`** |
| `POST lookups/sessions/{id}/end`, the same | **400 `validation_failed`** |
| The same two, with no body and no `Content-Type` | 200 |

**What your docs say:**
- The app guide says bodies are JSON (`app-api-guide.md:47-51`), and logout has "No body" (`:243`).
- Your staff guide says it for its own bodiless routes, activate and deactivate: "Send no body (and then no `Content-Type: application/json` header)" (`frontend-guide/api-guide.md:1107-1108`).
- The app guide says nothing like it.
- `mobile-app-api` runs on NestJS with Fastify (`phase-1-foundation.md:101`). *Our reading:* Fastify's default JSON parser refuses an empty body sent as `application/json`.

**Please, either:**
- **(a, preferred):** let the JSON parser read an empty body as "no body" for the bodiless routes (`auth/logout`, `lookups/sessions/{id}/end`, and `me/password/later` when it ships). For example, a JSON content-type parser that returns `undefined` for an empty string. Many HTTP clients send the JSON type by default.
- **(b):** add the staff guide's sentence to the app guide (§1).

**What the app does:** it sends these requests bare, so it is not affected.

**Status:** Open.

---

## Already settled (no action needed)

| Point | Settled by |
|---|---|
| `001` and `1` are one serial | DEC-371; the app now does the same |
| A serial with letters answers `not_found` | Guide §4.2 ("a value … that matches no format … answers `not_found`"); your phase 9 test |
| Logout with no body | 200, as the app sends it |
| The app's own problems found on the server | Fixed in the app: the address setting (f29ec20); empty text from the server (1e88cdb); leading zeros in a stack (5aacf99); the note and the search (8915a54); the sign-up name (aaade9d); a padded serial (93e2f12) |

**Left on the test server by our checks:**
- checks MA-2026-000001 … -000043, with their sessions and stacks;
- reports #1 to #4, and #5 (2026-11-23, a length check filed by mistake: an emoji and 999 "n"; please delete it if you like);
- two sign-up requests, pending (see item 1).

The test login's password is unchanged.
