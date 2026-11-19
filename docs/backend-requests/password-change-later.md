# Backend Request: Change the First Password Now, or Later

> **Status 2026-11-17: requested; the backend team will build it.** The app has Not now (and the Profile reminder) built against this contract; until the route exists, the mock build plays it (`DEMO_PASSWORD_LATER`). Backend D59 (the office decides per account whether a change is forced) works beside it.

**From:** the mobile app team. **To:** the ProtectB backend team. **Date:** 2026-11-16.

## In Short

1. **New route `POST me/password/later`:** allowed with the restricted pass of a forced change. It returns a normal access pass, and the refresh pass stays.
2. **New field `password_change_skippable: true`:** next to `must_change_password: true` in login, verify-phone, refresh, and `GET me`.
3. **New field `password_change_pending`** in `GET me`: true after **Not now**, cleared by a password change or a reset.
4. **After Not now,** renewals answer `must_change_password: false`. **The next login** answers `true` again.
5. **Postman:** add the route and the fields to the collection and the mock server.

## What the Client Wants

After the first login, or after an admin sets a new password, the official may either change the password at once or tap **Not now** and keep working. The app asks again at every login until the password is changed, and shows a reminder on Profile meanwhile.

The client wants this for every official: a new account's first password and an admin-set password alike.

## Why the App Cannot Do It Alone

Today the backend enforces the change:
- **The 403 block:** while `must_change_password` is true, every route except `me`, `me/password`, and `auth/logout` answers `403 password_change_required` (app API guide §3.2).
- **The restricted pass:** the login's access pass itself only allows those routes.
- **The written rule:** `phase-2-accounts-login.md` says "A forced password change cannot be skipped: every other route refuses."

**Not now** therefore needs a route that gives the official a normal access pass while the password is still the one someone else set.

## Requested Contract

### 1. New Route: `POST me/password/later`

| | |
|---|---|
| Auth | The access pass of a login with `must_change_password: true` |
| Body | None |
| Answer 200 | `{ "access_token": "eyJ…", "access_expires_in": 900, "must_change_password": false, "password_change_pending": true }` |
| Refresh pass | Stays as it is (the same as `POST me/password`) |
| 401 `token_expired` | The usual renewal, then one retry |
| 403 `forbidden` | Skipping is turned off for this account |

The new access pass allows every route the official's role allows.

### 2. Renewals After Not Now
`POST auth/refresh` in the same login answers `must_change_password: false`, so the change is not forced again in the middle of the day.

### 3. The Next Login Asks Again
`POST auth/login` (and `POST auth/verify-phone` on a new phone) answers `must_change_password: true` again until the password is changed.

### 4. New Field: `password_change_skippable`
Sent next to `must_change_password: true` in:
- `POST auth/login` and `POST auth/verify-phone` (`logged_in`);
- `POST auth/refresh`;
- `GET me`, which the app reads after a restart.

It is `true` for every official, per the client. A backend without the route leaves it out, and the app keeps the change required.

### 5. New Field in `GET me`: `password_change_pending`
`true` while the password is still the one someone else set (the official chose **Not now**). Both of these clear it:
- `POST me/password`;
- a forgotten-password reset (`POST auth/password/reset`).

### 6. Postman
Please add `POST me/password/later` and the two fields to the Postman collection and the mock server, so the mock build shows the choice too.

## The Security Trade-Off

A first password has no end date (backend D55). A skipped one therefore stays valid until the official changes it, and the person who typed or emailed it may still know it.

The app keeps asking:
- the choice screen at every login;
- a warning banner on Profile with **Change password**.

If the client later wants a limit, the backend can answer `403 forbidden` on `POST me/password/later`, for example after a number of skips or days. The app then hides **Not now** and the change becomes required again, with no app update.

## What the App Already Does (Built and Tested)

Built against this contract and tested on the app's fake backend; it switches on when the backend sends `password_change_skippable: true`.
- **Choice screen:** **Set a new password** with **Save password**, **Not now**, and **Log out**.
- **Not now:** stores the new access pass and continues to the app.
- **Errors:** a refused **Not now** (`403 forbidden`) shows "Not now is not available for your account. Choose a new password or log out." and hides the button. Offline shows the usual network message.
- **Profile reminder:** the banner shows while `password_change_pending` is true, and goes after a change.
- **Without the new field:** today's required change, unchanged.

## Postman Examples to Add

**`POST me/password/later` → 200 "Not now: a normal pass"**
```json
{
  "success": true,
  "message": "Password change postponed.",
  "data": {
    "access_token": "eyJ…",
    "access_expires_in": 900,
    "must_change_password": false,
    "password_change_pending": true
  }
}
```

**`POST me/password/later` → 403 "Skipping is off for this account"**
```json
{
  "success": false,
  "message": "You must change your password before continuing.",
  "error": { "code": "forbidden", "message": "You must change your password before continuing.", "request_id": "req-…" }
}
```

**`POST auth/login` (and `auth/verify-phone`, `auth/refresh`) → 200 "Logged in: change the password, or later"**
```json
{
  "success": true,
  "message": "Logged in.",
  "data": {
    "status": "logged_in",
    "access_token": "eyJ…",
    "access_expires_in": 900,
    "refresh_token": "…",
    "refresh_expires_in": 2592000,
    "must_change_password": true,
    "password_change_skippable": true
  }
}
```

**`GET me` → 200 "After Not now"**
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "…",
    "name": "Asha Rao",
    "email": "official@example.com",
    "role": "Field inspector",
    "permissions": ["history:own", "item:lookup"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+880…" },
    "must_change_password": false,
    "password_change_pending": true
  }
}
```

## Checklist for the Backend Team

- [ ] `POST me/password/later` exists. It is allowed with the restricted pass and returns a normal access pass; the refresh pass is unchanged.
- [ ] `403 forbidden` when skipping is turned off for the account.
- [ ] `password_change_skippable: true` sits next to `must_change_password: true` in login, verify-phone, refresh, and `GET me`.
- [ ] After **Not now**, `POST auth/refresh` answers `must_change_password: false` for the rest of that login.
- [ ] The next `POST auth/login` / `verify-phone` answers `must_change_password: true` again.
- [ ] `GET me` answers `password_change_pending: true` after **Not now**. `POST me/password` and `POST auth/password/reset` set it back to false.
- [ ] The Postman collection and the mock server have the examples above.
- [ ] `app-api-guide.md` §3.2 and §3.6 describe the route and the fields. The "cannot be skipped" line in `phase-2-accounts-login.md` is updated.

Until this ships, the app's mock build plays these answers on the phone (`DEMO_PASSWORD_LATER`), so the flow can be seen and tested now. Staging and live builds keep the change required.
