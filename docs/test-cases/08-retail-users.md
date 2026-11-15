# RTL: Retail Users

| Field | Value |
|---|---|
| Spec | final.md §13.6 |
| API | `GET retail-users`, `GET retail-roles`, `POST retail-users`, `POST retail-users/{id}/password` |
| Automated in | `test/flow/reports_retail_flow_test.dart`, `retail_user_admin_test` |
| Format | [Case format and type tags](README.md#3-case-format) |

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-RTL-001 | Entry only with `retail_user:add` | POS | P1 | MOCK | ✅ `flow/reports_retail_flow_test` | Mock build | Verify tab as R1, then R2 | R1 has the Retail users tile; R2 does not | §13.6 |
| TC-RTL-002 | List and search | POS | P2 | MOCK | ✅ `flow/reports_retail_flow_test` | Mock build | Open Retail users; search | Rahim Store, `ra***@gmail.com` | §13.6 |
| TC-RTL-003 | No retail role yet | EDGE | P2 | MOCK | ✅ `retail_user_admin_test` | Mock build | **Add retail user** on the mock | "…no retail user can be added."; no form | §13.6 |
| TC-RTL-004 | Email the login details on by default | POS | P1 | AUTO + STAGE | ✅ `retail_user_admin_test` | Fake backend; Staging build, backend test sheet | Open the add form | Switch on | §13.6.1, build guide step 8 |
| TC-RTL-005 | Switch off: give the password yourself | POS | P1 | AUTO + STAGE | ✅ `retail_user_admin_test` | Fake backend; Staging build, backend test sheet | Turn the switch off; add | "Give the password to the retail user yourself." and the password shown once | §13.6.1 |
| TC-RTL-006 | Mail failed | NET | P2 | AUTO + STAGE | ✅ `retail_user_admin_test` | Fake backend; Staging build, backend test sheet | Add answered `email_sent: false` | Account made; mail failed text; password shown once | §13.6.1 |
| TC-RTL-007 | Email already used | NEG | P1 | AUTO + STAGE | ✅ `retail_user_admin_test` | Fake backend; Staging build, backend test sheet | Add with a used email | "An official with this email already exists." | §13.6 |
| TC-RTL-008 | Password forgotten after the screen | SEC | P1 | AUTO + MOCK | ✅ `retail_user_admin_test` | Fake backend; Mock build | **Add another**; or leave and come back | No password shown | §13.6.1 |
| TC-RTL-009 | Email a new first password | POS | P2 | MOCK | ✅ `flow/reports_retail_flow_test` | Mock build | Row menu → **Email a new first password** → **Email it** | "A new first password was emailed to Rahim Store." | §13.6 |
| TC-RTL-010 | Own password already set | NEG | P2 | STAGE | ✋ | Staging build, backend test sheet | Same, for a retail user who changed their password | "…has set their own password…" | §13.6 |
| TC-RTL-011 | Hourly limit | NET | P3 | STAGE | ✋ | Staging build, backend test sheet | Exceed 30 adds or emails in an hour | Countdown message; no crash | §13.6 |
| TC-RTL-012 | Name empty or over 100 characters | BVA | P1 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1, one retail role | Add retail user with an empty name; then 101 characters | Empty: **Add retail user** disabled; 101: the field stops at 100 or the form refuses it; never sent | §13.6.1 |
| TC-RTL-013 | Name of 1 and of 100 characters | BVA | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Name `R`; then 100 characters | Sent unchanged each time | §13.6.1 |
| TC-RTL-014 | Email that is not an address | NEG | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Email `rahim.store`, then `rahim@` | Not sent (spec gap 4 for the exact check) | §13.6.1 |
| TC-RTL-015 | Email in other capitals already used | EDGE | P3 | STAGE | ✋ | Staging build, backend test sheet | Add `Rahim.Store@Gmail.com` when `rahim.store@gmail.com` exists | Spec gap 4 | §13.6 |
| TC-RTL-016 | First password empty | NEG | P1 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Leave First password empty | Add retail user disabled | §13.6.1 |
| TC-RTL-017 | First password without the rule | BVA | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | First password `1`; then `abc` | Sent as typed; no password rules shown | §6.6, §13.6.1 |
| TC-RTL-018 | First password of 128 and 129 characters | BVA | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | 128 characters; then try a 129th | 128 sent; the 129th not accepted | §13.6.1 |
| TC-RTL-019 | First password with a control character | NEG | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Paste `abc<Tab>123` | Not sent | §13.6.1 |
| TC-RTL-020 | Several retail roles | POS | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1; `GET retail-roles` answers 2 roles | Open the form; choose the second role; add | Both offered; the chosen `role_id` sent | §13.6.1 |
| TC-RTL-021 | Role no longer a retail role | NEG | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Add answers `404 not_found` | "This role is no longer a retail role. Choose another." | §13.6.2 |
| TC-RTL-022 | One press, one account | WORST | P1 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1; slow answer | Tap **Add retail user** twice quickly | One `POST retail-users` | §13.6.2 |
| TC-RTL-023 | Adding rate limited | NET | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Add answers `429` with `Retry-After: 120` | "Too many attempts. Try again in 120 s." counting down | §13.6 |
| TC-RTL-024 | Adding offline | NET | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1; no connection | Fill the form; add | "No connection. Check the internet and try again."; no "was added" screen | §15.4 |
| TC-RTL-025 | `send_email` follows the switch | POS | P1 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Add with the switch on; then with it off | `send_email: true`; then `send_email: false` | §13.6.1 |
| TC-RTL-026 | Login details emailed | POS | P2 | AUTO | ✅ `flow/reports_retail_flow_test` | Fake backend; R1 | Add answers `email_sent: true` | "The login details were emailed to rahim.store@gmail.com."; no password shown | §13.6.1 |
| TC-RTL-027 | Copy the first password | POS | P3 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Add with the switch off; tap copy by the password | The clipboard holds the typed password | §13.6.2 |
| TC-RTL-028 | Retail roles fail to load | NET | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | `GET retail-roles` answers `500`; then **Try again** | "Something went wrong. Try again." with "Reference: …"; no form until the roles load | §14.2 |
| TC-RTL-029 | First password never logged | SEC | P1 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Add a retail user; read the logs | The typed first password appears nowhere in the logs | §12.2, §13.6.1 |
| TC-RTL-030 | First password not restored after the system closes the app | SEC | P2 | DEVICE | ✋ | Real phone; "Don't keep activities" on | Add with the switch off; leave the app; return | The password is not shown again | §13.6.1 |
| TC-RTL-031 | A new retail user can be picked at once | STATE | P2 | STAGE | ✋ | Staging build, backend test sheet | Add a retail user; Report incident → Choose a retail user; search the name | The new retail user is listed | API guide §7.3 |
| TC-RTL-032 | Email a new first password: Cancel | POS | P3 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Row menu → Email a new first password → **Cancel** | No request | §13.6.2 |
| TC-RTL-033 | Email a new first password: not found | NEG | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | The request answers `404 not_found` | "This retail user was not found or is blocked." | §13.6.2 |
| TC-RTL-034 | Email a new first password: rate limited | NET | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | The request answers `429` with `Retry-After: 120` | "Too many attempts. Try again in 120 s." counting down | §13.6 |
| TC-RTL-035 | Email a new first password: one press | WORST | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1; slow answer | Tap **Email it** twice quickly | One `POST retail-users/{id}/password` | §13.6 |
| TC-RTL-036 | The old first password stops working | STATE | P2 | STAGE | ✋ | Staging build, backend test sheet | Email a new first password; log in as that retail user with the old one | "Email or password is incorrect." | §13.6 |
| TC-RTL-037 | Retail users: next page | POS | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Page 1 with a cursor; scroll to the end | Page 2 with `cursor`; the end marker at `next_cursor: null` | §13.6.2, §10 |
| TC-RTL-038 | Search waits for typing to stop | POS | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Type `RAHIM` quickly | One request with `search=RAHIM`, 400 ms after the last key | §8.3, §13.6 |
| TC-RTL-039 | Search over 100 characters | BVA | P3 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Paste 101 characters into search | Never sent over 100 characters | §13.6.2 |
| TC-RTL-040 | No retail user matches | EDGE | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R2 | Picker search answered empty | "No retail user found" | §13.6 |
| TC-RTL-041 | Masked email of a short name | EDGE | P3 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | A retail user with `email: "r***@gmail.com"` | `r***@gmail.com` shown exactly | §13.6 |
| TC-RTL-042 | No retail users yet | EDGE | P3 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R1 | Open Retail users; the list is empty | "No retail user yet." | §13.6.2 |
| TC-RTL-043 | A new picker search starts again | STATE | P2 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R2 | Scroll the picker to page 2; type a new search | A new first page with no cursor | §13.6.2 |
| TC-RTL-044 | Picker offline | NET | P3 | AUTO | ✅ `flow/retail_edge_flow_test` | Fake backend; R2; no connection | Open the picker | "No connection. Check the internet and try again." and **Try again** | §10.4 |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 4 (email format and capitals).
