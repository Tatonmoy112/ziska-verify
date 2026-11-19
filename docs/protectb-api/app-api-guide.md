# ProtectB mobile app API — guide for the app's developers

_For the developers who build the client's mobile app. It lists every route
the app can call, with an example of each. A Postman collection with every route
comes with it: `ProtectB-mobile-app.postman_collection.json`; how to build the app
on it, step by step, is `app-build-guide.md`._

> **What is ready (2026-11-16).** Everything in this guide is built and tested on
> our side, the stack of serials (§4.7) included: after its load test a stack
> holds up to 50 serials, 500 a minute per official. There is no test server yet
> (§8); until there is, build against this guide and the Postman collection.
>
> **Changed 2026-11-15, before any client's app is live:** people can ask for an
> account from the app (§3.9). Items are looked up by **serial or QR only**:
> `way: "hidden_code"` answers 400 and `GET formats` has no `hidden_code`. A
> stack of up to 50 typed serials goes in one request (§4.7). The app sees only
> the official's own checks: `history:all`, `scope=all` (now 400) and `count.by`
> are gone. Adding retail users in the app is gone (`GET retail-roles`,
> `POST retail-users`, `POST retail-users/{id}/password` answer 404); picking one
> for a report stays (§7). Certificates are not part of the design; every check
> keeps its reference number.
>
> **Changed 2026-11-11:** the bulk lookup `POST lookups/bulk` is gone (it
> answers 404); **scanner sessions** replace it (§4.3–4.6): each QR is sent on
> its own with a `session_id`. The limit per network address is 3,000 a
> minute, and the limit of 3,000 items a minute is gone. Build the bulk screen
> as scanner mode.

## 1. The basics

**Address.** Every route is under

```
https://<app API host>/v1/clients/<client>/…
```

- `<app API host>` is the address we give you for each server (test and
  live).
- `<client>` is the client's short name (its "slug"), for example `ziska`.
  We give it to you with the host. An app built for one client always uses
  the same one.
- A client whose app is switched off, and a client name that does not
  exist, both answer **404 `not_found`** on every route. A client switched on
  a moment ago can too, for up to about 30 seconds.

**Requests.**
- Bodies are JSON (`Content-Type: application/json`), at most 64 KB. The
  one exception is a report's photo (§6.2): the file itself, up to 1 MB.
- A field the route does not know, a missing field or a field of the wrong
  type is **400 `validation_failed`**, and so is a query parameter the route
  does not list. A body over its size is **413**, with the same `code`.
- After logging in, every request carries the pass in a header:
  `Authorization: Bearer <access_token>`. Nothing is ever sent in a cookie;
  the API sets none and reads none.
- Only versioned paths (`/v1/`). A change that would break your app comes as
  `/v2/`, and `/v1/` keeps working for a period we agree with you.

**Times** are ISO 8601 with their offset, in UTC, such as
`2026-10-28T10:04:37.512+00:00` or `2026-10-28T10:04:37Z`. Read them with a date
library; the number of digits after the seconds varies. Dates such as a batch's
expiry are `YYYY-MM-DD`.

**Answers.** Every success has the same shape; what each route returns is
in `data`:

```json
{ "success": true, "message": "Logged in successfully.", "data": { … } }
```

Every error has this shape:

```json
{ "success": false, "message": "Authentication required.",
  "error": { "code": "unauthenticated", "message": "Authentication required.", "request_id": "6f1c…" } }
```

Decide what the app does from `error.code`, never from the message. Show
`request_id` on an error screen ("Reference: 6f1c…"): with it we can find the
request in our logs.

| HTTP | `code` | Meaning | What the app does |
|---|---|---|---|
| 400, 413, 415 | `validation_failed` | The request is malformed, or too large, or of the wrong type | A bug in the app: log it |
| 401 | `token_expired` | The pass ran out (it lives 15 minutes) | Renew it (§3.4) and retry once |
| 401 | `unauthenticated` | Wrong login details, or the login ended | The login screen |
| 403 | `password_change_required` | The official must set a new password first (§3.2) | The change-password screen |
| 403 | `policy_denied` | The new password breaks a rule (§3.6) | Show the password rules |
| 403 | `forbidden` | The official's role lacks the permission (§4) | Hide what the role cannot do |
| 404 | `not_found` | Unknown route, unknown client, or the app is switched off for this client | "Not available" |
| 409 | `conflict` | The request conflicts with the current state (§3.9, §6.2) | Show the message |
| 409 | `session_full`, `session_ended`, `session_not_yours` | A scan cannot join this scanner session (§4.3) | Start a new session |
| 429 | `rate_limited` | Too many requests | Wait the seconds in the `Retry-After` header |
| 503 | `app_preparing` | The client's app was just switched on and is being prepared (§4) | "The app is being prepared. Try again later." |
| 503 | `service_unavailable` | A part of our service is down | "Try again shortly" |
| 5xx | `internal_error` | Anything else | A general error with the reference |

