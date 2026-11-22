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
| 2 | Login and staying logged in | **Done** 2026-11-22 |
| 3 | Profile and permissions | **Done** 2026-11-22 |
| 4 | One check | **Done** 2026-11-22 |
| 5 | History and the sessions list | **Done** 2026-11-22 |
| 6 | Serial stacks | **Done** 2026-11-22 |
| 7 | Scanner sessions | Next |
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

## Step 2. Login and staying logged in (2026-11-22)

**Cases first:** already covered offline by about 110 tests:
- login `logged_in` and `code_sent`; wrong, expired and used codes; five wrong codes;
- resend's wait and its 3-in-all limit; `429` with `Retry-After`;
- one renewal at a time; a refused renewal; a forced change; logout's worst cases.

No new offline case was needed. Step 2's new tests replay the server's real answers.

**Against the server** (the checker: `login`, the code pasted by the owner, `verify`, then `session`):

| Check | Result |
|---|---|
| `POST auth/login` (a new phone) | 200 `code_sent` with a `challenge_id`; the code emailed |
| `POST auth/verify-phone` | 200 `logged_in`: both passes (access 15 minutes, refresh 30 days), `must_change_password: false` (no forced change) |
| `GET me` | Supervisor, permissions `history:own`, `incident:report`, `item:bulk_lookup`, `item:lookup`; organisation "Ziska-test"; support email and phone `null` |
| `GET formats` with the pass | 200 |
| `POST auth/refresh` | 200: two new passes; the next request works with the new one |
| `POST auth/logout` | **200 when sent bare** (no body, no type, as the app sends it). **The first run sent an empty JSON body and got `400 validation_failed`**: this answers data-flow question Q4. |
| `GET me` after logout | 401 `unauthenticated` |
| `POST auth/refresh` with an already used pass | 401 `unauthenticated` |
| `POST auth/login` again on the same phone | 200 `logged_in` at once: the phone is trusted |

**Differences from the contract:** none. The only failure was the checker's own: its first version did not strip the type of a bodiless request as the app does (`BodilessRequestInterceptor`). It now does.

**Real-answer tests** (`test/staging/step2_login_session_test.dart`, TC-STG-008 … -013): the ten saved answers (passes, challenge, email, name and IDs replaced) replayed through the whole app: login with the code; the trusted phone; renewal; logout; a used refresh pass; a pass ended elsewhere.

**On the emulator** (TC-STG-014): passed.
- **Login with the emailed code:** "Welcome back, Trendsbird", "Ziska-test".
- **Restart:** still logged in.
- **Profile:** the four permissions and "Not set by your office".
- **Logout:** back to Login.
- **The next login:** no code.

The first attempt said "No connection" while the emulator's network was dropping packets (the ping to the server varied from 22 to 508 ms); the retry worked. The app reported it correctly.

## Step 3. Profile and permissions (2026-11-22)

**Cases first.** Covered already: every role; unknown, duplicated and capitalised permissions; a missing permissions list; a `403` reloading the profile; no organisation; support with an email or a phone only.

**Gap found and closed:** the app took the server's text as it came. Tests first (TC-PROF-042 … -045), then the fix in `profile_mapper.dart`: text the server sends empty or as spaces now counts as not set.
- **Support:** an empty email (`""`) used to give a blank "Support contact" row that opened the mail app with no address. It now shows "Not set by your office".
- **Organisation:** an empty one now shows "—" on Profile and the app's name on Check.
- **Name:** a blank one gives way to the email, so the screens never greet nobody.

