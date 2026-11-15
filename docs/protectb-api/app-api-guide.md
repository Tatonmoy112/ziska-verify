# ProtectB mobile app API — guide for the app's developers

_For the developers who build the client's mobile app. It lists every route
the app can call, with an example of each. A Postman collection with every route
comes with it: `ProtectB-mobile-app.postman_collection.json`; how to build the app
on it, step by step, is `app-build-guide.md`._

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
| 409 | `conflict` | The request conflicts with the current state (§6.2, §7) | Show the message |
| 429 | `rate_limited` | Too many requests | Wait the seconds in the `Retry-After` header |
| 503 | `app_preparing` | The client's app was just switched on and is being prepared (§4) | "The app is being prepared. Try again later." |
| 503 | `service_unavailable` | A part of our service is down | "Try again shortly" |
| 5xx | `internal_error` | Anything else | A general error with the reference |

**Limits.** 120 requests a minute per official, 3,000 looked-up items a
minute per official (§4.3), 50 reports an hour per official (§6.1), 30 retail
users added or passwords emailed an hour per official (§7), and 1,200
requests a minute per network address (shared by everyone behind it, such as one
office). Logging in has its own, lower limits (§3.1). Over a limit: **429** with
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
password emailed by us (§7.4). Until it is changed (§3.6), every route
except `me`, `me/password` and `auth/logout` answers **403
`password_change_required`**. Show only the change-password screen.

A **first password** (typed by whoever made the account, or made and emailed by
us) works until it is used: it has no end date. It reaches the official either
by our email or from the person who made the account, who chose not to have it
emailed. Either way it must be changed at the first login, and the first login
on a phone still needs the emailed 6-digit code.

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
the forgotten-password reset of §3.7, and a password their admin types for
them):

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
account was made (by the admin, or by a supervisor for a retail user, §7.3) has
no rule but 1 to 128 characters, because it works once and must be changed.

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

## 4. Looking items up

An item can be looked up three ways, each giving the same answer:

| `way` | `value` | Where the official finds it |
|---|---|---|
| `serial` | the serial number, digits only, as text: `"1000001"` | printed on the label |
| `qr` | the 12 characters after `/q/` in the QR's link | the QR code |
| `hidden_code` | the code under the scratch layer | scratched off |

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
| `item:bulk_lookup` | §4.3, many items at once (a supervisor checking 50 QR codes, say); since 2026-11-03 |
| `history:own` | §5, the official's own checks |
| `history:all` | §5, the official's own checks and every official's, and who made an item's earlier checks |
| `incident:report` | §6, filing a report with photos and seeing one's own reports; picking a retail user (§7.1) |
| `retail_user:add` | §7, adding retail users and emailing their first password |

**While the app is being prepared.** When a client's app is first switched
on, every existing item gets its QR value in a job that can run up to an hour.
Until it is done, every lookup answers **503 `app_preparing`**, "The app is
being prepared. Try again later." Show that message; nothing is logged.

### 4.1 Input formats: `GET formats`

What a valid input looks like, so the app can check it before sending:

```json
{ "success": true, "message": "Formats fetched successfully.",
  "data": { "hidden_code": [ { "length": 12, "characters": "0123456789" } ],
            "serial": { "max_digits": 19 },
            "qr": { "length": 12, "characters": "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" } } }
```

- `hidden_code` lists every format this client uses (there can be several
  lengths). Spaces and `-` an official types are ignored, and lower-case
  letters are read as capitals.
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
| `not_found` | No item of this client has this serial, QR value or hidden code | nothing else |
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

- `ref` is the check's reference number. Put it on a certificate: the
  client's office looks it up to confirm the certificate.
  Every answer has one, `not_found` and `unassigned` included.
- `count.this_check` is this check's number for the item (1 for a first
  check); `count.last_at` the time of the check before, `null` on a first
  check. For an official with `history:all`, `count.by` lists the names of
  the officials of earlier checks.
