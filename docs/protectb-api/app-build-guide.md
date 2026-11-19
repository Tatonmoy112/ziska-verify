# Building the ProtectB mobile app: a guide for the app's developers

_For the developers of the client's mobile app, and for the AI coding agent they
build it with. Read it once whole; then work through §5 in order._

This guide says **how to build** the app's side of the API. **What** each route
takes and answers is in two files beside this one, and they are the reference:

| File | What it is | Use it for |
|---|---|---|
| `app-api-guide.md` | The API guide: every route, field, answer, error and limit, with the reasons | The rules. When this guide and that one seem to differ, that one wins. |
| `ProtectB-mobile-app.postman_collection.json` | Every route, grouped by screen, with **example answers** (successes and errors) | The exact shape of every request and answer; trying the API by hand |
| `ProtectB-mobile-app.postman_environment.json` | The values to fill in: address, client, test login | Pointing Postman at a server |

Copy all four files into your app repository, for example into `docs/protectb-api/`,
so your agent can read them.

---

## 1. For the AI agent: how to work

Give your agent this section as its standing instructions.

1. **Read before writing.** Before building any screen, read the routes it uses in
   `app-api-guide.md` and their requests and example answers in the Postman
   collection. Never guess a field name, a status code or an error code.
2. **The examples are the contract.** Every answer the app parses has an example in
   the collection (open the request, then its saved responses). Build the app's
   types from them, field by field, including the fields that can be `null`.
3. **Decide by codes, never by messages.** Branch on the HTTP status and
   `error.code` (and `data.status`, `data.result`, `data.reasons`). Messages are for
   showing; they can change.
4. **Follow the rules in §4 exactly.** They are where a wrong guess locks an
   official out, logs them out, or makes a duplicate record.
5. **Ignore fields you do not know.** The API only grows: new fields can appear in
   any answer. Parsing must not fail on them.
6. **Work in the order of §5**, and finish each step's checklist before the next.
7. **When something is unclear, ask the people, not the code.** Write the question
   down with the route and the `request_id` of the answer; do not invent behaviour.

---

## 2. What the app does

Field officials of one client (a manufacturer) check whether items are genuine:
they scan a QR code or type a serial (one, or a stack of up to 50), and the app
shows whether the item is genuine and whether anything is wrong with it. Some
officials also file reports with photos and look back at their own past checks. A
person without an account asks for one from the app; the client's office approves it.

**One app, one client.** The app is built for one client: its API address and the
client's short name (the "slug") are fixed in the app's configuration. Every route
is `{base}/v1/clients/{slug}/…`.

**What an official may do depends on their role.** The client's office sets each
role's permissions; the app shows only what the role allows (§4.5).

---

## 3. The app's structure

These are the parts to build. Names are suggestions; keep the responsibilities.

| Part | Responsibility |
|---|---|
| **Config** | The base address and the slug, per build (test, live). Nothing else is hard-coded: formats and limits come from the API. |
| **Secure store** | The phone ID, the access pass and the refresh pass, in the phone's secure storage (Keychain on iOS, Keystore / EncryptedSharedPreferences on Android). Never plain storage, never logs. |
| **API client** | Every HTTP call goes through it. Adds `Authorization: Bearer`, sends JSON, parses the answer shape, turns errors into typed errors by `error.code`, renews the pass once on `token_expired` (§4.2), honours `Retry-After`. No cookies. |
| **Session** | Logged out, waiting for a code, must change password, logged in. Drives which screen shows. |
| **Profile** | `GET me`: name, role, **permissions**, the client's name, support contact. Loaded at start and after login; the permissions decide the menus. |
| **Screens** | Login, code, change password, forgotten password, request access, home, single lookup (scanner and typing), scanner mode (sessions), stack of serials, result, history, report, photo upload, retail user picker, profile, error. |

**The answer shape** is always the same (collection overview ▸ *The answer*):

```json
{ "success": true, "message": "…", "data": { … } }
{ "success": false, "message": "…", "error": { "code": "…", "message": "…", "request_id": "…" } }
```

The API client returns `data` on success and throws one typed error on failure,
carrying `status`, `code`, `message`, `request_id` and, for 429, the `Retry-After`
seconds. Every error screen shows "Reference: {request_id}".

---

## 4. The rules that must never be broken

### 4.1 The phone ID

- Make it **once**, on the first run: 32 random bytes from a secure random source,
  base64url (letters, digits, `_`, `-`; 43 characters). Store it in secure storage.
