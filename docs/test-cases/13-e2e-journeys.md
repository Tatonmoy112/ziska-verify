# E2E: End-to-End Journeys

> **2026-11-16 baseline:** [16-mobile-migration.md](16-mobile-migration.md) replaces conflicting cases for hidden-code input, bulk submission, everyone scope, retail administration, certificates, and email-only access requests. Historical IDs/counts below remain for traceability; do not execute retired cases as release requirements. Current architecture: ../../final.md.


> **Retired 2026-11-26 (production audit P-58):** TC-E2E-011 handed a retail user's first password over in person, after adding the user in the app; adding retail users is the office portal's (final.md §13.6). Its ID is not reused.

Each journey crosses several features in one session, as a real official would. The single steps are proved by their own cases; a journey proves they work together. Format: [README](README.md#3-case-format).

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-E2E-001 | Supervisor's day | E2E | P1 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R1 | Log in with a code; look up serial `1000001`; **Report incident** from the result with a photo; My reports; History: Filters, **Apply**, a serial search; no tile for adding retail users; log out | Each step as in its own cases; never the Login screen in between; Login at the end | §7, §13 |
| TC-E2E-002 | Field inspector's day | E2E | P1 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R2; fake scanner | Scan a QR; a serial stack of 3 serials; open a row; report from it; own History; log out | Each step as in its own cases | §7, §13 |
| TC-E2E-003 | Head office auditor's day | E2E | P2 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R3 | Look up (no Report button); History: Filters, **Apply**; item tracking of a serial, no `scope` sent; log out | Each step as in its own cases | §7, §13.4 |
| TC-E2E-004 | Senior seller's day | E2E | P2 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R4 | A serial stack of 3 serials; own History; Profile; log out | No reports or retail users anywhere | §7 |
| TC-E2E-005 | Retail seller's day | E2E | P1 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R5 | Look up serial `1000001`; back; own History; Profile; log out | The serial kept in the field after the result; own checks only, no `scope` sent | §7, §12 |
| TC-E2E-006 | Incident reporter's day | E2E | P2 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R6 | Report incident with a retail user picked; My reports; log out | Each step as in its own cases; no lookup anywhere | §7 |
| TC-E2E-007 | Trainee's day | E2E | P2 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R7 | Log in; Check tab; Profile; change the password; log out | "No features yet"; the change works | §7 |
| TC-E2E-008 | Retail seller without history | E2E | P2 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R8 | Log in; look up; log out | No History anywhere | §7 |
| TC-E2E-009 | A suspect item reported | E2E | P1 | STAGE | ✋ | Staging; an inspector login; the test sheet's `not_found` item | Look the item up; **Report incident** with 2 photos; open My reports; ask the office to open the report in the portal | My reports lists it with 2 photos and the reference; the office sees the same report and photos | §13.5 |
| TC-E2E-010 | A new retail user's first day | E2E | P1 | STAGE | ✋ | Staging; portal access; a second phone | The office adds the new retail user in the portal; on the phone the retail user logs in with the emailed first password; code; new password; looks up an item; opens History | Code screen, then the forced change, then Home; History lists that check only | §6, §13.6 |
| TC-E2E-012 | Login ends in the middle of a report | E2E | P1 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; R2 | Type a report note; File report; the renewal answers `401 unauthenticated`; log in again; open My reports | Login screen; after logging in, no report was filed; nothing filed twice | §6, §12 Duplicate protection |
| TC-E2E-013 | Connection lost along a journey | E2E | P2 | DEVICE | ✋ | Real phone; mock build | Serial stack → History → report; turn airplane mode on and off at each step | Each step shows its connection message and works again online; no check or report doubled | §15 |
| TC-E2E-014 | Forced change, then a normal day | E2E | P1 | AUTO | ✅ `flow/e2e_journeys_flow_test` | Fake backend; `must_change_password: true` | Log in; set a new password; look up; log out; log in again (`must_change_password: false`) | Set a new password, then Home; the second login goes straight to Home | §6, §9 |
| TC-E2E-015 | Blocked in the middle of the day | E2E | P2 | STAGE | ✋ | Staging; portal access | Logged in; the admin blocks the official; use the app; try to log in | Login at the next request; then "Email or password is incorrect." | §6 |
| TC-E2E-016 | Two phones, one official | E2E | P2 | STAGE | ✋ | Staging; phones A and B | Logged in on both; change the password on A; use B; log in on B with the new password | A stays logged in; B goes to Login; B logs in with the new password | §6 |