- `item.code` is the hidden code masked: `*****` and its last 3 characters,
  whatever its length. The full hidden code is never sent.
- `item.product.picture_url`, `short_name` and the batch's `made` and
  `expires` can be `null`.
- **400 `validation_failed`**: an unknown `way`, or a `value` that is not text,
  is empty, is longer than 64 characters or holds a control character. A value of the right kind that matches no
  format is not an error: it answers `not_found`.

### 4.3 Many items: `POST lookups/bulk`

Needs `item:bulk_lookup` (until 2026-11-03 `item:lookup` opened it; every role
holding `item:lookup` then was given `item:bulk_lookup` too, so nobody lost
it). A retail role usually has single lookups only: hide the bulk screen when
`GET me` does not list it.

Up to 500 items in one request, of any ways mixed:

```json
{ "items": [ { "way": "serial", "value": "1000001" },
             { "way": "qr", "value": "Q8F2KD91XA7M" },
             { "way": "hidden_code", "value": "4815 1623 4200" } ] }
```

```json
{ "success": true, "message": "Lookup done.",
  "data": { "summary": { "total": 3, "valid": 1, "warning": 1,
                         "by_reason": { "checked_before": 1, "expired": 0, "recalled": 0, "damaged": 0, "switched_off": 0 },
                         "not_found": 1, "unassigned": 0 },
            "results": [ { "ref": "MA-2026-000124", "result": "valid", "count": { … }, "item": { … } },
                         { "ref": "MA-2026-000125", "result": "warning", "reasons": ["checked_before"], … },
                         { "ref": "MA-2026-000126", "result": "not_found" } ] } }
```

- `results` are in the order sent: the first result is the first item. What
  was sent is never repeated in the answer; match by position.
- `by_reason` counts items, so an item with two reasons counts in both.
- Every item counts as its own check, with its own reference number, even the
  same item twice in one request.
- 0 or more than 500 items: **400 `validation_failed`**.
- **503 `service_unavailable`** (our service is very busy): none of the items
  was checked or recorded. Send the same request again after a few seconds;
  each item then gets its true answer.

**Limit.** 3,000 items a minute per official, a bulk request counting as its
items. Over it: **429 `rate_limited`** with `Retry-After`, and nothing in the
request is checked. The limit is counted over the last minute as an
estimate, so an official sending bulks without a pause can be refused a
little before 3,000 (at full speed about 2,700 items a minute get through).
Wait the seconds in `Retry-After`, then send the same request again.

## 5. History: `GET checks`

The official's own checks, newest first (`history:own`), or every official's
(`history:all`, with `?scope=all`):

```
GET checks?limit=50&result=warning&way=qr&from=2026-10-01&to=2026-10-28&search=1000001
```

| Query | Meaning |
|---|---|
| `limit` | 1 to 100, default 50 |
| `cursor` | from the previous page's `next_cursor` |
| `result` | `valid`, `warning`, `not_found`, `unassigned` |
| `way` | `serial`, `qr`, `hidden_code` |
| `from`, `to` | dates (`YYYY-MM-DD`), both included |
| `search` | a serial or a reference number |
| `scope` | `own` (default; needs `history:own` or `history:all`) or `all` (needs `history:all`) |

```json
{ "success": true, "message": "Checks fetched successfully.",
  "data": { "checks": [ { "ref": "MA-2026-000123", "at": "2026-10-28T10:02:11Z", "way": "qr",
                          "result": "warning", "reasons": ["checked_before"],
                          "serial": "1000001", "product": "Paracetamol 500", "batch": "B-1042",
                          "official": "Asha Rao" } ],
            "totals": { "total": 120, "valid": 80, "warning": 30, "not_found": 9, "unassigned": 1 },
            "next_cursor": "3255" } }
```

- `totals` comes with the first page only (`null` on later pages), counting
  every check that matches the filters.