- Send the **same** one with every login and code. Never make a new one on logout,
  on an app update or on an error: a new phone ID is a new phone, and the official
  must get an emailed code again.

### 4.2 The passes and renewing them

- `access_token` lives 15 minutes and goes in `Authorization: Bearer …` on every
  request after login. `refresh_token` lives 30 days unused and goes **only** in the
  body of `auth/refresh`.
- On **401 `token_expired`**: renew, store **both** new passes, then send the failed
  request again, **once**.
- **Renew once at a time, app-wide.** A refresh pass works exactly once; sending a
  used one again **ends the login**. When several requests fail together, they all
  wait for the same single renewal (the code sample in the collection's *Session ▸
  Renew the passes*). This is the most common way to log users out by mistake.
- On **401 `unauthenticated`** (any route, including the renewal): clear both
  passes and show the login screen. Keep the phone ID.

### 4.3 Logging in

- `auth/login` answers 200 in two ways: decide by `data.status`:
  `logged_in` (store the passes) or `code_sent` (keep `challenge_id`, show the code
  screen). The message is the same for both.
- One message for every failed login: "Email or password is incorrect." The API
  answers the same 401 for a wrong email, a wrong password, a blocked official and a
  locked account, on purpose. Never try to tell them apart.
- After `verify-phone` (or any login), when `must_change_password` is **true**, show
  only the change-password screen. Every other route answers 403
  `password_change_required` until it is done.

### 4.4 Errors and limits

| Answer | The app |
|---|---|
| 400 / 413 / 415 `validation_failed` | A bug in the app: log it with the `request_id`; show a general error |
| 401 `token_expired` | Renew once, retry once (§4.2) |
| 401 `unauthenticated` | Login screen |
| 403 `password_change_required` | Change-password screen |
| 403 `forbidden` | Hide what the role cannot do; refresh the profile |
| 403 `policy_denied` | Show the password rule (§4.9): 8 or more characters, a letter, a number |
| 404 `not_found` | "Not available", or the route's own message (e.g. "Check not found.") |
| 409 `conflict` | Show the message |
| 429 `rate_limited` | Wait the seconds in `Retry-After`, then allow a retry. Never a fixed number in the app |
| 503 `app_preparing` | "The app is being prepared. Try again later." |
| 503 `service_unavailable` | "Try again shortly"; where the route says so, send the same request again |
| anything else | A general error with the reference |

### 4.5 Permissions

Show a feature only when `GET me` lists its permission. Load the profile at start,
after login, and after any 403 `forbidden`.

| Permission | Feature |
|---|---|
| `item:lookup` | Single lookup (scan or serial) |
| `item:bulk_lookup` | Checking many items: scanner mode (scanner sessions) and the stack of serials |
| `history:own` | History of one's own checks and sessions |
| `incident:report` | Reports, photos, my reports, picking a retail user |

No permission shows other officials' checks: the app never sees them.

### 4.6 Looking items up

- **Reading a QR:** the QR holds a link such as `https://…/q/Q8F2KD91XA7M`. Send only
  the part after the last `/q/` with `way: "qr"`. **Never open the link.**
- Check what is typed against `GET formats` before sending; never hard-code lengths
  or characters (they differ between clients).
- Show `data.result` and every `data.reasons` entry (*Looking items up ▸ Look up one
  item* lists them). `not_found` and `unassigned` carry only `ref`. There is no
  "invalid" result.
- Show `ref` on the result: it is the check's reference number, which finds the
  check fast in the history and in the client's portal.
- `item.code` is already masked (`*****7K2`). The app never asks for the hidden
  code: it is the consumer's.
- **Scanner mode:** each QR is sent on its own as soon as the camera reads it, with
  the session's `session_id` (API guide §4.3). Show each result on the scanner screen
  and add it to the list; `repeat: true` shows "already scanned". Keep only the
  session ID on the phone.
- **A stack of serials:** up to 50 typed or pasted serials in one
  `POST lookups/serials` (API guide §4.7); show each entry's result in the order
  sent. A failed stack recorded nothing: send it again whole (a 503 now and then
  under load is expected: send it again after a second).

### 4.7 Reports and photos

- File the report first, keep its `id`, then send each photo, one at a time.
- **A photo's body is the file itself**, not JSON and not a form:
  `Content-Type: image/jpeg` and `Content-Length`. Shrink to 2048 px on the longer
  side, JPEG quality 85, before sending; at most 1 MB.