**Limits.** 120 requests a minute per official (2 scans a second, §4.3; a
stack of serials is one request, §4.7), 500 serials a minute per official in
stacks (§4.7), 50 reports an hour per official (§6.1),
10 access codes and 10 access requests an hour per network address (§3.9), and 3,000 requests a
minute per network address
(shared by everyone behind it, such as supervisors on one warehouse Wi-Fi). Logging in has its own, lower limits (§3.1). Over a limit: **429** with
`Retry-After`. Go by that header, never by a number written into the app.

## 2. The phone ID

The app makes one **phone ID** the first time it runs: a random value of
22 to 128 characters from `A–Z a–z 0–9 _ -` (for example 32 random bytes in
base64url). Keep it in the phone's secure storage (Keychain on iOS, Keystore
on Android) and send the same one every time.

The first login on a phone asks for a 6-digit code we email to the official;
after that, the phone is **trusted** and logs in with the email and password
only. An official has at most **3** trusted phones; logging in on a fourth
forgets the one used longest ago. A new phone ID (for example after the app
is reinstalled) is a new phone and gets a code again.

We keep only a fingerprint of the phone ID (a SHA-256), never the ID itself.

## 3. Logging in and staying logged in

### 3.1 Log in: `POST auth/login`

```json
{ "email": "official@example.com", "password": "correct horse battery staple", "phone_id": "Qm9mYXJ…" }
```

On a trusted phone the official is logged in at once:

```json
{ "success": true, "message": "Login accepted.",
  "data": { "status": "logged_in",
            "access_token": "eyJ…", "access_expires_in": 900,
            "refresh_token": "Xk2…", "refresh_expires_in": 2592000,
            "must_change_password": false } }
```

On any other phone a code is emailed instead:

```json
{ "success": true, "message": "Login accepted.",
  "data": { "status": "code_sent", "challenge_id": "0b6e…" } }
```

Then show the code screen and call §3.2. Decide by `data.status`, never by
the message: it is the same for both.

- **401 `unauthenticated`**: the same answer for an unknown email, a wrong
  password, a blocked official and a locked account, on purpose. Show one
  message: "Email or password is incorrect."
- After 5 wrong passwords in a row the account is locked for 15 minutes; the
  answer does not say so (it stays the same 401).
- **429 `rate_limited`**: too many attempts for this email, or one account
  started more than 5 logins with a code in 15 minutes, or 20 failed logins
  from this network address within an hour. Show the `Retry-After`
  countdown.

### 3.2 The emailed code: `POST auth/verify-phone`

```json
{ "challenge_id": "0b6e…", "code": "123456", "phone_id": "Qm9mYXJ…" }
```

- **200**: the same `data` as a login on a trusted phone (`status:
  "logged_in"`, the two passes). The phone is now trusted.
- **401 `unauthenticated`**: a wrong, expired or already-used code. A code
  lives 5 minutes and allows 5 tries; after that, start again at §3.1.
  10 wrong codes in an hour lock the account for 15 minutes.
- `code` is exactly 6 digits; anything else is 400.

**`must_change_password: true`** means the official's password was set by
someone else: a new account's first password, typed by whoever added them and
emailed to them by us or given to them personally; a password their admin replaced; or a new first
password emailed by us. Whoever makes an account may leave it `false` (for
example when approving a request with the password the person chose, §3.9). Until it is changed (§3.6), every route
except `me`, `me/password` and `auth/logout` answers **403
`password_change_required`**. Show only the change-password screen.

A **first password** (typed by whoever made the account, or made and emailed by
us) works until it is used: it has no end date. It reaches the official either
by our email or from the person who made the account, who chose not to have it
emailed. Either way it must be changed at the first login when
`must_change_password` is `true`, which is the default for an account the
office makes; the first login on a phone still needs the emailed 6-digit code.

**Send the code again: `POST auth/resend-code`** with `{ "challenge_id": "0b6e…" }`.
**200**, `data: { "status": "sent" }`: a new code is emailed (the old one
stops working). At most one resend a minute (**429** with `Retry-After`)
and 3 in all (then **401**: start again at §3.1).

### 3.3 The two passes

| Pass | Lives | Where it goes |
|---|---|---|
| `access_token` | 15 minutes | the `Authorization: Bearer` header of every request |
| `refresh_token` | 30 days unused; replaced at every use | only the body of `auth/refresh` |

Keep both in the phone's secure storage, never in plain app storage or logs.
A pass works only for this client's app: the client portal refuses it, and
the app refuses a portal session.

A login ends:
- after 30 days without a renewal, or at the latest a year after it began;
- when the official logs out (§3.5);
- when the client's admin blocks the official, logs out all their phones, moves
  them to another role, or sets a new password for them;
- when the official resets a forgotten password (§3.7), on every phone;
- when the official changes the password (§3.6), on every **other** phone.

The next request then answers **401 `unauthenticated`**: go to the login
screen.

### 3.4 Renew: `POST auth/refresh`

When a request answers **401 `token_expired`**, renew and retry it once:

```json
{ "refresh_token": "Xk2…" }
```

