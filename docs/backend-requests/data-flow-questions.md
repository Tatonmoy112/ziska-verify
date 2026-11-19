# Backend Questions: Data Flow (2026-11-17)

> **Status 2026-11-17: sent to the backend team.** The app works as described under "What the app does now" for each question. An answer that differs changes only that point.

**From:** the mobile app team. **To:** the ProtectB backend team. **Contract checked:** `docs/protectb-api/` at backend commit ebff1d9 (app API guide, build guide, Postman collection).

The app's data flow was checked route by route against the contract: every request field, query parameter and answer field matches in name, type and nullability, and every documented error code is handled. Four points are not settled by the documents.

## Q1. The days of `from` and `to`

**Routes:** `GET checks` and `GET lookups/sessions`.

**Question:** Are `from` and `to` UTC calendar days or Bangladesh calendar days (Asia/Dhaka, UTC+6)? A check made at 01:00 Dhaka time on 17 November is still 16 November in UTC.

**What the app does now:** It shows every time in Dhaka time and sends the calendar date the official picked, as `YYYY-MM-DD`.

## Q2. Upper and lower case in a QR value

**Route:** `POST lookups` with `way: "qr"`.

**Question:** Is the QR value matched without regard to case? `GET formats` lists the QR characters as capitals and digits (`ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`).

**What the app does now:** It sends the value after the last `/q/` as read, trimmed only (guide §4), and checks it against the `characters` of `GET formats`. A value in lower case is refused on the phone ("This QR code is not a product code of this company.") and is not sent.

## Q3. Renewing the pass during a forced password change

**Route:** `POST auth/refresh` while `must_change_password` is true.

**Question:** Does `auth/refresh` answer 200 with `must_change_password: true`, or `403 password_change_required`?

**What the app does now:** A 200 with `must_change_password: true` opens the change screen. A 403 keeps the login: the request that needed the renewal fails with "Something went wrong. Try again." and the change screen is not opened.

## Q4. An empty body on `auth/logout`

**Routes:** `POST auth/logout` and `POST me/password/later`.

**Question:** Is a request with no body and `Content-Type: application/json` accepted, or refused as an empty JSON body?

**What the app does now:** It sends both with no body and no `Content-Type`, as the Postman collection does. The answer matters only if a later contract asks for a body.
