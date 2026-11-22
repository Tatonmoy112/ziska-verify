# STG: Integration with the backend's test server

| Field | Value |
|---|---|
| Spec | final.md §17 (environments), §15 (contract); app API guide |
| Server | `https://testapp.protecb.com`, client `ziska-test` (the staging build, `config/staging.json`) |
| Automated in | `test/staging/` (the server's real answers, saved by `tool/staging_check` and replayed offline from `test/fixtures/staging/`), `test/app/config/app_config_test.dart` |
| Record | [staging-integration-2026-11-22.md](../staging-integration-2026-11-22.md) |
| Format | [Case format and type tags](README.md#3-case-format) |

The integration runs one step at a time. For each step, the cases come first (normal, edge, worst), then the checker against the server, then tests on its real answers, then the screens on the emulator.

## Step 1. Connection and errors

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-001 | The public roles as the server sends them | POS | P1 | AUTO | ✅ `staging/step1_connection_test` | The server's real `roles/requestable` answer | Read it with the app's Sign up service | Distributor (2) and Retail seller (1), in the server's order | Guide §3.9 |
| TC-STG-002 | A route needing a login, asked without one | NEG | P1 | AUTO | ✅ `staging/step1_connection_test` | The server's real `401` answer for `formats` | Read it with the app's client | "Not logged in" (`unauthenticated`), status 401, with its reference | Guide §1 |
| TC-STG-003 | An unknown route | NEG | P2 | AUTO | ✅ `staging/step1_connection_test` | The server's real `404` answer | Read it with the app's client | "Not available" (`not_found`) with its reference | Guide §1 |
| TC-STG-004 | Sign up offers the server's roles | POS | P1 | AUTO | ✅ `staging/step1_connection_test` | The real roles answer through the whole app | Login → Sign up → open the role list | Distributor and Retail seller offered | Guide §3.9 |
| TC-STG-005 | The server address: host alone, https | WORST | P1 | AUTO | ✅ `app/config/app_config_test` | `API_BASE_URL` as the whole API address, with a path, a query, a fragment, a login, a placeholder, no scheme; with spaces, two slashes, capitals, a port | Start a build | The whole API address refused with a message naming the host to use and `CLIENT_SLUG`; the other bad ones refused; the good ones read as `https://host[:port]` | final.md §12.1, §17 |
| TC-STG-006 | The client name | WORST | P1 | AUTO | ✅ `app/config/app_config_test` | `CLIENT_SLUG` `ziska-test`, `ziska`; then with capitals, a space, `/`, `_`, a leading `-`, empty, a placeholder; with surrounding spaces | Start a build | Lower-case letters, digits and `-` accepted (spaces around removed); the rest refused at start (the server answers 404 for any other name) | Backend review 2026-11-18 |
| TC-STG-007 | The staging app on a phone reaches the server | E2E | P1 | DEVICE | ✋ | Staging build on the emulator or a phone | Open the app; Login → Sign up | Login shows; Sign up's role list comes from the server (Distributor, Retail seller) | final.md §17 |

## Step 2. Login and staying logged in

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-008 | A new phone: login, the emailed code, in | POS | P1 | AUTO | ✅ `staging/step2_login_session_test` | The server's real answers: login `code_sent`, verify-phone `logged_in`, `me`, `formats` | Log in; enter the code | The login sends email, password and phone ID only; the code goes with the server's challenge and the same phone ID; both passes stored; the Check tab with the official's name | Guide §3.1, §3.2 |
| TC-STG-009 | A trusted phone logs in without a code | POS | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real `logged_in` answer of a login on a trusted phone | Log in | Straight in: no code screen, no verify-phone | Guide §3.1 |
| TC-STG-010 | Renewal with the real answer | STATE | P1 | AUTO | ✅ `staging/step2_login_session_test` | A request answering `token_expired`; the real `auth/refresh` answer | Open History | One renewal; both new passes stored; the request sent once more with the new pass | Guide §3.4 |
| TC-STG-011 | Logout as the server accepts it | NET | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real logout answers: bare → 200, empty JSON body → `400 validation_failed` | Log out | Sent with no body and no type; Login; passes deleted, the phone ID kept; the 400 read as a validation error | Guide §3.5; data-flow Q4 |
| TC-STG-012 | A used refresh pass is refused | WORST | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real `401` for a refresh pass already used | A request expires | Login; passes deleted; the phone ID kept | Guide §3.4 |
| TC-STG-013 | A pass ended elsewhere | WORST | P1 | AUTO | ✅ `staging/step2_login_session_test` | The real `401` after a logout | Open History | Login | Guide §3.3 |
| TC-STG-014 | Login, restart, logout and login again on a phone | E2E | P1 | DEVICE | ✋ | Staging build on the emulator or a phone; the test login; its inbox | Log in (code from the email); close and reopen the app; log out; log in again | In with the code; still in after the restart (the server's name and organisation shown); Login after logout; the next login needs no code | Guide §3 |

## Step 3. Profile and permissions

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-015 | Profile shows the server's profile | POS | P1 | AUTO | ✅ `staging/step3_profile_test` | The real `GET me` (name and email replaced): Supervisor, four permissions, organisation, support with both values `null`, no `password_change_pending` | Open Profile | Name, role, organisation, email; the four permissions by name; "Not set by your office"; no password reminder | Guide §3.8 |
| TC-STG-016 | A new account's counts | EDGE | P2 | AUTO | ✅ `staging/step3_profile_test` | The real empty `GET checks` (totals all 0) | Open Profile | 0, 0, 0: never blank, never the error | Guide §5 |
| TC-STG-017 | The tabs and tools the permissions open | ROLE | P1 | AUTO | ✅ `staging/step3_profile_test` | The real profile and empty lists | Look at Check; open History | Check, History and Profile tabs; the serial field, Scanner mode, Serial stack, Report incident and My reports; History opens without an error | Guide §4 |
| TC-STG-018 | Profile and tools on a phone | E2E | P1 | DEVICE | ✋ | Staging build, logged in with the test login | Open Profile; open Check and scroll | The server's name, role, organisation, email; counts 0; the four permissions; support not set; every tool on Check | Guide §3.8, §4 |

## Step 4. One check

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-019 | Genuine: every field as sent | POS | P1 | AUTO | ✅ `staging/step4_lookup_test` | The real `valid` answer for serial `1` (Napa Extra 500, batch ZT-2509-001, no picture) | Type `1`, Check | `{way: serial, value: 1}` sent; "Genuine product"; the reference; product, generic and short name, batch, made and expiry dates, masked code; "No picture for this product" | Guide §4.2 |
| TC-STG-020 | Checked before, in Bangladesh time | POS | P1 | AUTO | ✅ `staging/step4_lookup_test` | The real `warning` / `checked_before` answer, `last_at` written `…06:30:49.67778+00:00` | Type the serial, Check | "Genuine, needs attention"; check number 2; the last check on Nov 22, 2026 at 12:30 (Dhaka) | Guide §4.2; DEC-205 |
| TC-STG-021 | Not in a batch: no item | EDGE | P1 | AUTO | ✅ `staging/step4_lookup_test` | The real `unassigned` answer (only `ref` and `result`) | Type `1000001`, Check | "Not in a batch"; the reference; no error | Guide §4.2 |
| TC-STG-022 | Not found | NEG | P1 | AUTO | ✅ `staging/step4_lookup_test` | The real `not_found` answer | Type `1234567890`, Check | "Not found"; the reference; what was entered | Guide §4.2 |
| TC-STG-023 | A QR from the camera | POS | P1 | AUTO | ✅ `staging/step4_lookup_test` | The real `not_found` answer for a QR | Show the link `https://www.ziskaverify.com/q/Q8F2KD91XA7M` to the camera | `{way: qr, value: Q8F2KD91XA7M}` sent; "Not found" | Guide §4 |
| TC-STG-024 | What the app never sends | NEG | P3 | AUTO | ✅ `staging/step4_lookup_test` | The real answers: the hidden-code way → 400; letters in a serial → 200 `not_found` | Read them | The 400 is a validation error with its reference; the 200 is read as not found (the app refuses letters before sending) | Guide §4; B5 |
| TC-STG-025 | One check of each result on a phone | E2E | P1 | DEVICE | ✋ | Staging build, logged in; serials `1`, `1000001`, `1234567890` | Check each | Genuine (or checked before, once checked), not in a batch, not found: each with the server's reference and fields; the loader while it waits | Guide §4.2 |

## Step 5. History and the sessions list

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-026 | The real first page | POS | P1 | AUTO | ✅ `staging/step5_history_test` | The real first page: 13 checks, totals 1 / 2 / 5 / 5 (the official's name replaced) | Open History | The chip counts 13, 1, 2, 5, 5; a not-found row titled by its reference; "Checked by …"; the newest at 12:36 PM (Dhaka) | Guide §5 |
| TC-STG-027 | The real pages and cursors | STATE | P1 | AUTO | ✅ `staging/step5_history_test` | The real pages of 5 (cursors `9`, `4`, then none) | Scroll to the end | Cursors sent as text in order: none, `9`, `4`; the oldest check reached; no error | Guide §5 |
| TC-STG-028 | A serial search: the tracking log | POS | P1 | AUTO | ✅ `staging/step5_history_test` | The real answer to `search=1` (3 checks) | Search `1` | The tracking log of serial 1, "Your checks of serial 1" read by TalkBack, the product | Guide §5; final.md §13.4 |
| TC-STG-029 | No sessions yet | EDGE | P2 | AUTO | ✅ `staging/step5_history_test` | The real empty sessions list | History → Sessions | "No sessions found."; one request | Guide §4.5 |
| TC-STG-030 | History on a phone | E2E | P1 | DEVICE | ✋ | Staging build, logged in, with checks made | History; Valid; Sessions | The server's checks newest first with counts, time and "Checked by"; Valid shows only the genuine ones; Sessions empty until a session exists | Guide §5, §4.5 |

## Step 6. Serial stacks

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-031 | The real stack of three | POS | P1 | AUTO | ✅ `staging/step6_stack_test` | The real answer for `1, 1000001, 1234567890` | Send the stack | Sent as typed; a row for each serial as sent; "Scanned: 3" | Guide §4.7 |
| TC-STG-032 | `001` and `1` on the real server | EDGE | P1 | AUTO | ✅ `staging/step6_stack_test` | The real answer: one row, `001` (the server takes them for one serial) | Type `001, 1`; send | "1 of 50 serials · 1 repeated, sent once"; `001` sent once; its row shown, never "cannot be shown" | Test server; B5 |
| TC-STG-033 | 51 serials | NEG | P2 | AUTO | ✅ `staging/step6_stack_test` | The real 400 for 51 serials | Read it | A validation error (the app refuses 51 before sending) | Guide §4.7 |
| TC-STG-034 | The stack in History | POS | P2 | AUTO | ✅ `staging/step6_stack_test` | The real stack and its session's checks | Send; View this session's checks | The checks by `session_id`; "Session checks" with the stack's serials | Guide §4.5, §4.7 |
| TC-STG-035 | A stack on a phone | E2E | P1 | DEVICE | ✋ | Staging build, logged in | Serial stack: `1, 1000001, 1234567890`; then `001, 1` | Each row's result; "Scanned: 3"; `001, 1` counted as one and its row shown | Guide §4.7 |

## Step 7. Scanner sessions

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-036 | Real scans in a session | POS | P1 | AUTO | ✅ `staging/step7_scan_test` | The real answers to QR A, QR B, then QR A again | Scan them; Finish | One session for all three; the repeat says "Already scanned" with the first scan's reference; Scanned 2, Not found 2, Remaining 4998; "2 products scanned"; the end sent once | Guide §4.3, §4.4 |
| TC-STG-037 | A real answer for another session | WORST | P1 | AUTO | ✅ `staging/step7_scan_test` | The real scan answer, with the checker's session | Scan in another session | Refused (`session_mismatch`), never counted | Guide §4.3 |
| TC-STG-038 | The real `session_ended` | NET | P1 | AUTO | ✅ `staging/step7_scan_test` | The real 409, the real answer in a new session | Scan in an ended session | A new session, the scan sent again in it, nothing asked; the real 404 and both real summaries read | Guide §4.3, §4.5 |
| TC-STG-039 | After a crash, the real saved session | WORST | P1 | AUTO | ✅ `staging/step7_scan_test` | The real summary (open, ended) or 404, and the real checks | Open Scanner mode with the session saved | Open: its totals and its two scans back, the next scan in it. Ended or 404: a new session | Guide §4.6 |
| TC-STG-040 | Scanner mode on a phone | E2E | P1 | DEVICE | ✋ | Staging build, logged in; the checker's sessions on the server | Open Scanner mode; Back; History → Sessions; open a session | The camera, the frame, counters at 0, Finish off; the sessions with their counts; a session's checks | Guide §4.3, §4.5 |

## Step 8. Reports, photos and retail users

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-041 | A report and its photo on the real answers | POS | P1 | AUTO | ✅ `staging/step8_report_test` | The real 201s for a report and its first photo | File a note with spaces around it and a photo | The note sent trimmed; "Report 3 filed."; "Photo 1"; the photo sent as `image/jpeg` | Guide §6.1, §6.2 |
| TC-STG-042 | The real 404s on filing | NEG | P1 | AUTO | ✅ `staging/step8_report_test` | The real "Check not found." and "Retail user not found." | File | Each names what is gone | Guide §6.1 |
| TC-STG-043 | The real refusals of a photo | NEG | P1 | AUTO | ✅ `staging/step8_report_test` | The real 409 for a 4th photo; the real 400s, 415 and 404 | Add the photo; read each answer | "The report has 3 photos already." with its reference, the report not filed again; every refusal of its kind | Guide §6.2 |
| TC-STG-044 | My reports from the real list | POS | P1 | AUTO | ✅ `staging/step8_report_test` | The real list of three reports | Open My reports; open the newest | Newest first; "3 photos", the check, the whole note of 1,000 characters | Guide §6.3 |
| TC-STG-045 | The picker with the real empty list | EDGE | P2 | AUTO | ✅ `staging/step8_report_test` | The server has no retail users | Open the picker; search | "No retail user found", before and after a search | Guide §7.1 |
| TC-STG-046 | A report on a phone | E2E | P1 | DEVICE | ✋ | Staging build, logged in | Note with spaces around it; link a check; the picker; a camera photo; file; My reports | The counter leaves out the spaces; the picker empty; filed with its photo; My reports shows it with "1 photo" and its check | Guide §6, §7 |

## Step 9. Sign up

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-STG-047 | The real 401 for a used code | NEG | P1 | AUTO | ✅ `staging/step9_signup_test` | The server's real answer to a code already used | Send the request | "The code is wrong or expired…"; the code step stays, with "Send a new code"; not "Thanks for signing up" | Guide §3.9 |
| TC-STG-048 | The real 404 "Role not found." | NEG | P2 | AUTO | ✅ `staging/step9_signup_test` | The real 404 | Send the request | "This role is no longer available. Choose another role." | Guide §3.9 |
| TC-STG-049 | The real 400s for a name | NEG | P2 | AUTO | ✅ `staging/step9_signup_test` | The real 400s for 101 letters, and for 99 letters and an emoji | Read them | Validation errors (the app refuses both before sending: TC-MIG-065) | Guide §3.9; B5 |
| TC-STG-050 | Sign up on a phone | E2E | P1 | DEVICE | ✋ | Staging build, logged out; a new address; its emailed code | Fill the form; Send code; type the code; Sign up | "A code was sent to the address."; then "Thanks for signing up. Your request was sent…" | Guide §3.9 |