- No `Authorization` header is needed.
- **200**: the same `data` as a login (`status: "logged_in"`, a new access
  pass **and a new refresh pass**). Store both before anything else.
- **401 `unauthenticated`**: the login has ended; go to the login screen.

**Renew once at a time.** Each refresh pass works exactly once. Sending one
that was already used ends the login, because we must assume it was copied.
If several requests fail together, they all wait for the same single
renewal:

```ts
let renewing: Promise<boolean> | null = null;
function renewOnce(): Promise<boolean> {
  renewing ??= api('auth/refresh', { refresh_token: store.refreshToken })
    .then(async (r) => { if (!r.ok) return false; await store.save((await r.json()).data); return true; })
    .finally(() => { renewing = null; });
  return renewing;
}
```

### 3.5 Log out: `POST auth/logout`

No body; the access pass in the header. **200**, `data: null`. The login on
this phone ends; delete both passes. The phone stays trusted, so the next
login on it needs no code.

### 3.6 Change the password: `POST me/password`

```json
{ "old_password": "…", "new_password": "…" }
```

- **200**, `data: { "access_token": "eyJ…", "access_expires_in": 900, "must_change_password": false }`.
  Replace the access pass with this one (the refresh pass stays). Every
  **other** phone of the official is logged out; this one stays logged in.
- **401 `unauthenticated`**: the old password is wrong.
- **403 `policy_denied`**: the new password breaks the password rule below.
  The answer does not say which part failed.

**The password rule** (for every password an official chooses: this change,
the forgotten-password reset of §3.7, the password of an access request §3.9,
and a password their admin types for them):

| Rule | Example that fails | Example that passes |
|---|---|---|
| At least **8** characters, at most 128 | `abc123` (6) | `abcd1234` |
| At least one **letter** | `12345678` | `a2345678` |
| At least one **number** | `password` | `password1` |

- Anything else is allowed: capitals or not, spaces, symbols (`!@#$%…`), and
  letters and numbers of any alphabet (Bangla `পাসওয়ার্ড১` counts as letters and
  a number). Nothing is required beyond the three rules.
- Line breaks, tabs and other control characters are refused.

**Show the rule on the screen before the official types**, and tick each part as
it is met, for example:

```
New password
  ✓ 8 characters or more
  ✓ a letter
  ✗ a number
```

Check the same three things in the app before sending, and keep the button
disabled until all three are met; a 403 then only happens when the app's check
and ours differ. Count characters, not bytes. A first password typed when an
account was made by the client's office has no rule but 1 to 128 characters,
because it works once and must be changed.

### 3.7 Forgotten password

**1. `POST auth/password/forgot`** with `{ "email": "official@example.com" }`.
Always **200**, `data: null`, "If the address has an account, a code was
sent." The same answer whether or not the email has an account. If it has,
a 6-digit code is emailed; it lives 5 minutes and allows 5 tries. A new
request replaces the code. An account gets at most 5 emailed codes in 15
minutes, login codes included; past that, no mail is sent (the answer is
still 200).

**2. `POST auth/password/reset`**

```json
{ "email": "official@example.com", "code": "123456", "new_password": "…" }
```

- **200**, `data: null`. The password is changed, **every** login of the
  official ends (on every phone), and every trusted phone is forgotten: the
  next login asks for an emailed code again.
- **401 `unauthenticated`**: a wrong, expired or used code, or an email
  without an account (the same answer).
- **403 `policy_denied`**: the new password breaks the password rule (§3.6:
  8 or more characters, a letter and a number). Show the same hints as there.
- A blocked official cannot reset a password: the answer is the same 401.
- **10 wrong codes in an hour close the official's reset for 15 minutes**
  (D64): the waiting code stops working, step 1 sends no mail, and step 2
  answers the same 401 even for the right code. The answers do not change, so
  the app cannot tell; show the usual "wrong or expired code" text and offer
  step 1 again. Logging in with the password still works meanwhile.

### 3.8 The official's profile: `GET me`

```json
{ "success": true, "message": "Profile fetched successfully.",
  "data": { "id": "5b1c…", "name": "Asha Rao", "email": "official@example.com",
            "role": "Field inspector", "permissions": ["history:own", "item:lookup"],
            "organisation": "Ziska Pharma",
            "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
            "must_change_password": false } }
```

- `permissions` are what the official's role allows (§4), sorted; an empty
  list means the role allows nothing yet.
- `organisation` is the client's name. `support` is the contact the client's
  admin set; either field can be `null` when not set.
- Call it when the app starts: **401** means the login ended.

### 3.9 Request access

A person without an account asks for one from the app; none of these routes
needs a login. The client's office reads the request in its portal and approves
or refuses it, and either way we email the person.

Build the screen in this order, so that the emailed code is still fresh when it
is sent: the name, the role, the password and the email first; then "Send code";
then the code and "Send request".

**1. The roles: `GET roles/requestable`**

```json
{ "success": true, "message": "Roles fetched successfully.",
  "data": [ { "id": 8, "name": "Distributor" }, { "id": 7, "name": "Retail seller" } ] }
```

