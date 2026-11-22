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
| 7 | Scanner sessions | **Done** 2026-11-22 |
| 8 | Reports, photos, retail users | **Done** 2026-11-22 |
| 9 | Sign up | **Done** 2026-11-22 |
| 10 | Password reset and change | **Done** 2026-11-22 |
| 11 | Records | **Done** 2026-11-22 |

## Summary (2026-11-22)

All 11 steps are done. Every area of the app ran against the real server through the app's own services and parsers; the server's answers are kept as fixtures and replayed offline in `test/staging/` (TC-STG-001 … -054).

**What the server changed in the app** (each fixed test first):

| Step | Fix | Commit |
|---|---|---|
| 1 | The address: `API_BASE_URL` takes the host alone; a path, query, login or placeholder is refused with the host to use; the slug is checked | f29ec20 |
| 3 | Text the server sends empty or as spaces (organisation, support, name) counts as not set | 1e88cdb |
| 6 | Serials that differ only by leading zeros are one serial, as the server counts them; the first typed is sent once | 5aacf99 |
| 8 | The spaces around a report's note do not count toward its 1,000; the retail-user search is cut at a whole character | 8915a54 |
| 9 | A sign-up name is kept within the server's 100 UTF-16 units; one helper (`TextLimits.fitUtf16`) for the name and the search | aaade9d |

Steps 2, 4, 5, 7 and 10 needed no app change. Step 5 added tests for gaps the app already handled (cb01e2b), and step 7 did the same (TC-MIG-062 … -064).

**Server rules not in the guide** (asked of the backend in B5):
- Serials are compared as numbers: `001` and `1` are one item.
- A serial with letters is accepted as `not_found`, alone or in a stack.
- A search and a sign-up name count characters in UTF-16 units (an emoji as two); a note and a password count code points.
- A new password may be the same as the current one (B3 item 5).

**What the server lacks for the remaining checks** (asked in B1):
- QR values of test items, so a scanner session can meet a found item.
- An item with a picture.
- A retail user. The sign-up request of step 9 ("Test Signup mobile app check", Retail seller) waits for the office; approving it gives one.

**Left for a second phone, or not sent on purpose:**
- **A second phone:** another phone logged out by a change or a reset; `session_not_yours`.
- **Limits not hit on a shared server:** `session_full` (5,000 items); 120 scans a minute; 50 reports an hour; 10 sign-ups an hour.
- **Lockouts of the test login:** 10 wrong reset codes an hour; more than 5 codes in 15 minutes.

All of these are covered offline.

**Left on the test server by these checks:**
- **Checks and sessions:** checks MA-2026-000001 … -000032, the sessions of steps 6 and 7, and the stacks.
- **Reports:** #1 … #4, three with photos.
- **Sign-up:** one sign-up request, pending.
- **The test login:** still logged in on the emulator; its password unchanged.

**Numbers:**
- 1312 automated tests pass (136 goldens).
- 757 of 885 cases are automated.
- 11 phone checks passed (TC-STG-007, -014, -018, -025, -030, -035, -040, -046, -050, -054, and TC-AUTH-063).

How to build, run and check against the server: `docs/run.md`, "The test server".

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

## Step 7. Scanner sessions (2026-11-22)

**Cases first.** Already covered (TC-MIG-012 … -054):
- one UUID per session, saved per official; repeats and camera frames counted once;
- `session_full` and `session_ended` roll over and send the scan again; `session_not_yours` starts anew;
- a 429 waits; two scans a second at most; Back ends without waiting; crash recovery; Finish.

**Gaps found and closed with tests** (the app already behaved; now it is pinned):
- **TC-MIG-062:** a saved session that has ended, is a stack, or answers 404 starts a new session, and the old one's checks are never read. With no connection, the ID is kept for the next try.
- **TC-MIG-063:** a `503` on a scan: "Scan again", nothing kept, nothing sent again by itself.
- **TC-MIG-064:** an end answered 404 or lost still leaves, and the ID is forgotten.