- If a photo fails (503 or the network), keep it and send it again: the same file is
  never counted twice. **Never file the report again**: that makes a second report.
- Photos can be added only by the report's author, within an hour, at most 3.

### 4.8 What never goes into logs or analytics

Passes, passwords, emailed codes, the phone ID. Log `request_id`,
the route and the status instead.

### 4.9 The password rule and its hints

Every password an official chooses (the change after the first login, any later
change, the forgotten-password reset, the password of an access request) must have:

- at least **8** characters (at most 128);
- at least one **letter** (of any alphabet: English, Bangla, …);
- at least one **number**.

Anything else is allowed (spaces, symbols, capitals or not); nothing else is
required. Line breaks and tabs are refused.

On every screen where a new password is typed:

- **Show the three rules under the field before typing starts**, each with a mark
  that turns to ✓ as it is met: "8 characters or more", "a letter", "a number".
- Keep the button disabled until all three are met. Count characters, not bytes.
- A **403 `policy_denied`** then means the app's check and ours differ: show the
  three rules again and log the `request_id`.
- Offer "show password" (an eye icon). If the design has a "repeat password"
  field, check in the app that both match; the API takes the password once.
- The **first password** the client's office types when making an account has no
  rule but 1 to 128 characters: it works once and, unless the office said
  otherwise, must be changed under the rule above at the first login.

---

## 5. The order to build in

Each step lists its routes (folders of the Postman collection) and what must work.
Finish a step's checklist before starting the next.

### Step 1: the API client and the secure store

Routes: none yet. Build the config, the secure store (§4.1), the API client with
its typed errors (§3, §4.4) and the single renewal (§4.2), and the error screen.

- [ ] The phone ID is made once and survives app restarts and logouts.
- [ ] Every error becomes one typed error carrying `code` and `request_id`.
- [ ] Two requests failing with `token_expired` at the same moment cause **one**
      renewal, and both are retried once.
- [ ] A 429 exposes `Retry-After`.

### Step 2: logging in

Routes: *Logging in* (all three), *Session ▸ Profile*, *Session ▸ Change the
password*, *Forgotten password* (both).

- [ ] Login on a new phone → code screen → logged in; the next login on the same
      phone needs no code.
- [ ] The code screen's "send again" respects one a minute (show the countdown).
- [ ] `must_change_password: true` shows only the change-password screen, and
      after the change the app continues to home.
- [ ] A wrong password and an unknown email show the same message.
- [ ] The forgotten-password screens always show the same "If the address has an
      account, a code was sent." and then accept the code and a new password; the
      app then goes to the login screen.
- [ ] Every new-password screen shows the three rules (8 characters, a letter, a
      number) with live ticks, and keeps the button disabled until all are met (§4.9).
- [ ] `abcd1234` is accepted; `12345678`, `password` and `abc123` are stopped by the
      app before sending.
- [ ] Request access (API guide §3.9): the roles come from `roles/requestable` (an
      empty list shows "Ask the office for an account"); the form takes the name,
      role, password and email, then sends the code, then the code and the request;
      every address shows "A code was sent to the address."; a 401 is "The code is
      wrong or expired"; a 403 or 404 keeps the form and the code for another try;
      a 409 shows "Try again later" and goes back to sending a code; the end screen
      says an email will follow.