- Only the roles the client's office lets people ask for, ordered by name. An
  empty list means none can be asked for now: show "Ask the office for an
  account" instead of the form.

**2. The code: `POST auth/access/code`** with `{ "email": "person@example.com" }`.

- Always **200**, `data: null`, "A code was sent to the address.", whatever the
  address. Show the code screen.
- A new address gets a 6-digit code; it lives 5 minutes and allows 5 tries, and
  asking again replaces it. An address that already has an account gets a mail
  saying so and pointing to "Forgot password" (§3.7), and no code.
- An address gets at most 5 mails from us in 15 minutes, login codes included;
  past that none is sent, and the answer is still 200.

**3. The request: `POST auth/access`**

```json
{ "email": "person@example.com", "code": "123456", "name": "Rahim Store", "role_id": 7, "password": "…" }
```

```json
{ "success": true, "message": "Request sent.", "data": { "status": "pending" } }
```

- **200**: the request waits for the client's office. Show "Your request was
  sent. You will get an email when it is answered." A second request for the
  same address replaces the first.
- `name`: 1 to 100 characters. `role_id`: one of step 1. `password`: the app's
  rule (§3.6). We keep the password only in a form nobody can read back, the
  client's office included.
- **What happens next.** The office may change the name, the role and even the
  password before approving. The approval mail says the person can log in
  (§3.1), with the password they chose unless the mail gives a new one; the
  first login on a phone needs the emailed code, as always. A refusal mail says
  the request was not approved.
- **The first login after approval.** With the password they chose, the person
  goes straight in (`must_change_password: false`). If the office gave a new
  password, or ticked "must change password", the login answers
  `must_change_password: true` and only the change of §3.6 is open. The app
  just follows the flag (§3.2); it never assumes either. A request nobody answers is deleted after
  **20 days**; the person may then ask again.
- **401 `unauthenticated`**: a wrong, expired or used code. An address that
  already has an account was sent no code, so it gets the same answer.
- **403 `policy_denied`**: the password breaks the rule; show the hints of §3.6.
- **404 `not_found`** "Role not found.": `role_id` is not one of step 1's.
- **409 `conflict`**: too many requests are waiting for the client's office;
  show "Try again later." The code was used up: the next try starts again at
  step 2.
- **429 `rate_limited`**: more than 10 code requests, or 10 requests, in an hour
  from this network address. Show the `Retry-After` countdown.
- **Which refusals use up the code.** A 400, 403 or 404 does not: the official
  corrects the form and sends it again with the same code (it still lives 5
  minutes and allows 5 tries in all). A 401 with a wrong code costs one of the 5
  tries. A 200 or a 409 uses it up.

## 4. Looking items up

An item can be looked up two ways, each giving the same answer:

| `way` | `value` | Where the official finds it |
|---|---|---|
| `serial` | the serial number, digits only, as text: `"1000001"` | printed on the label |
| `qr` | the 12 characters after `/q/` in the QR's link | the QR code |

The hidden code under the scratch layer is the consumer's: the app never asks
for it (`way: "hidden_code"` answers 400 since 2026-11-15).

**Reading a QR.** The QR holds a link such as
`https://www.ziskaverify.com/q/Q8F2KD91XA7M`. Take the part after the last
`/q/` and send that (`Q8F2KD91XA7M`). Never open the link inside the app: it
is the consumer's verification page.

**Permissions.** The client's admin gives each official's role its
permissions. A route the role lacks answers **403 `forbidden`**: hide what the
role cannot do (the role's permissions come with `GET me`). A change to what a
role allows takes effect within a minute.

| Permission | Opens |
|---|---|
| `item:lookup` | §4.2, one item at a time |
| `item:bulk_lookup` | checking many items: §4.3–4.5, scanner sessions (a supervisor scanning a stack of products one after another), and §4.7, a stack of typed serials |
| `history:own` | §5, the official's own checks, and §4.5, their own sessions |
| `incident:report` | §6, filing a report with photos and seeing one's own reports; picking a retail user (§7) |

No role sees other officials' checks in the app: those are for the client's
office, in its portal.

**While the app is being prepared.** When a client's app is first switched
on, every existing item gets its QR value in a job that can run up to an hour.
Until it is done, every lookup answers **503 `app_preparing`**, "The app is
being prepared. Try again later." Show that message; nothing is logged.

### 4.1 Input formats: `GET formats`

What a valid input looks like, so the app can check it before sending:

```json
{ "success": true, "message": "Formats fetched successfully.",
  "data": { "serial": { "max_digits": 19 },
            "qr": { "length": 12, "characters": "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" } } }
```

- Never build these numbers into the app: they differ between clients and can
  change.

### 4.2 One item: `POST lookups`

```json
{ "way": "qr", "value": "Q8F2KD91XA7M" }
```

```json
{ "success": true, "message": "Lookup done.",
  "data": { "ref": "MA-2026-000123",
            "result": "warning",
            "reasons": ["checked_before", "expired"],
            "count": { "this_check": 3, "last_at": "2026-10-12T09:14:00Z" },
            "item": { "serial": "1000001", "code": "*****7K2",
                      "product": { "name": "Paracetamol 500", "generic_name": "Paracetamol",
                                   "short_name": "PCM500", "picture_url": "https://…" },
                      "batch": { "number": "B-1042", "made": "2026-01-10", "expires": "2026-09-30" } } } }
```

**`result`** is one of:

| `result` | Meaning | What comes with it |
|---|---|---|
| `valid` | The item is genuine, this is its first check by any official, and nothing is wrong with it | `item`, `count` |
| `warning` | The item is genuine but needs attention: see `reasons` | `item`, `count`, `reasons` |
| `not_found` | No item of this client has this serial or QR value | nothing else |
| `unassigned` | The item exists but has not been given to a batch yet | nothing else |

A check never answers `invalid`: an item can pass from one seller to another
and be checked again.

**`reasons`** (only with `warning`, one or more):

| Reason | Meaning |
|---|---|
| `checked_before` | Officials checked this item before; `count` says how often and when |
| `recalled` | The batch was recalled |
| `expired` | The batch's expiry date has passed |
| `damaged` | The item was marked damaged |
| `switched_off` | The item's batch is switched off |

- `ref` is the check's reference number: show it with the result. It finds
  the check fast in the history (§5) and in the client's portal. Every answer
  has one, `not_found` and `unassigned` included.
- `count.this_check` is this check's number for the item (1 for a first
  check); `count.last_at` the time of the check before, `null` on a first
  check. Who made the earlier checks is never sent.