**Against the server** (the checker's `profile` step, logged in on its trusted phone without a code):

| Check | Result |
|---|---|
| `GET me` | Supervisor; organisation "Ziska-test"; support email and phone `null`; no `password_change_pending` field |
| Permissions | `history:own`, `incident:report`, `item:bulk_lookup`, `item:lookup` |
| `GET formats` (item:lookup) | 200: serials up to 19 digits; QR 12 characters, capitals and digits |
| `GET checks?limit=1` (history:own) | 200: no checks, totals all 0, `next_cursor: null` |
| `GET lookups/sessions?limit=1` (item:bulk_lookup) | 200: no sessions |
| `GET incidents?limit=1` (incident:report) | 200: no reports |
| `GET retail-users?search=a` (incident:report) | 200: **no retail users on the server** |
| `POST auth/logout` | 200 |

**Differences from the contract:** none. **The account is new:** nothing is recorded yet, and the server has no retail users. The retail-user picker of step 8 can be checked only once the office adds one (added to backend request B1).

**Real-answer tests** (`test/staging/step3_profile_test.dart`, TC-STG-015 … -017):
- Profile from the real `me`;
- a new account's counts are 0;
- every tab and tool the four permissions open.

**On the emulator** (TC-STG-018): passed.
- **Profile:** "Trendsbird", Supervisor, "Ziska-test", the email, counts 0 / 0 / 0, the four permissions, "Not set by your office".
- **Check:** the serial field, Scanner mode, Serial stack, Report incident and My reports.

## Step 4. One check (2026-11-22)

**Cases first.** Already covered by about 48 flow tests and the contract tests:
- every result and reason, and several reasons together;
- unknown results or reasons, never shown as genuine;
- `null` optional fields, and extra fields ignored;
- the serial length and the QR from `GET formats`;
- QR links (only the value after the last `/q/`);
- `429` countdowns, `500` and `503`.

No new offline case was needed.

**Against the server** (the checker's `lookup` step; each input prepared by the app's own rules, every answer read by the app's parser):

| Sent | Result |
|---|---|
| `GET formats` | serial up to 19 digits; QR 12 characters, capitals and digits |
| serial `1` | **valid**: Napa Extra 500 (Paracetamol + Caffeine, "Napa Extra"), batch ZT-2509-001, made 2025-09-18, expires 2027-09-18, masked code `*****BQQ`, **no picture** |
| serial `0000000000000000001` | **warning, checked_before**: the same item `1` (check 2; `last_at` written with `+00:00`) |
| serials `1000001` … `1000004` | **unassigned** (only `ref` and `result`) |
| serial `1234567890`, QRs `Q8F2KD91XA7M`, `K7M2PX4Q9AB1` | **not_found** |
| the hidden-code way | 400 `validation_failed` |
| serial `12AB` (the app never sends it) | **200 `not_found`, recorded** |

All four results exist on the test server, and the app reads each one. **Differences from the contract:** none in what the app sends. Two server rules are not in the guide, so they went to the backend (B5):
- **Leading zeros:** serials are compared as numbers, so `000…1` is item `1`. This matters for stacks; it will be checked in step 6.
- **Letters:** a serial with letters is recorded as not found, not refused.

None of the test items has a picture, so the product picture is still unseen from the real server.

**Real-answer tests** (`test/staging/step4_lookup_test.dart`, TC-STG-019 … -024): genuine, with every field; checked before, in Bangladesh time; not in a batch; not found; a QR through the Check tab's camera; and the two answers to requests the app never sends.

**On the emulator** (TC-STG-025): passed.
- **`1`:** check 3, so "Genuine, needs attention · Checked before", last check 12:30 PM, with every product field.
- **`1000001`:** "Not in a batch".
- **`1234567890`:** "Not found", with the server's reference and hints for up to 19 digits.

The loader ("Checking the item…") showed while the slow emulator network waited.

## Step 5. History and the sessions list (2026-11-22)

**Cases first.** History was covered:
- filters, searches, Bangladesh dates, paging races and rate limits;
- totals on the first page only, missing totals, rows without serial, product or batch.

The Sessions view had only its main flow. Four cases were added: History's empty last page after a cursor (TC-HIST-050), and for Sessions, none in the period, paging by cursor, and a failed first page (TC-MIG-057 … -059). All passed at once: no app change.

**Against the server** (the checker's `history` step, read only, through the app's query builder, parser and mapper):

| Check | Result |
|---|---|
| First page | 13 checks, newest first, all the official's own; totals 13 = 1 valid + 2 warning + 5 not found + 5 not in a batch |
| Paging by 5 | 3 pages, cursors `9`, `4`, then none; every check once; totals on the first page only |
| `result` filters | valid 1, warning 2, not found 5, not in a batch 5; each row of the filtered result |
| `way` filters | serial 11, qr 2 |
| `from` = `to` = today (Dhaka) | all 13 |
| `search=1`, `search=0000000000000000001` | the same 3 checks of item 1 (the server compares serials as numbers: B5) |
| `search=<a reference>` | that one check |
| `GET lookups/sessions` | none yet |

Not-found rows carry `serial`, `product` and `batch` as `null`, as the guide says. **Differences from the contract:** none.

The checker's first run stopped at the date filter because the checker had not loaded the timezone data the app loads at start. That was the checker's fault, not the app's or the server's; it now loads it.

**Real-answer tests** (`test/staging/step5_history_test.dart`, TC-STG-026 … -029):
- the real first page: counts, rows, "Checked by", Bangladesh time;
- the real pages of 5 with their cursors;
- the real serial search as a tracking log;
- the real empty sessions list.

**On the emulator** (TC-STG-030): passed.
- **History:** All 13, Valid 1, Warning 2, newest "Today · 12:36 PM", "Checked by Trendsbird".
- **Valid:** only the genuine check.
- **Sessions:** "No sessions found."

## Step 6. Serial stacks (2026-11-22)

**Cases first.** Already covered:
- 1 to 50 serials, more refused, never split; repeats removed; order kept;
- a `503` sent again once; a lost answer never sent again; a backgrounded resend cancelled;
- a 200 that cannot be read, or whose rows do not match, counts as recorded.

Added before asking the server: what happens if the server answers `001` as `1`, or merges `001` with `1` (TC-MIG-060). The app fails safe: "recorded, cannot be shown", never sent twice.

**Against the server** (the checker's `stack` step):

| Sent | Result |
|---|---|
| `1, 1000001, 1234567890` | A session of kind `serial`, scanned 3; rows in order with the serials as sent: checked before, not in a batch, not found |
| `001, 1` (as the app used to send it) | **One row, `001`, scanned 1**: the server takes them for one serial. The app expected two rows, so it would have shown "recorded, cannot be shown" |
| `1000002, 1000002` (raw) | One row: a repeat is checked once |
| 51 serials (raw) | 400 `validation_failed` |
| `12AB` (raw) | **200**, one row: the guide says 400 for a value §4.2 refuses, but §4.2 does not refuse it either (B5) |
| The stack's session, then its checks | Kind serial, ended, scanned 3; `GET checks?session_id=…` gives its 3 checks |

**Fixed, test first (TC-MIG-061).**
- **What:** serials that differ only by leading zeros are now one serial in the app, as on the server. The first one typed is kept as typed and sent once (`sameSerial`, `distinctSerials`, used by the stack parser and the repository).
- **Before:** the tests failed, as the app sent `001` and `1`.
- **After:** the checker's second run gives `001, 1` → one row `001`, shown.
- **Count:** for `001, 1` it reads "1 of 50 serials · 1 repeated, sent once".

The rule is asked of the backend (B5); if it ever compares text, the app changes back.

**Real-answer tests** (`test/staging/step6_stack_test.dart`, TC-STG-031 … -034):
- the real stack of three;
- `001, 1` sent once, with the real one-row answer shown;
- the real 400 for 51 serials;
- the stack's checks in History by session.

**On the emulator** (TC-STG-035): passed.
- **`001 1`:** the count read "1 of 50 serials · 1 repeated, sent once"; one row `001`, "Genuine, needs attention", checked before; Scanned 1.
- **`1, 1000001, 1234567890`:** checked before, not in a batch, not found, in that order; Scanned 3, Warning 1, Not found 1, Not in a batch 1.
- **Build:** the first rebuild had failed unnoticed (run beside the checker) and the old app showed "2 of 50 serials"; the rebuilt app shows the fix.
- The emulator itself crashed (exit 139) before "View this session's checks" was tapped; that link is covered by TC-STG-034.
