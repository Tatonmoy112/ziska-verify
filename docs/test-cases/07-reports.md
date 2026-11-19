# REP: Reports and Photos

| Field | Value |
|---|---|
| Spec | final.md §13.5 |
| API | `POST incidents`, `POST incidents/{id}/photos`, `GET incidents` |
| Automated in | `test/flow/reports_retail_flow_test.dart`, `report_incident_bloc_test`, `incident_contract_test` |
| Format | [Case format and type tags](README.md#3-case-format) |

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-REP-001 | Report from a result carries the reference | POS | P1 | MOCK | ✅ `report_incident_bloc_test` | Mock build | Result → **Report incident** | The check row shows the reference; filed with `check_ref` | §13.5, §18.3 Reports |
| TC-REP-002 | Note is required | NEG | P2 | MOCK | ✅ `report_incident_bloc_test` | Mock build | Leave the note empty | **File report** disabled | §13.5.2 |
| TC-REP-003 | File a report | POS | P1 | MOCK | ✅ `flow/reports_retail_flow_test` | Mock build | Note, **File report** | "Report 1042 filed."; form locked; **Done** | §13.5 |
| TC-REP-004 | Filed once | WORST | P1 | AUTO | ✅ `report_incident_bloc_test` | Fake backend | Tap File report twice quickly | One `POST incidents` | §13.5.2 |
| TC-REP-005 | Photos sent one at a time after filing | POS | P1 | AUTO | ✅ `report_incident_bloc_test` | Fake backend | 2 photos, then file | Photo 1 then photo 2 sent; each shows "Photo n" | §13.5.1 |
| TC-REP-006 | Lost photo sent again, report not filed again | NET | P1 | AUTO + DEVICE | ✅ `report_incident_bloc_test` | Fake backend; Real phone | Airplane mode after filing; then back online; tap the failed photo | Photo sent; still one report | §13.5.1, §18.3 Reports |
| TC-REP-007 | Refused photo not offered again | NEG | P2 | AUTO | ✅ `report_incident_bloc_test` | Fake backend | Photo answered `400` | "This photo was refused."; no retry | §13.5.3 |
| TC-REP-008 | At most 3 photos | BVA | P2 | AUTO | ✅ `report_incident_bloc_test` | Fake backend | Add a 4th photo | The add tile disappears at 3 | §13.5.2 |
| TC-REP-009 | Nothing after one hour | BVA | P2 | AUTO | ✅ `report_incident_bloc_test` | Fake backend | Retry a photo after 61 minutes | Not sent; window message | §13.5.2 |
| TC-REP-010 | Photo is shrunk and has no metadata | SEC | P1 | DEVICE | ✋ | Real phone | Take a photo with location on; file; check the stored photo in the portal (or capture the request) | JPEG, longer side ≤ 2048 px, ≤ 1 MB, no EXIF (no location, time, phone model), upright | §13.5.2, §18.3 Photo metadata |
| TC-REP-011 | HEIC photo | COMPAT | P2 | DEVICE | ✋ | Real phone | iPhone or Android HEIC photo from the gallery | Accepted as JPEG | §13.5.2 |
| TC-REP-012 | Camera and gallery | POS | P1 | DEVICE | ✋ | Real phone | Add photo → Take a photo; → Choose from gallery | Both add a thumbnail | §13.5 |
| TC-REP-013 | Retail user picker | POS | P2 | MOCK | ✅ `flow/reports_retail_flow_test` | Mock build | **Choose a retail user**; search "rahim"; pick | "Rahim Store" linked; email shown masked in the list | §13.6 |
| TC-REP-014 | Remove links before filing | POS | P3 | MOCK | ✅ `flow/reports_retail_flow_test` | Mock build | Remove the check and the retail user (×) | Both cleared | §13.5 |
| TC-REP-015 | Filing on a lost connection | NET | P1 | DEVICE | ✋ | Real phone | Airplane mode; File report | "The connection dropped. The report may have been filed: check My reports…" | §13.5 App rules |
| TC-REP-016 | My reports | POS | P1 | MOCK | ✅ `incident_contract_test` | Mock build | Open My reports | #1042, time, note, "2 photos", reference, "Rahim Store" | §13.5.4, build guide step 7 |
| TC-REP-017 | New report from My reports | POS | P3 | MOCK | ✅ `flow/reports_retail_flow_test` | Mock build | **New report**; file; back | Report screen; My reports refreshes on return | §13.5 |
| TC-REP-018 | Note of 1 character | BVA | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Note `x`; **File report** | Filed with `note: "x"` | §13.5.2 |
| TC-REP-019 | Note of 1 000 characters | BVA | P1 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | A 1 000-character note; File report | Filed with all 1 000 characters | §13.5.2 |
| TC-REP-020 | Note over 1 000 characters | BVA | P1 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Type or paste 1 001 characters | The field stops at 1 000, or File report stays disabled; never sent over 1 000 | §13.5.2 |
| TC-REP-021 | Note of spaces only | NEG | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Note `   ` | File report disabled (the server removes the spaces around a note) | §13.5.2, API guide §6.1 |
| TC-REP-022 | Note in Bangla with emoji | I18N | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Note `লেবেল ঝাপসা 😟` | Sent unchanged | §13.5.2 |
| TC-REP-023 | Note with line breaks | EDGE | P3 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | A note of three lines | Sent with its line breaks; the answer decides | §13.5.2 |
| TC-REP-024 | Report about nothing linked | POS | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Check tab → **Report incident**; note only; File report | `POST incidents` with the note; no `check_ref` and no `retail_user_id` (or both `null`) | §13.5 |
| TC-REP-025 | Linked check or retail user not found | NEG | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Filing answers `404 not_found` | "The check or the retail user was not found. Remove it and try again." | §13.5 Filing failure |
| TC-REP-026 | Filing rate limited | NET | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Filing answers `429` with `Retry-After: 60` | "Too many attempts. Try again in 60 s." counting down; File report sends nothing until 0 | §13.5.2 |
| TC-REP-027 | Filing answered 500 or 503 | NET | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | `500`, then `503 service_unavailable` | An error with its reference; the report is not filed again by itself | §12.1 Duplicate protection, §15.4 |
| TC-REP-028 | App closed after filing, before the photos | WORST | P1 | DEVICE | ✋ | Real phone; mock or staging | Add 2 photos; File report; close the app as soon as "Report N filed." shows; open it; open My reports | The report is listed once, with the photos that arrived; nothing is sent by itself (nothing is queued on the phone) | §12.1 Local data, §13.5.2 |
| TC-REP-029 | Photo of exactly 1 MB and of 1 MB + 1 byte | BVA | P1 | AUTO | ✅ `photo_limit_test`, `flow/reports_edge_flow_test` | Fake backend; fake photo service | The prepared photo is 1 048 576 bytes; then 1 048 577 bytes | The first is sent; the second shows "This photo is too large even after shrinking." and is not sent | §13.5.2 |
| TC-REP-030 | PNG photo | EDGE | P2 | DEVICE | ✋ | Real phone | Choose a PNG from the gallery; file | Sent and counted on the report | §13.5.2 |
| TC-REP-031 | Photo that cannot be read | NEG | P2 | AUTO | ✅ `photo_limit_test`, `flow/reports_edge_flow_test` | Fake backend; the photo service fails on the file | Choose a corrupt or empty file | "This photo could not be read. Try another."; nothing sent | §13.5.3 |
| TC-REP-032 | WebP photo | EDGE | P3 | DEVICE | ✋ | Real phone | Choose a WebP image from the gallery | Sent as a JPEG (the server refuses WebP) | §13.5.2, API guide §6.2 |
| TC-REP-033 | Very large photo | PERF | P2 | DEVICE | ✋ | Real phone; a 50 MP photo | Add it; file | Shrunk to 2048 px on the longer side and at most 1 MB; no crash; the screen stays usable | §13.5.2 |
| TC-REP-034 | Photo refused: 3 already or the hour passed | NEG | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | A photo answers `409 conflict` | Not offered again | §13.5.2 Retry, §13.5.3 |
| TC-REP-035 | Photo refused: report not found | NEG | P3 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | A photo answers `404 not_found` | Not offered again | §13.5.3 |
| TC-REP-036 | Photo answered 429 or 500 | NET | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | A photo answers `429`; another answers `500` | "Not sent. Tap to send again." for both; tapping sends the same file to the same report | §13.5.2 Retry |
| TC-REP-037 | A photo sent twice counts once | WORST | P1 | STAGE | ✋ | Staging; real phone | Airplane mode the moment a photo starts sending; back online; tap the failed photo | My reports shows the true number of photos (not one extra) | API guide §6.2 |
| TC-REP-038 | Photo added after filing | POS | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | File with 1 photo; add another within the hour | Sent at once to the same report; "Photo 2" | §13.5 Photos after filing |
| TC-REP-039 | Photo picker cancelled | EDGE | P3 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend; the picker returns nothing | **Add photo** → **Choose from gallery**; cancel | No photo added; no error | §13.5 |
| TC-REP-040 | Camera or gallery permission denied | NEG | P2 | DEVICE | ✋ | Real phone | Deny camera, then gallery access; **Add photo** | Spec gap 11. No crash; the report can still be filed without photos | §13.5 |
| TC-REP-041 | Report from a not-found result | EDGE | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend; R2 | `not_found` result → **Report incident**; file | The check row shows that reference; filed with `check_ref` | §13.1.4, §13.5 |
| TC-REP-042 | My reports: next page | POS | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Page 1 with a cursor; scroll to the end | Page 2 asked with `cursor`; appended; the end marker when `next_cursor` is `null` | §13.5.4, §10 |
| TC-REP-043 | My reports: none | EDGE | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Open My reports; the first page is empty | "You have not filed any report yet." | §13.5.4 |
| TC-REP-044 | My reports: first page error | NET | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | `GET incidents` answers `500`; then **Try again** | "Something went wrong. Try again." with "Reference: …"; then the list | §10.4 |
| TC-REP-045 | My reports row with nothing linked | EDGE | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | A report with `check_ref: null`, `retail_user: null`, `photos: 0` | "No photos"; no reference or retail user line; the text "null" never shown | §13.5.4 |
| TC-REP-046 | My reports sends only `limit` and `cursor` | POS | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Open My reports; load page 2 | No other query parameter | §13.5.4 |
| TC-REP-047 | Long note in My reports | UI | P3 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | A report with a 1 000-character note | Fits the row (shortened with "…" or wrapped); no overflow | §14 |
| TC-REP-048 | 50 reports an hour | NET | P3 | STAGE | ✋ | Staging build, backend test sheet | File 51 reports within an hour | The 51st: a countdown; no crash | §13.5.2 |
| TC-REP-049 | Photo after the hour on the server | NEG | P3 | STAGE | ✋ | Staging build, backend test sheet | File a report; add a photo 61 minutes later | "Photos can be added only within an hour of the report." | §13.5.3 |
| TC-REP-050 | A lost answer while filing never files again | WORST | P1 | AUTO | ✅ `features/incidents/report_incident_bloc_test` | Fake repository; filing answers a lost connection | File; tap again | "…check My reports before filing it again"; **Check My reports** instead of File; one request | Build guide step 7; SRS FR-INC-05 |
| TC-REP-051 | Link one of your own checks | POS | P2 | AUTO | ✅ `flow/reports_retail_flow_test` | Fake backend; R1 (with `history:own`) | **Link one of your checks**; pick one; file | The check shows on the report; sent as `check_ref` | SRS UC-08; decision N3 |
| TC-REP-052 | Done asks while a photo is not sent | EDGE | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend; the photo answers 500 | File with a photo; **Done**; **Stay**; **Done**; **Leave** | "Photos not sent" first; Stay keeps the report; Leave closes it | Guide §6.2 |
| TC-REP-053 | A report opens in full | POS | P3 | AUTO | ✅ `flow/reports_retail_flow_test` | Fake backend | My reports; tap a report | A sheet with the whole note, its time, photos, check, and retail user | SRS UC-09 |
| TC-REP-054 | A photo answered 429 waits | NET | P2 | AUTO | ✅ `flow/reports_edge_flow_test` (TC-REP-036) | Fake backend; the photo 429 with `Retry-After: 30`, then without | File with a photo; tap the photo during the wait | "Too many attempts. Try again in 30 s." on the tile; nothing sent before the end; without the header it can be tapped at once | Guide §1, §6.2 |
| TC-REP-055 | The note counts code points | BVA | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend | Type 998 letters and two flags (two code points each) | 998 letters and one flag kept (1,000 code points); the counter says 1000/1000 | Guide §3.6, §6.1 |
| TC-REP-056 | Filing answered 2xx that cannot be read | WORST | P1 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend; `POST incidents` 201 with an `id` that is not a number, then an HTML page | File | "The report was sent, but its answer could not be read…"; **Check My reports**; never filed again | Build guide step 7 |
| TC-REP-057 | The same photo twice | EDGE | P2 | AUTO | ✅ `flow/reports_edge_flow_test` | Fake backend; both photos answer `n: 1` | Add a photo twice; file | One tile "Photo 1"; "That photo is already on the report."; a place is free again | Guide §6.2 |
| TC-REP-058 | A 404 on filing names what is gone | NEG | P1 | AUTO | ✅ `features/incidents/report_incident_bloc_test`, `flow/reports_edge_flow_test` (TC-REP-025) | Fake backend; `POST incidents` 404 | File with "Check not found.", "Retail user not found.", no message | The check's text, the retail user's text (and the retail user taken off), or "Not available." | Guide §1, §6.1 |
| TC-REP-059 | A refused photo shows why and its reference | NEG | P2 | AUTO | ✅ `flow/reports_edge_flow_test` (TC-REP-034, -035) | Fake backend; the photo 409 "The report has 3 photos already.", then 404 | File with a photo | Under the photos the server's message for the 409, "This photo was refused." for the 404, each with "Reference: …" | Guide §1, §6.2 |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 11 (camera or gallery access denied while adding a photo).