- `item.code` is the hidden code masked: `*****` and its last 3 characters,
  whatever its length. The full hidden code is never sent.
- `item.product.picture_url`, `short_name` and the batch's `made` and
  `expires` can be `null`.
- **400 `validation_failed`**: a `way` other than `serial` or `qr`, or a `value` that is not text,
  is empty, is longer than 64 characters or holds a control character. A value of the right kind that matches no
  format is not an error: it answers `not_found`.
- With a `session_id`, the lookup is a scan in a scanner session (§4.3).

### 4.3 Scanner sessions: product after product

A supervisor with a stack of products in front of them opens **scanner mode**:
the camera reads one QR code, the app sends it at once, shows the result on the
scanner screen, and the supervisor takes the next product. Every scan is the
single lookup of §4.2 with a **session ID**, so each result comes back at once
and the session keeps the totals. (Until 2026-11-10 a bulk lookup,
`POST lookups/bulk`, took up to 500 items in one request. It is removed.)

Needs `item:bulk_lookup`. A retail role usually has single lookups only: hide
scanner mode when `GET me` does not list it.

**Starting a session.** On entering scanner mode, the app makes a new random
UUID (version 4) and sends it with every scan of that session. Nothing is sent
to start it: the first scan does. Keep the ID on the phone (it is the only thing
the app may keep, §4.6) so that after a crash the app can carry on in the same
session.

#### A scan: `POST lookups` with `session_id`

```json
{ "way": "qr", "value": "Q8F2KD91XA7M", "session_id": "7f3c2a10-5b1e-4c8e-9d4a-2e6f0b9c1d33" }
```

```json
{ "success": true, "message": "Lookup done.",
  "data": { "ref": "MA-2026-004103",
            "result": "warning",
            "reasons": ["checked_before", "expired"],
            "count": { "this_check": 3, "last_at": "2026-10-12T09:14:00Z" },
            "item": { "serial": "1000311", "code": "*****7K2",
                      "product": { "name": "Paracetamol 500", "generic_name": "Paracetamol",
                                   "short_name": "PCM500", "picture_url": "https://…" },
                      "batch": { "number": "B-2291", "made": "2026-01-10", "expires": "2026-09-30" } },
            "repeat": false,
            "session": { "id": "7f3c2a10-5b1e-4c8e-9d4a-2e6f0b9c1d33",
                         "scanned": 41, "valid": 38, "warning": 2, "not_found": 1, "unassigned": 0,
                         "left": 4959 } } }
```

- Everything down to `item` is exactly the answer of §4.2, with the same
  rules. The app decides what the scanner screen shows.
- **`way` must be `qr`** in a session. Typed serials stay on the one-item
  screen, or go as a stack (§4.7).
- **`repeat: true`**: this QR was already scanned in this session. The answer is
  the **first** scan's (the same `ref` and result); it is not counted again and
  adds no check, so `session` does not change. Show "already scanned". The
  same item scanned in another session, or outside one, counts as usual.
- **`session`**: `scanned` is the different items scanned in this session so
  far, this one included; `valid`, `warning`, `not_found` and `unassigned` how
  many of them had each result; `left` how many more different items the
  session can take (5,000 in all).
- **`not_found`** and **`unassigned`**: `ref`, `result`, `repeat` and `session`
  only, as in §4.2.

