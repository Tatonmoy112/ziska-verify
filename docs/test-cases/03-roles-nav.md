# ROLE and NAV: Permissions and Navigation

| Field | Value |
|---|---|
| Spec | final.md §7, §9.3–9.5, §13.7 |
| API | `GET me` (`permissions`) |
| Automated in | `test/flow/role_nav_flow_test.dart`, `main_shell_test`, `route_guard_test` |
| Format | [Case format and type tags](README.md#3-case-format) |

## ROLE — Roles

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-ROLE-001 | Supervisor (R1) | POS | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Set the R1 profile; log in | As in [test-plan §7](../test-plan.md#7-roles), R1 | §7, §9.3.1 |
| TC-ROLE-002 | Field inspector (R2) | POS | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Default mock profile | As in [test-plan §7](../test-plan.md#7-roles), R2 | §7 |
| TC-ROLE-003 | Head office auditor (R3) | POS | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Set R3 | As in [test-plan §7](../test-plan.md#7-roles), R3 | §7 |
| TC-ROLE-004 | Senior seller (R4) | POS | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Set R4 | As in [test-plan §7](../test-plan.md#7-roles), R4 | §7 |
| TC-ROLE-005 | Retail seller (R5) | POS | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Set R5 | As in [test-plan §7](../test-plan.md#7-roles), R5 | §7 |
| TC-ROLE-006 | Incident reporter (R6) | POS | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Set R6 | As in [test-plan §7](../test-plan.md#7-roles), R6 | §7 |
| TC-ROLE-007 | Trainee (R7) | EDGE | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Set R7 | As in [test-plan §7](../test-plan.md#7-roles), R7 | §7.2 |
| TC-ROLE-008 | Retail seller with history off (R8) | EDGE | P1 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Set R8 | As in [test-plan §7](../test-plan.md#7-roles), R8: no History tab | §7.2 |
| TC-ROLE-009 | Unknown permission ignored | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["item:lookup", "report:everything"]` | Log in | As R8 (lookup form and Scan QR only); nothing else shown; no crash | §7.1, §15.1 |
| TC-ROLE-010 | Duplicate permissions | EDGE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["item:lookup", "item:lookup", "item:bulk_lookup", "item:bulk_lookup"]` | Log in | One lookup form and one Bulk lookup tile | §7.2 |
| TC-ROLE-011 | Permission in capitals | EDGE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["ITEM:LOOKUP"]` | Log in | Treated as an unknown value: "No features yet", as R7 | §7.1, §15.1 |
| TC-ROLE-012 | Permissions missing or `null` | WORST | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `GET me` without `permissions`, then with `permissions: null` | Log in | Spec gap 9. No crash; no feature shown that the profile does not list | §7.2 |
| TC-ROLE-013 | Bulk lookup only | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["item:bulk_lookup"]` | Log in | Tabs Verify, Profile; the Bulk lookup tile; no lookup form, no Scan QR | §7.2, §13.7 |
| TC-ROLE-014 | History only | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["history:own"]` | Log in | Tabs Verify, History, Profile; the Verify tab shows the no-features empty state | §9.3.1, §13.7 |
| TC-ROLE-015 | `history:all` without `history:own` | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["history:all"]` | Log in; open History; open Filters | History tab shown; "Everyone's checks" switch shown | §9.3.1, §13.4 |
| TC-ROLE-016 | Retail users only | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["retail_user:add"]` | Log in | The Retail users tile only; no lookup form, no reports, no History | §13.7 |
| TC-ROLE-017 | Reporter without lookup picks a retail user | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R6 | **Report incident** → **Choose a retail user** | The picker lists retail users (`incident:report` opens `GET retail-users`) | §7.1, §13.6 |
| TC-ROLE-018 | Permission lost while on its screen | STATE | P1 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R2 | Open Bulk lookup; a request answers `403 forbidden`; the reloaded `GET me` no longer lists `item:bulk_lookup` | Profile reloaded; moved to the Verify tab; the Bulk lookup tile gone | §7.2, §9.4 |
| TC-ROLE-019 | Permission gained | STATE | P2 | STAGE | ✋ | Staging; portal access | In the portal add `item:bulk_lookup` to the role; wait a minute; restart the app | The Bulk lookup tile appears (the profile loads at start, after login, and after a `403`) | §7.2 |
| TC-ROLE-020 | `403` while the profile still lists the permission | WORST | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R2 | Bulk send answers `403 forbidden`; the reloaded `GET me` still lists `item:bulk_lookup` (the role change is not in effect yet) | One profile reload; an error shown; no loop of reloads or requests | §7.2, §12.1 API protection |

## NAV — Navigation

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-NAV-001 | Tabs hidden by permission | POS | P1 | AUTO | ✅ `main_shell_test` | Fake backend | Profile without `history:*` | No History tab | §9.3.1 |
| TC-NAV-002 | A route without its permission goes Home | SEC | P1 | AUTO | ✅ `route_guard_test`, `main_shell_test` | Fake backend | Open `/history` without `history:*` | Verify tab | §9.4, §18.3 Navigation |
| TC-NAV-003 | Every session state has its screen | STATE | P1 | AUTO | ✅ `route_guard_test` | Fake backend | Each guard row of §9.4 | The screen in the table | §9.4 |
| TC-NAV-004 | Tabs keep their state; tapping the current tab stays | STATE | P3 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Search on History; go to Verify; back to History; tap History again | The search is still there; History stays open | §9.3.1 |
| TC-NAV-005 | Android back on a tab | POS | P2 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | On History, press back; on Verify, press back | History → Verify; Verify → leaves the app | §9.3.1 |
| TC-NAV-006 | Profile shortcut on Verify | POS | P3 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Tap the user icon in the Verify header | Profile tab | §13.7 |
| TC-NAV-007 | Role changed while logged in | STATE | P2 | STAGE | ✋ | Staging build, backend test sheet | Admin removes `history:own`; the official triggers a `403` | Profile reloads; History tab disappears | §7.2 |
| TC-NAV-008 | Result screen restored without its result | WORST | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend | Open `/home/result` without `extra` (as after a system restore) | The Verify tab (the parent route) | §9.5 Missing extra |
| TC-NAV-009 | Deep links do not open the app | SEC | P2 | DEVICE | ✋ | Real phone | `adb shell am start -a android.intent.action.VIEW -d "https://www.ziskaverify.com/q/Q8F2KD91XA7M"`; then a link with the app's package scheme | The app is not offered or opened for either; the browser handles the website link | §9.5 Deep links |
| TC-NAV-010 | Back on every nested screen | STATE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R1 | Open and press Android back on: Scan, Result, Bulk lookup, My reports, Report incident, Retail users, Change password (from Profile) | Each returns to the screen it was opened from | §9.5 Back |
| TC-NAV-011 | Feature screens open above the bottom bar | STATE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R1 | Open each Verify tile (Bulk lookup, Report incident, My reports, Retail users); press back | No bottom bar on the feature screen; back shows the Verify tab's first screen with the bar (so "tap the current tab on a nested screen" cannot happen) | §9.2, §9.3.1 |
| TC-NAV-012 | Android back on Profile | STATE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend | Open the Profile tab; press back | The Verify tab | §9.3.1 |
| TC-NAV-013 | Pre-login routes after login | STATE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; logged in | Go to `/login`, `/forgot-password`, `/request-access`, `/splash` | Home each time | §9.4 |
| TC-NAV-014 | Feature route while logged out | STATE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; logged out | Go to `/home/bulk-lookup` and `/history` | Login each time | §9.4 |
| TC-NAV-015 | Navigation log holds route names only | SEC | P1 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend | Open a result (with `extra`), then Report incident with `check_ref`; read the logs | Route names only; no `check_ref`, no `extra` values | §9.5 Observer |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 9 (`permissions` missing or `null`).