- `serial`, `product` and `batch` are `null` for `not_found`, and `product`
  and `batch` for `unassigned`. `official` is the name of whoever checked.
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
| 503 | `service_unavailable` | "Service temporarily unavailable." | the photo storage cannot be reached: send it again shortly |

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
about (§6.1). The client's office adds retail users in its portal; an official
whose role has `retail_user:add` (a supervisor, say) can also add one on the
spot, here.

**The first password** is typed by the official who adds the retail user
(§7.3). By default we email it to the retail user; the official can instead
give it to them personally (`send_email: false`). Later ones (§7.4) are made and
emailed by us, never shown to the official. The retail user logs in with it,
must change it at once (§3.2), and their phone needs the emailed code as any
new phone does. It works until it is used: there is no end date.

**Limit:** 30 retail users added or passwords emailed an hour per official,
together. Over it: **429 `rate_limited`** with `Retry-After`.

### 7.1 Pick a retail user: `GET retail-users`

Needs `incident:report` or `retail_user:add`.

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

### 7.2 The retail roles: `GET retail-roles`

Needs `retail_user:add`. The roles a new retail user can be given.

```json
{ "success": true, "message": "Retail roles fetched successfully.",
  "data": [ { "id": 7, "name": "Retail seller" } ] }
```

An empty list means the client's office has marked no role as a retail role
yet: no retail user can be added until it does.

### 7.3 Add a retail user: `POST retail-users`

Needs `retail_user:add`.

```json
{ "name": "Rahim Store", "email": "rahim.store@gmail.com", "role_id": 7, "password": "1234567890", "send_email": true }
```

```json
{ "success": true, "message": "Retail user added successfully.",
  "data": { "id": "9d2e…", "name": "Rahim Store", "email": "rahim.store@gmail.com", "email_sent": true } }
```

- **201** on success. The retail user can be named on a report at once.
- `name`: 1 to 100 characters. `email`: the address the retail user will log
  in with and read the mail at; it must be real, or they can never log in.
  `role_id`: one of §7.2. `password`: required, 1 to 128 characters, no
  control characters, and no other rule: it is used once and must be changed at
  the first login.
- `send_email`: optional, `true` or `false`; left out it is `true`.
  - `true`: we email the password to the retail user with the login email.
  - `false`: no mail. The official gives the password to the retail user
    personally. Show a switch "Email the login details" (on by default) and,
    when it is off, "Give the password to the retail user yourself."
  - Anything but `true` or `false`: **400 `validation_failed`**.
- `email_sent`:
  - `true`: the mail went.
  - `false`: we tried and it could not be sent; the account was made. Say so:
    the official gives the retail user the password they typed, or emails a new
    one (§7.4) a little later.
  - `null`: not sent, as asked (`send_email: false`).
- **409 `conflict`** "An official with this email already exists.": anyone of
  the client's officials, retail or not, already has it.
- **404 `not_found`** "Role not found.": `role_id` is not a retail role.

### 7.4 Email a new first password: `POST retail-users/{id}/password`

Needs `retail_user:add`. For a retail user whose mail never arrived or was lost,
or who was given the password personally and lost it. No body. This one is
always emailed.

```json
{ "success": true, "message": "Password emailed.", "data": { "email_sent": true } }
```

- The new password replaces the old one, which stops working at once.
- **409 `conflict`** "The retail user has set their own password.": once a
  retail user has chosen their own, only the client's office can change it.
- **404 `not_found`** "Retail user not found.": no such official, one who is
  not a retail user, or a blocked one.

## 8. Versions and questions

- **Versions.** Every route is under `/v1/` and only grows: new routes and new
  fields in answers can appear, so ignore a field you do not know. A change that
  would break your app comes as `/v2/`, and `/v1/` keeps working for a period we
  agree with you.
- **Testing.** A test client with made-up items and officials comes with the test
  server, whose address we give you when it exists. Never test on a live client:
  every check is kept for good.
- **Questions** come to us, at the address you have from us with the host and the
  client's name. Send the `request_id` of the answer you are asking about.