- [ ] The first login after an approval follows `must_change_password`: home when
      it is `false` (the person's own password), the change-password screen when it
      is `true` (the office gave a new password or ticked "must change"). Test both.

### Step 3: staying logged in

Routes: *Session ▸ Renew the passes*, *Session ▸ Log out*, *Session ▸ Profile*.

- [ ] Leave the app 20 minutes, come back: the first request renews silently.
- [ ] Logout deletes both passes, keeps the phone ID, and the next login needs no code.
- [ ] Any 401 `unauthenticated` lands on the login screen.
- [ ] The home screen shows only what the profile's permissions allow.

### Step 4: single lookup

Routes: *Looking items up ▸ Input formats*, *Look up one item*.

- [ ] Scanning a QR sends only the part after `/q/`.
- [ ] Typing a serial is checked against `formats` first.
- [ ] Every `result` and every `reason` has its own clear display; `ref` is shown.
- [ ] `app_preparing` shows its message; a role without `item:lookup` never sees
      the screen.

### Step 5: scanner mode (scanner sessions)

Routes: *Scanner sessions* (a scan, end a session, the sessions, one session) and
*History ▸ History of checks* with `session_id`. API guide §4.3–4.6.

- [ ] Entering scanner mode makes a new UUID; every scan sends it with `way: "qr"`.
- [ ] Each result shows on the scanner screen at once and joins the list; the
      counter comes from `session` (scanned, valid, warning, not found, left).
- [ ] The same QR held in front of the camera is sent once; `repeat: true` shows
      "already scanned".
- [ ] `session_full` and `session_ended` start a new session and send the scan
      again in it; a 503 or no connection shows "scan again"; a 429 waits
      `Retry-After`.
- [ ] The app's and the phone's back button send `…/sessions/{id}/end` without
      waiting, clear the list and forget the ID.
- [ ] After a crash, the same session reopens from its ID: counter from
      `GET lookups/sessions/{id}`, list from `GET checks?session_id=…`.
- [ ] Past sessions: the sessions list, then one session's checks.
- [ ] Hidden without `item:bulk_lookup`.
- [ ] A stack of serials: up to 50 per request (more are split by the app or
      refused before sending); repeats show once; each entry shows its result;
      the stack appears in the sessions list with `kind: "serial"`; a 429 (more than
      500 serials a minute) waits `Retry-After` and sends the same stack again.

### Step 6: history

Routes: *History ▸ History of checks*.

- [ ] Filters (result, way, dates, search), paging with `next_cursor` until it is
      `null`, `totals` from the first page.
- [ ] Never sends `scope` (it is 400): the history is the official's own.

### Step 7: reports and photos

Routes: *Reports and photos* (all three), *Retail users ▸ Pick a retail user*.

- [ ] A report from a lookup's result carries its `ref` as `check_ref`.
- [ ] Photos are shrunk, sent as the raw file, retried after a failure, never
      duplicated; the report is never filed twice.
- [ ] "My reports" lists the official's own reports with their photo counts.

### Step 8: retail users

Routes: *Retail users ▸ Pick a retail user*.

- [ ] Picking a retail user for a report (search, masked emails); hidden without
      `incident:report`. Retail users are not added in the app.

---

## 6. The test server

You build against **our test server**, with a made-up client, `demo-pharma`, filled
for you. With it we give you:

- **the app API's address** (`mobileBase`);
- **the test sheet**: ten test logins (inspectors, supervisors, a trainee with no
  rights, retail users, one who must change the first password, one blocked), and
  for every result the app can show (`valid`, each `warning` reason, `unassigned`,
  `not_found`) a serial and a QR value;
- **the mail page**, where every emailed code arrives (a new phone, a forgotten
  password, an access request). Nothing is sent to a real mailbox.

**In Postman:** import `ProtectB-mobile-app.test-server.postman_environment.json`
(the client and a login are filled in), put the address into `mobileBase` and the
password from the sheet into `mobilePassword`, pick the environment, and run the
collection from *Logging in ▸ 1. Log in* down. The first login on a phone answers
`code_sent`: read the code on the mail page, put it into `mobileCode`, run *2. Verify
the phone*. The passes and ids are then saved from one request to the next.

**What is already there:** 400 past checks over the last 60 days and 12 reports with
photos, so History and My reports have pages to show. A "valid" item is valid only on
its first check by anyone; the sheet lists several: take the next one each time.
Ask us for a new sheet when they run out.

**Working offline: a mock server.** Postman can serve the collection's example
answers as a fake API: open the collection ▸ *More (…)* ▸ *Mock collection*, and put
the mock's address into `mobileBase`. Every request then answers its saved example. To
see an error answer, add the header `x-mock-response-name` with the example's name
(for example `401 Email or password is incorrect`). The mock is fixed: a lookup always
answers the same example, and no codes are emailed.

**Never test on a live client**: every check is kept for good.

**Asking us.** Send the route, what you sent (without passwords or passes) and the
`request_id` of the answer.

---

## 7. Known differences being fixed

Where the API today does not yet do exactly what `app-api-guide.md` says. Build to
the guide; these do not change what the app must do.

- **A fourth phone.** The guide says a fourth trusted phone replaces the one *used*
  longest ago; today it replaces the one *confirmed with a code* longest ago.
- **Unknown query parameters.** The guide says any query parameter a route does not
  list is 400; today some routes without query parameters ignore them. Send none
  that a route does not list.