**Against the server** (the checker's `scan` step: a new UUID, QR values of the right format):

| Sent | Result |
|---|---|
| QR A (the first scan starts the session) | 200 `not_found`, ref MA-2026-000030, `repeat: false`; scanned 1, not found 1, `left: 4999` |
| QR B | 200 `not_found`; scanned 2, `left: 4998` |
| QR A again | `repeat: true`, **the first scan's ref**; scanned still 2 |
| `GET lookups/sessions/{id}` | kind `qr`, open, scanned 2 |
| `GET checks?session_id={id}` | 2 checks (the repeat added none), both `qr` |
| `POST …/end`, twice | 200 both times |
| `GET lookups/sessions/{id}` after the end | ended, scanned 2 |
| A scan in the ended session | 409 `session_ended` |
| The same QR in a new session | `repeat: false`, scanned 1: counted again |
| A serial in a session; a session ID that is not a UUID (sent raw) | 400 `validation_failed` |
| `GET` and `end` of an unknown session | 404 `not_found` |

All 18 checks passed: the server answers exactly as the guide says. Every answer went through the app's own parsers, and each answer's session matched the one sent.

**Not checked against the server:**
- **A found item in a session:** no QR value of a test item is known, so every scan was `not_found`. The QR values were requested in B1.
- **`session_not_yours`:** needs a second official.
- **`session_full`:** needs 5,000 items.
- **`429`:** needs more than 120 scans a minute; not sent to a shared server.

These are covered offline.

**Real-answer tests** (`test/staging/step7_scan_test.dart`, TC-STG-036 … -039):
- the real scans, the repeat and Finish in Scanner mode;
- a real answer for another session refused;
- the real `session_ended` rolled over without asking, and the real 404;
- recovery after a crash from the real summaries and checks.

**On the emulator** (TC-STG-040): passed.
- **Scanner mode:** the camera, the frame, five counters at 0, Finish off. The emulator's camera cannot read a QR, so no scan was made on the phone; QR posters in its virtual scene were out of the camera's view.
- **Sessions:** the checker's two scanner sessions, ended, with 1 and 2 scanned, under the stack of step 6.
- **Session checks:** MA-2026-000031 and -000030, "QR code · Session 4A7A81BB".
- **The emulator crashed twice** (exit 139) while opening Session checks. A third run, with the phone's log recording, opened it cleanly. The log showed the camera closed when the Check tab was left and not opened again, so the app was not at fault; the log showed heavy memory pressure.

## Step 8. Reports, photos and retail users (2026-11-22)

**Cases first.** Already covered (TC-REP-001 … -060, the picker, My reports):
- the note's length, in code points; filing once, a lost answer never filed again;
- photos one at a time, three at most, the hour, 2,048 px and 1 MB, the same photo twice;
- every refusal while filing or adding a photo; My reports and its pages; the picker's search, pages and waits.

**Gaps found, tests first:**
- **TC-REP-061:** no test said the note goes trimmed. It did; now it is pinned.
- **TC-REP-062 (fixed):** the guide removes the spaces around a note *before* counting its 1,000 characters. The field counted them, so a 1,000-character note pasted with a space before it lost its last character. The tests failed; the field now leaves the spaces around the note out of the limit and the counter (`CodePointLimit(outerSpaceFree: true)`).
- **TC-REP-063 (fixed):** the retail-user search was cut at 100 UTF-16 units with `substring`, which could cut an emoji in half. The domain service had no test at all; it now has one, and the search is cut at whole characters.

**Against the server** (the checker's `report` step):

| Sent | Result |
|---|---|
| A note of spaces only; a note of 1,001 characters | 400 `validation_failed`; nothing filed |
| An unknown check; an unknown retail user | 404 "Check not found."; 404 "Retail user not found."; nothing filed |
| A note of exactly 1,000 characters, sent with spaces and a line break around it, about one of this official's checks | **201**: the server removes the spaces before counting (the rule of TC-REP-062) |
| Photo 1: a JPEG of 2048 × 1536 at quality 85 (210 KB) | 201, `n: 1` |
| The same photo again | 201, `n: 1`: not counted twice |
| Text sent as a JPEG; an empty photo; 1 MB + 1 byte; a WebP type | 400 "The file is not a JPEG or PNG photo."; 400 "The photo is empty."; 400 "The photo must be at most 1 MB."; 415 |
| A photo for an unknown report | 404 "Report not found." |
| Photo 2 (a PNG), photo 3 (a JPEG) | 201, `n: 2`, `n: 3` |
| A 4th photo | 409 "The report has 3 photos already." |
| `GET incidents` | the new report first: the note trimmed (1,000 characters), 3 photos, the check, no retail user |
| `GET incidents?limit=1`, then its cursor | `next_cursor` given; the next page holds the others |
| `GET incidents?sort=old` | 400 |
| `GET retail-users` (none, `a`, 100 characters, `"  rahim  "`) | 200, **no retail users on the server** |
| A search of 101 characters (raw) | 400 |

All 28 checks passed.

The first run had 2 failures:
- **The 4th photo:** the checker sent photo 3's file again, and the server rightly answered its `n` once more. The checker now sends a new photo.
- **A search of 99 letters and an emoji was refused (400).**

**How the server counts characters** (the checker's `lengths` step):

| Search sent | Code points | UTF-16 units | UTF-8 bytes | Answer |
|---|---|---|---|---|
| 100 letters | 100 | 100 | 100 | 200 |
| 98 letters and an emoji | 99 | 100 | 102 | 200 |
| 99 letters and an emoji | 100 | 101 | 103 | **400** |
| 100 "é" | 100 | 100 | 200 | 200 |
| 50 emoji | 50 | 100 | 200 | 200 |

The search counts **UTF-16 units**. A note of an emoji and 999 letters (1,000 code points, 1,001 units) was **filed** (report 2): the note counts code points, as the app does. The app now keeps a search within 100 units, cut at a whole character, so it passes whichever way the server counts (TC-REP-063). The difference is asked of the backend (B5, item 3).

**Reports on the test server** (all by the test login, 2026-11-22):
- **#1:** the checker's first run, with 3 photos.
- **#2:** the emoji note of the length check, no photos.
- **#3:** the checker's second run, with 3 photos.
- **#4:** filed from the phone, with 1 photo.

**Not checked against the server:**
- **The picker with retail users in it:** the server has none (asked in B1).
- **Photos after the hour; 50 reports an hour:** these need an hour or 50 reports.

These are covered offline.

**Real-answer tests** (`test/staging/step8_report_test.dart`, TC-STG-041 … -045):
- a report and its photo;
- the real 404s while filing, each naming what is gone;
- the real 409 for a 4th photo with its reference, and every real refusal mapped to its kind;
- My reports from the real list;
- the picker with the real empty list.

**On the emulator** (TC-STG-046): passed.
- **The note:** "Test from the phone: seal cut.", typed with two spaces before and after, counted 30/1000.
- **The picker:** "No retail user found".
- **The check:** MA-2026-000031 linked.
- **The photo:** taken with the emulator's camera.
- **Filing:** "Report 4 filed.", "Photo 1".
- **My reports:** #4 first, with "1 photo" and its check, then #3, #2 and #1.

## Step 9. Sign up (2026-11-22)

**Cases first.** Already covered (TC-MIG-005 … -011, -033, -042, -044, the access-request tests):
- the form before the code; no login sent; no roles means "Ask the office";
- an email edit needs a new code; a 401 keeps the code step; a 409 uses the code up;
- one request at a time; the code and the request wait apart after a 429; a 404 for the role.

**Against the server, first: how it checks a request.** These used an `example.com` address that was sent no code, and a wrong code. The server checks the form before the code, so a form it takes answers 401 and nothing is filed or mailed.

| Sent | Answer | Meaning |
|---|---|---|
| A name of 101 letters | 400 | The form is checked before the code |
| A name of 99 letters and an emoji (100 code points, 101 units) | **400** | The name counts **UTF-16 units**, like the search (step 8) |
| A password of 128 code points ending in an emoji (129 units) | 401 | The password counts code points, as the app does |
| A password of Bangla letters and Bangla digits only | 401 | Any script's letters and digits count, as the app does |
| A role not offered | 404 "Role not found." | Checked before the code |

**Fixed, test first.** The app counted the name in code points; the field (Flutter's `maxLength`) counted what shows on screen. A name with an emoji at its end, 100 characters on screen, went to the server and was refused.
- **TC-MIG-065:** the app's own check now counts UTF-16 units, so such a name is refused before sending.
- **TC-MIG-066:** the field stops at 100 units, at a whole character.
- **One rule in one place:** `TextLimits.fitUtf16` now serves the name and the retail-user search of step 8.

**The real request, from the app** (on the emulator):
- **The form:** "Test Signup mobile app check", role Retail seller, a random password (never written down), a `+signup` address of the test inbox.
- **Send code:** "A code was sent to the address."; the code came by email.
- **Sign up:** "Thanks for signing up. Your request was sent. You will get an email when it is answered."

The request is **pending with the office**. Approving it would give the server the retail user step 8 lacked (B1).

**The code is used up:** the same code sent again by the checker answered 401 "Authentication required.", twice. A 200 uses the code up, as the guide says.

**Not checked against the server:**
- **409** (too many requests waiting) needs many requests.
- **429** needs more than 10 requests an hour.

Both are covered offline. This step used 8 of the 10 requests an hour allowed from one network address.

**Real-answer tests** (`test/staging/step9_signup_test.dart`, TC-STG-047 … -049):
- the real 401 for a used code keeps the code step;
- the real 404 asks for another role;
- the real 400s for a name are validation errors.

**On the emulator** (TC-STG-050): passed, as above. All three password hints were met before Send code was enabled.

The emulator's build showed a "28/100" counter under the name, added by mistake with the fix; the golden tests caught it (the Sign up design has none) and it was removed before committing.

## Step 10. Password reset and change (2026-11-22)

**Cases first.** Already covered (TC-AUTH-013 … -021, -055 … -102):
- the rule, ticked live, in characters, any alphabet, no control characters, 8 to 128;
- a wrong current password keeps the login; the new access pass is used, the refresh pass kept; one press, one change; offline;
- forgot always confirms; a wrong, expired or used reset code; the server refusing the new password; back to Login after a reset.

No gap was found. The manual cases this step could close on the server:
- **TC-AUTH-063:** may a new password be the same as the current one?
- **TC-AUTH-080:** a reset ends every login.

**Against the server, first what changes nothing** (the checker's `password-probe` step):

| Sent | Answer | Meaning |
|---|---|---|
| A change with a wrong current password | 401; `GET me` still 200 | Still logged in, as the guide says |
| A change with a wrong current password and a weak new one | 401 | The current password is checked before the rule |
| Forgot, for an address with no account | 200 | The same answer as for an account |
| A reset with a wrong code (that address) | 401 | |
| A reset with a wrong code and a weak password | 403 | The rule is checked before the code |

**Then on the phone.** The owner chose to keep the test login's password: each change went to the same password, so the login is as before.
1. **Forgot password:** "Reset password", "If … has an account, a code was sent to it." The emailed code and the same password; **back to Login**: the server took the current password as the new one (TC-AUTH-063; backend B3 item 5 noted).
2. **Login:** the password worked, and the app asked for an emailed code. The phone had been trusted since step 2, so **the reset forgot it**, as the guide says (half of TC-AUTH-080; the other half needs a second phone logged in at the time).
3. **The code:** logged in.
4. **Change password, a wrong current password:** "The current password is incorrect." with the server's reference; still logged in (TC-AUTH-019).
5. **Change password, the right one** (to the same password): saved; back on Profile, still logged in; History loaded with the new access pass (TC-AUTH-066).

**Not checked against the server:**
- **Another phone logged out by a change or a reset:** needs a second phone logged in.
- **10 wrong reset codes in an hour (TC-AUTH-052):** would close the test login's reset for 15 minutes.
- **More than 5 codes in 15 minutes (TC-AUTH-082):** would stop the test login's codes for a while.

The app side of each is covered offline.

**Real-answer tests** (`test/staging/step10_password_test.dart`, TC-STG-051 … -053):
- the real 401 for a wrong current password: said so, still logged in;
- the real forgot, then the real 401 of a wrong reset code: the code step stays;
- the real 403 of a reset password: the rules shown.

**On the emulator** (TC-STG-054): passed, as above. Two emailed codes were pasted by the owner: the reset's and the login's.