| HTTP | `code` | When | What the app does |
|---|---|---|---|
| 400 | `validation_failed` | `session_id` is not a UUID, or `way` is not `qr` | A bug in the app |
| 403 | `forbidden` | the role lacks `item:bulk_lookup` | Hide scanner mode |
| 409 | `session_full` | the session has 5,000 different items | Start a new session and send the scan again in it |
| 409 | `session_ended` | the session was ended, or closed itself after 15 minutes without a scan | Start a new session and send the scan again in it, without asking the official |
| 409 | `session_not_yours` | the session ID belongs to another official | Start a new session |
| 429 | `rate_limited` | more than 120 requests a minute (2 scans a second) | Wait `Retry-After`, then send the scan again |
| 503 | `service_unavailable` | busy | Show "scan again"; nothing was recorded |

### 4.4 End a session: `POST lookups/sessions/{id}/end`

When the official leaves scanner mode (the app's back button or the phone's),
send this and leave at once: do not wait for the answer. Then forget the ID; the
next time is a new session.

```json
{ "success": true, "message": "Session ended.", "data": null }
```

- No body; **200**, `data: null`. Ending a session that has already ended
  answers the same.
- **404 `not_found`**: no such session, or another official's.
- A session nobody ended closes by itself after **15 minutes without a scan**.

### 4.5 The sessions: `GET lookups/sessions` and `GET lookups/sessions/{id}`

The official's own sessions, scanner sessions and stacks of serials alike
(`history:own`), newest first:

```
GET lookups/sessions?limit=50&status=ended&from=2026-11-01&to=2026-11-10
```

| Query | Meaning |
|---|---|
| `limit` | 1 to 100, default 50 |
| `cursor` | from the previous page's `next_cursor` |
| `status` | `open` or `ended` |
| `from`, `to` | dates (`YYYY-MM-DD`), both included; the last 7 days when left out |

`scope` is gone since 2026-11-15: sending it is **400**.

```json
{ "success": true, "message": "Sessions fetched successfully.",
  "data": { "sessions": [ { "id": "7f3c…", "kind": "qr", "status": "ended",
                            "started_at": "2026-11-10T10:15:02Z", "last_scan_at": "2026-11-10T10:32:41Z",
                            "scanned": 300, "valid": 291, "warning": 6, "not_found": 3, "unassigned": 0,
                            "official": "Karim Ahmed" } ],
            "next_cursor": null } }
```

- `kind` is `qr` for a scanner session (§4.3) and `serial` for a stack of
  serials (§4.7), which starts and ends with its one request.
- A session runs from its first scan (`started_at`) to its last
  (`last_scan_at`), however it was ended.
- `GET lookups/sessions/{id}` answers one such row: use it after a crash to
  rebuild the scanner's counter. Another official's session answers **404**.
- **A session's items** are the history (§5) filtered by it:
  `GET checks?session_id=7f3c…&limit=100`.

### 4.6 On the phone

- The list on the scanner screen lives in the app's memory only. When the
  official leaves scanner mode, clear it; to see a session again, read it from
  us (§4.5).
- The app may keep the session ID on the phone, and nothing else of a session.
  After a crash, reopen scanner mode in the same session, read
  `GET lookups/sessions/{id}` and `GET checks?session_id=…`, and carry on; if it
  answers `session_ended`, start a new one.
- Online only: a scan without a connection fails. Show "no connection, scan
  again"; nothing is queued for later.
- Do not send the same QR twice in a row while it stays in front of the camera.
  If it is sent again anyway, the answer says `repeat: true` and nothing is
  counted.

### 4.7 A stack of serials: `POST lookups/serials`

For a pile of items whose serials the official types or pastes: up to **50**
in one request, answered together (more are sent as several stacks, one after
another). Needs `item:bulk_lookup`, the permission of
scanner mode.

```json
{ "serials": ["1000001", "1000002", "1000003"] }
```

```json
{ "success": true, "message": "Lookup done.",
  "data": { "session": { "id": "c41d9e02-…", "kind": "serial",
                         "scanned": 3, "valid": 1, "warning": 1, "not_found": 1, "unassigned": 0 },
            "items": [
              { "serial": "1000001", "ref": "MA-2026-004200", "result": "valid",
                "count": { "this_check": 1, "last_at": null }, "item": { … } },
              { "serial": "1000002", "ref": "MA-2026-004201", "result": "warning", "reasons": ["recalled"],
                "count": { "this_check": 2, "last_at": "2026-11-02T08:40:00Z" }, "item": { … } },
              { "serial": "1000003", "ref": "MA-2026-004202", "result": "not_found" } ] } }
```

- `serials`: a list of 1 to 50 values, each as the `value` of §4.2 with
  `way: "serial"`. One that is no serial of this client answers `not_found`.
- **A serial sent twice** is checked once and answered once. `items` follows the
  order sent, without the repeats; each entry is the answer of §4.2 for that
  serial (`ref`, `result`, and `reasons`, `count` and `item` as there), with the
  `serial` as sent.
- **Every serial is one check:** its own reference number, its own row in the
  history (§5), counted as any check, and telling the client's office of a
  recalled, expired, damaged or switched-off item as any check does.
