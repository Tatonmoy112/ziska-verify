# ROLE and NAV: Permissions and Navigation

> **2026-11-16 baseline:** [16-mobile-migration.md](16-mobile-migration.md) replaces conflicting cases for hidden-code input, bulk submission, everyone scope, retail administration, certificates, and email-only access requests. Historical IDs/counts below remain for traceability; do not execute retired cases as release requirements. Current architecture: ../../final.md.


| Field | Value |
|---|---|
| Spec | final.md §7, §9.3–9.5, §13.7 |
| API | `GET me` (`permissions`) |
| Automated in | `test/flow/role_nav_flow_test.dart`, `main_shell_test`, `route_guard_test` |
| Format | [Case format and type tags](README.md#3-case-format) |


> **Retired 2026-11-26 (production audit P-55):** TC-ROLE-015 covered `history:all`, which the 2026-11-16 baseline removed. Its ID is not reused.

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
| TC-ROLE-010 | Duplicate permissions | EDGE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["item:lookup", "item:lookup", "item:bulk_lookup", "item:bulk_lookup"]` | Log in | One lookup form, one Scanner mode tile and one Serial stack tile | §7.2 |
| TC-ROLE-011 | Permission in capitals | EDGE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["ITEM:LOOKUP"]` | Log in | Treated as an unknown value: "No features yet", as R7 | §7.1, §15.1 |
| TC-ROLE-012 | Permissions missing or `null` | WORST | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `GET me` without `permissions`, then with `permissions: null` | Log in | Spec gap 9. No crash; no feature shown that the profile does not list | §7.2 |
| TC-ROLE-013 | `item:bulk_lookup` only | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["item:bulk_lookup"]` | Log in | Tabs Check, Profile; the Scanner mode and Serial stack tiles; no lookup form, no camera | §7.2, §13.7 |
| TC-ROLE-014 | History only | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["history:own"]` | Log in | Tabs Check, History, Profile; the Check tab shows the no-features empty state | §9.3.1, §13.7 |
| TC-ROLE-016 | A withdrawn permission only | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; `permissions: ["retail_user:add"]` (withdrawn: adding retail users is the office portal's) | Log in | The no-features state: no tile, no lookup form, no reports, no History | §13.7 |
| TC-ROLE-017 | Reporter without lookup picks a retail user | EDGE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R6 | **Report incident** → **Choose a retail user** | The picker lists retail users (`incident:report` opens `GET retail-users`) | §7.1, §13.6 |
| TC-ROLE-018 | Permission lost while on its screen | STATE | P1 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R2 | Open Serial stack; sending answers `403 forbidden`; the reloaded `GET me` no longer lists `item:bulk_lookup` | Profile reloaded; moved to the Check tab; the Serial stack tile gone | §7.2, §9.4 |
| TC-ROLE-019 | Permission gained | STATE | P2 | STAGE | ✋ | Staging; portal access | In the portal add `item:bulk_lookup` to the role; wait a minute; restart the app | The Scanner mode and Serial stack tiles appear (the profile loads at start, after login, and after a `403`) | §7.2 |
| TC-ROLE-020 | `403` while the profile still lists the permission | WORST | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R2 | Sending a serial stack answers `403 forbidden`; the reloaded `GET me` still lists `item:bulk_lookup` (the role change is not in effect yet) | One profile reload; an error shown; no loop of reloads or requests | §7.2, §12.1 API protection |
| TC-ROLE-021 | Each key grants its one capability | POS | P1 | AUTO | ✅ `features/profile/domain/permission_test` | `GET me` with each of `item:lookup`, `item:bulk_lookup`, `history:own`, `incident:report`, then all four | Map the profile | Each key becomes its `Permission` and opens only its own capability (`canLookup`, `canBulkLookup`, `canReadHistory`, `canReport`); all four open everything | §7 |
| TC-ROLE-022 | An empty or withdrawn set grants nothing | EDGE | P1 | AUTO | ✅ `features/profile/domain/permission_test` | `GET me` with no permission; with `history:all` and `retail_user:add`; a key twice; bulk only | Map the profile | No permission and no capability for the empty and withdrawn sets; a repeated key is one; bulk only can scan many but not one, nor read History | §7 |
| TC-ROLE-023 | A key not exactly the backend's grants nothing | WORST | P1 | AUTO | ✅ `features/profile/domain/permission_test` | Keys in upper or mixed case, with spaces or a line break, with a suffix, cut short, empty, two in one, unknown; and unknown keys beside `incident:report` | Map the profile | Each such key grants nothing; beside a real key, only the real one is kept | §7 |

## NAV — Navigation

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-NAV-001 | Tabs hidden by permission | POS | P1 | AUTO | ✅ `main_shell_test` | Fake backend | Profile without `history:*` | No History tab | §9.3.1 |
| TC-NAV-002 | A route without its permission goes Home | SEC | P1 | AUTO | ✅ `route_guard_test`, `main_shell_test` | Fake backend | Open `/history` without `history:*` | Check tab | §9.4, §18.3 Navigation |
| TC-NAV-003 | Every session state has its screen | STATE | P1 | AUTO | ✅ `route_guard_test` | Fake backend | Each guard row of §9.4 | The screen in the table | §9.4 |
| TC-NAV-004 | Tabs keep their state; tapping the current tab stays | STATE | P3 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Search on History; go to Check; back to History; tap History again | The search is still there; History stays open | §9.3.1 |
| TC-NAV-005 | Android back on a tab | POS | P2 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | On History, press back; on Check, press back | History → Check; Check → leaves the app | §9.3.1 |
| TC-NAV-006 | Profile shortcut on Check | POS | P3 | MOCK | ✅ `flow/role_nav_flow_test` | Mock build | Tap the user icon in the Check header | Profile tab | §13.7 |
| TC-NAV-007 | Role changed while logged in | STATE | P2 | STAGE | ✋ | Staging build, backend test sheet | Admin removes `history:own`; the official triggers a `403` | Profile reloads; History tab disappears | §7.2 |
| TC-NAV-008 | Result screen restored without its result | WORST | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend | Open `/home/result` without `extra` (as after a system restore) | The Check tab (the parent route) | §9.5 Missing extra |
| TC-NAV-009 | Deep links do not open the app | SEC | P2 | DEVICE | ✋ | Real phone | `adb shell am start -a android.intent.action.VIEW -d "https://www.ziskaverify.com/q/Q8F2KD91XA7M"`; then a link with the app's package scheme | The app is not offered or opened for either; the browser handles the website link | §9.5 Deep links |
| TC-NAV-010 | Back on every nested screen | STATE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R1 | Open and press Android back on: a result, Scanner mode, Serial stack, Report incident, My reports, Change password (from Profile) | Each returns to the screen it was opened from | §9.5 Back |
| TC-NAV-011 | Feature screens open above the bottom bar | STATE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; R1 | Open each Check tile (Scanner mode, Serial stack, Report incident, My reports); press back | No bottom bar on the feature screen; back shows the Check tab's first screen with the bar (so "tap the current tab on a nested screen" cannot happen) | §9.2, §9.3.1 |
| TC-NAV-012 | Android back on Profile | STATE | P3 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend | Open the Profile tab; press back | The Check tab | §9.3.1 |
| TC-NAV-013 | Pre-login routes after login | STATE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; logged in | Go to `/login`, `/forgot-password`, `/request-access`, `/splash` | Home each time | §9.4 |
| TC-NAV-014 | Feature route while logged out | STATE | P2 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend; logged out | Go to `/home/serial-stack` and `/history` | Login each time | §9.4 |
| TC-NAV-015 | Navigation log holds route names only | SEC | P1 | AUTO | ✅ `flow/roles_edge_flow_test` | Fake backend | Open a result (with `extra`), then Report incident with `check_ref`; read the logs | Route names only; no `check_ref`, no `extra` values | §9.5 Observer |
| TC-NAV-016 | The route table | POS | P2 | AUTO | ✅ `flow/route_table_flow_test` | The running app | Read the router's routes | Exactly the 16 named routes with their full paths (nested ones too), the flows above the tabs in their order, then the three tabs Check, History, Profile | §9; production audit P-6 |
| TC-NAV-017 | Parameters and a missing extra | EDGE | P2 | AUTO | ✅ `flow/route_table_flow_test` | The running app | Build a session's path; open Reset password logged out without its email; open the result page without a result | `/history/sessions/S-1`, an ID with a space or `/` encoded; Reset password goes back to Forgot password; the result page goes to Check | §9 |
| TC-NAV-018 | Links the role cannot open, or that are none | WORST | P1 | AUTO | ✅ `flow/route_table_flow_test` | Auditor (no `item:bulk_lookup`, no reports); retail seller without History; logged out | Open scanner mode, the stack, My reports, a new report, History, a session's checks; Profile logged out; an address the app does not have | Each gated link lands on Check; logged out lands on Login; an unknown address shows "Not available." and **Try again** leads back in | §7, §9 |
| TC-NAV-019 | Check opens New report and My reports | POS | P2 | AUTO | ✅ `flow/cross_feature_navigation_flow_test` | Supervisor | On Check tap New report, Back; tap My reports, Back | Each opens its page (`/home/reports/new`, `/home/reports`); the camera stops while it is open and runs again on Check after Back | §9, §13.10 |
| TC-NAV-020 | A result opens New report with its check | POS | P2 | AUTO | ✅ `flow/cross_feature_navigation_flow_test` | Supervisor; serial `1000001` | Check it; tap **Report a problem** | New report opens with `check_ref` the result's reference (`MA-YYYY-NNNNNN`), shown on the form | §9, §13.5 |
| TC-NAV-021 | No report permission; pages opened and closed in turn | WORST | P2 | AUTO | ✅ `flow/cross_feature_navigation_flow_test` | Auditor (no `incident:report`); supervisor | Look at Check and a result; open New report, Back, My reports, Back | No report tool and no report button without the permission; after the round, Check with its camera running, no error | §7, §9 |
| TC-NAV-022 | The guard names real routes only | POS | P2 | AUTO | ✅ `flow/route_table_flow_test` | The running app | Compare each path of the guard table (`tabPermissionByPath`) with the router's routes | Each is a route of the app, or the prefix of `/history/sessions/:id` | §9; production audit P-15 |
| TC-NAV-023 | Every page that needs a permission is guarded, and no other | EDGE | P2 | AUTO | ✅ `flow/route_table_flow_test` | — | Read the guard table | Exactly History, a session's checks, the result, scanner mode, the serial stack, My reports and a new report | §7, §9 |
| TC-NAV-024 | A removed route is not available to anyone | WORST | P2 | AUTO | ✅ `flow/route_table_flow_test` | A supervisor (with `item:lookup`); an incident reporter (without) | Open `/home/scan`, removed 2026-11-18 | "Not available." for both; no role is sent elsewhere by a guard left behind | §9 |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 9 (`permissions` missing or `null`).