- **The stack is kept as a session of kind `serial`** (§4.5), started and ended
  by this one request: it shows in the sessions list, and
  `GET checks?session_id=…` lists its checks. Nothing needs ending.
- **All or nothing:** when the answer is not 200, nothing was recorded; send the
  same stack again.
- **400 `validation_failed`**: `serials` missing, not a list, empty, longer than
  50, or holding a value §4.2 would refuse.
- **403 `forbidden`**: the role lacks `item:bulk_lookup`; hide the stack screen.
- **429 `rate_limited`**: a stack is one request of the 120 a minute, and an
  official sends at most **500 serials a minute** in stacks (10 full stacks; a
  serial sent twice in one stack counts once). A stack that would pass it is refused whole, and nothing is recorded: wait the
  `Retry-After` seconds and send it again.
- **503 `app_preparing`** (§4) or **`service_unavailable`**: try again shortly.
  When many officials send stacks at the same moment, a stack can now and then
  answer 503 `service_unavailable` (5 in 600 in our load test): nothing was
  recorded, so send the same stack again after a second.

## 5. History: `GET checks`

The official's own checks, newest first (`history:own`):

```
GET checks?limit=50&result=warning&way=qr&from=2026-10-01&to=2026-10-28&search=1000001
```

| Query | Meaning |
|---|---|
| `limit` | 1 to 100, default 50 |
| `cursor` | from the previous page's `next_cursor` |
| `result` | `valid`, `warning`, `not_found`, `unassigned` |
| `way` | `serial`, `qr`, or `hidden_code` (checks made before 2026-11-15 only) |
| `from`, `to` | dates (`YYYY-MM-DD`), both included |
| `search` | a serial or a reference number |
| `session_id` | one session's checks, a scanner session's or a stack's (§4.5) |

`scope` is gone since 2026-11-15: sending it is **400**.

```json
{ "success": true, "message": "Checks fetched successfully.",
  "data": { "checks": [ { "ref": "MA-2026-000123", "at": "2026-10-28T10:02:11Z", "way": "qr",
                          "result": "warning", "reasons": ["checked_before"],
                          "serial": "1000001", "product": "Paracetamol 500", "batch": "B-1042",
                          "official": "Asha Rao", "session_id": null } ],
            "totals": { "total": 120, "valid": 80, "warning": 30, "not_found": 9, "unassigned": 1 },
            "next_cursor": "3255" } }
```

- `totals` comes with the first page only (`null` on later pages), counting
  every check that matches the filters.
- `serial`, `product` and `batch` are `null` for `not_found`, and `product`
  and `batch` for `unassigned`. `official` is the official's own name.
- `session_id` is the scanner session the check belongs to, `null` for a check
  outside one.
- `reasons` is an empty list unless the result is `warning`.
- `next_cursor` is `null` when the page is not full. A full page always gives a
  cursor, so the page after it may be empty. Pass it back as it is.
- A malformed value of any query parameter is **400**.

## 6. Reports and photos

An official reports a problem to the client's office: a note, up to 3
photos, when it is about an item they checked that check's reference number,
and when it is about a retail user that retail user (§7). Needs
`incident:report`.

**No report is needed for a warning.** A lookup whose `reasons` include
`recalled`, `expired`, `damaged` or `switched_off` already tells the office by
itself. A report is for what the lookups cannot see: a fake-looking label, a
torn seal, a shop selling where it should not.

### 6.1 File a report: `POST incidents`

```json
{ "note": "Label print is blurred and the seal is cut.", "check_ref": "MA-2026-000123",
  "retail_user_id": "9d2e…" }
```

```json
{ "success": true, "message": "Report filed successfully.", "data": { "id": 1042 } }
```

- **201** on success. Keep `id`: the photos are sent to it.
- `note`: 1 to 1,000 characters, required. Spaces around it are removed.
- `check_ref`: optional, `null` or left out when the report is about no
  check. It must be one of **this official's own** checks: another
  official's, or a reference that does not exist, answers **404
  `not_found`** "Check not found.", the same for both.
- `retail_user_id`: optional, `null` or left out when the report is about no
  retail user. The `id` of a retail user from §7.1. An unknown one, a blocked
  one, or an official who is not a retail user answers **404 `not_found`**
  "Retail user not found.", the same for all three.
- **Limit:** 50 reports an hour per official. Over it: **429
  `rate_limited`** with `Retry-After`.

### 6.2 Add a photo: `POST incidents/{id}/photos`

The body is **the photo file itself**: not JSON, not a form.

```
POST incidents/1042/photos
Content-Type: image/jpeg
Content-Length: 612480

<the JPEG's bytes>
```

```json
{ "success": true, "message": "Photo uploaded successfully.", "data": { "n": 1 } }
```

- **201** on success; `n` is the photo's number on the report, 1 to 3.
- **Before sending**, shrink the photo to **2048 pixels** on its longer side
  and save it as **JPEG at quality 85**: about 400 to 800 KB,
  and a label's small print stays sharp. The server stores the file exactly as
  sent; it neither shrinks it nor removes what the phone adds (time, phone
  model, and the place if the phone records it).
- **At most 1 MB**, JPEG or PNG. What the file is, its own first bytes decide,
  never its name or `Content-Type`. Send the size (`Content-Length`): a request
  without it, or over 1 MB, is refused before the photo is read.
- **Only the report's author**, within **1 hour** of filing it, and at most 3
  photos. Send them one at a time, after the report.
- **Sending the same photo again is safe.** If the answer was lost (the
  network dropped), send it again: the same file on the same report answers
  its `n` once more and is not counted twice.

| HTTP | `code` | Message | When |
|---|---|---|---|
| 400 | `validation_failed` | "The photo must be at most 1 MB." | over 1 MB, or no `Content-Length` |
| 400 | `validation_failed` | "The file is not a JPEG or PNG photo." | anything else, a WebP or HEIC photo included |
| 400 | `validation_failed` | "The photo is empty." | an empty body |
| 400 | `validation_failed` | "Send the photo file itself as the request body, as image/jpeg or image/png." | JSON, or no body |
| 415 | `validation_failed` | "Invalid request." | another `Content-Type`, a form or `image/webp` included: the body is not read |
| 404 | `not_found` | "Report not found." | no such report, or another official's |
| 409 | `conflict` | "The report has 3 photos already." | a 4th photo |
| 409 | `conflict` | "Photos can be added only within an hour of the report." | after the hour |
| 503 | `service_unavailable` | "Service temporarily unavailable." | the photo storage cannot be reached, or did not take the photo within 10 seconds, or the client's other uploads keep it waiting as long: send it again shortly |

**On the phone:** a report and its photos are separate requests. When a
photo fails with 503 or a lost connection, keep it and send it again; the
report itself is already filed. Do not file the report again: that makes a
second report.

### 6.3 The official's own reports: `GET incidents`

The reports this official filed, newest first. Needs `incident:report`. Nobody
else's reports appear, whatever the role, and the warnings the lookups raise by
themselves are not in this list.

```
GET incidents?limit=50
```

| Query | Meaning |
|---|---|
| `limit` | 1 to 100, default 50 |
| `cursor` | from the previous page's `next_cursor` |

```json
{ "success": true, "message": "Reports fetched successfully.",
  "data": { "reports": [ { "id": 1042, "at": "2026-10-28T10:04:37.512+00:00",
                           "note": "Label print is blurred and the seal is cut.",
                           "photos": 2, "check_ref": "MA-2026-000123",
                           "retail_user": { "id": "9d2e…", "name": "Rahim Store" } } ],
            "next_cursor": "1042" } }
```

- `photos` is how many photos the report has, 0 to 3. The app cannot download
  them: the photos are for the client's office.
- `check_ref` is the check the report points to, `null` when it points to none.
- `retail_user` is the retail user the report names, `null` when it names none.
- `next_cursor` is `null` when the page is not full. A full page always gives a
  cursor, so the page after it may be empty.
- Any other query parameter, or a malformed one, is **400**.
- A role without `incident:report` gets **403**.

## 7. Retail users

A **retail user** is a seller who uses the app: an official in a role the
client's office marks as a retail role. They log in and look items up like any
official, with what their role allows. A report can name the retail user it is
about (§6.1). The client's office makes retail users in its portal, or approves
a seller's own request (§3.9). (Until 2026-11-15 an official with
`retail_user:add` could add one here; `GET retail-roles`, `POST retail-users` and
`POST retail-users/{id}/password` now answer 404.)

### 7.1 Pick a retail user: `GET retail-users`

Needs `incident:report`.

```
GET retail-users?search=rahim&limit=50
```

| Query | Meaning |
|---|---|
| `search` | part of a name (any case), or a whole email address; up to 100 characters |
| `limit` | 1 to 100, default 50 |
| `cursor` | from the previous page's `next_cursor` |

```json
{ "success": true, "message": "Retail users fetched successfully.",
  "data": { "retail_users": [ { "id": "9d2e…", "name": "Rahim Store", "email": "ra***@gmail.com" } ],
            "next_cursor": null } }
```

- Only the client's retail users who are not blocked, ordered by name.
- `email` is masked: the first 2 characters before the `@` (1 when there are
  only 1 or 2), then `***`, then the `@` and the rest. The whole address is
  never sent here.
- `next_cursor` is `null` when the page is not full. A full page always gives
  a cursor, so the page after it may be empty.

## 8. Versions and questions

- **Versions.** Every route is under `/v1/` and only grows: new routes and new
  fields in answers can appear, so ignore a field you do not know. (The one
  exception is 2026-11-15, before any client's app was live: see the top.) A change that
  would break your app comes as `/v2/`, and `/v1/` keeps working for a period we
  agree with you.
- **Testing.** A test client with made-up items and officials comes with the test
  server, whose address we give you when it exists. Never test on a live client:
  every check is kept for good.
- **Questions** come to us, at the address you have from us with the host and the
  client's name. Send the `request_id` of the answer you are asking about.
