# BULK: Bulk Lookup

| Field | Value |
|---|---|
| Spec | final.md §13.2 |
| API | `POST lookups/bulk` |
| Automated in | `test/flow/lookup_flow_test.dart`, `bulk_lookup_bloc_test`, `bulk_contract_test`, `bulk_results_view_test` |
| Format | [Case format and type tags](README.md#3-case-format) |

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-BULK-001 | Entry only with `item:bulk_lookup` | POS | P1 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Verify tab as R2 and R5 | R2 has the Bulk lookup tile; R5 does not | §13.2 |
| TC-BULK-002 | Add typed items | POS | P2 | MOCK | ✅ `bulk_lookup_bloc_test` | Mock build | Add serials `1000001`, `1000002`, hidden code `481516234200` | 3 rows numbered 1–3; hidden code shown `*****200`; counter "3 / 500 items" | §13.2 |
| TC-BULK-003 | Duplicate refused | NEG | P2 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend | Add `1000001` twice | "This item is already in the list."; still one row | §13.2 |
| TC-BULK-004 | Wrong format refused | NEG | P2 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend | Add hidden code `12` | The format message; not added | §13.2 |
| TC-BULK-005 | 500 items maximum | BVA | P2 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend | Add a 501st item | "The list is full (500 items)." | §13.2, §18.3 Bulk |
| TC-BULK-006 | Remove and clear | POS | P3 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Remove one row; then **Clear list** | Row gone; then the list is empty | §13.2 |
| TC-BULK-007 | Results by position with summary | POS | P1 | MOCK | ✅ `bulk_contract_test` | Mock build | Add exactly 3 items; **Check 3 items** | Summary 3 / 1 valid / 1 warning / 1 not found; rows 1–3 in order with their own references | §13.2, §18.3 Bulk |
| TC-BULK-008 | Count mismatch is never shown | WORST | P1 | MOCK | ✅ `bulk_contract_test` | Mock build | On the mock, send 1 or 2 items | An error ("Something went wrong"); no results shown | §13.2 |
| TC-BULK-009 | Only items that need attention | POS | P2 | MOCK | ✅ `bulk_results_view_test` | Mock build | Results → turn on the switch | The valid row disappears | §13.2 |
| TC-BULK-010 | Open a row | POS | P2 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Tap a result row | That item's full result screen | §13.2 |
| TC-BULK-011 | 503: send the same list again | NET | P1 | AUTO + STAGE | ✅ `bulk_lookup_bloc_test` | Fake backend; Staging build, backend test sheet | Bulk answered `503` | "Nothing was checked. Send the same list again."; **Send again**; same list | §13.2, §18.3 Bulk |
| TC-BULK-012 | 429: wait | NET | P2 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend | Bulk answered `429 Retry-After: 42` | Countdown; button disabled until 0 | §13.2 |
| TC-BULK-013 | Scan many QR codes | POS | P2 | DEVICE | ✋ | Real phone | **Scan QR codes**; scan 3 different QRs | Each added with "Added …" and a short vibration | §13.2 |
| TC-BULK-014 | New list | POS | P3 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | After results, **New list** | Empty list, ready to add | §13.2 |
| TC-BULK-015 | Empty list cannot be sent | BVA | P2 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | Open Bulk lookup; add nothing | "Scan QR codes or type serials and hidden codes to build the list."; no way to send | §13.2 |
| TC-BULK-016 | One item | BVA | P2 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend | Add one serial; send | One `POST lookups/bulk` with 1 item | §13.2 |
| TC-BULK-017 | Exactly 500 items | BVA | P1 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend | Add 500 items; send | "500 / 500 items"; one request with 500 items | §13.2 |
| TC-BULK-018 | Mixed ways in one list | POS | P1 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | Add serial `1000001`, hidden code `481516234200`, a scanned QR `Q8F2KD91XA7M`; send | One request; each item has its own `way` and `value`, in the order added | §13.2 |
| TC-BULK-019 | Duplicate after normalising | EDGE | P2 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend | Add hidden code `4815 1623 4200`, then `481516234200` | "This item is already in the list."; one row | §13.2 |
| TC-BULK-020 | Same value, different way | EDGE | P3 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend; serial and hidden code both 12 digits | Add serial `123456789012`, then hidden code `123456789012` | Both added (the way differs) | §13.2 |
| TC-BULK-021 | Same QR scanned twice | EDGE | P2 | DEVICE | ✋ | Real phone | **Scan QR codes**; scan one QR twice | "This item is already in the list."; one row | §13.2 |
| TC-BULK-022 | Non-product QR while building | NEG | P2 | DEVICE | ✋ | Real phone | **Scan QR codes**; scan a website QR | "This QR code is not a product code of this company."; not added | §13.2 |
| TC-BULK-023 | One press, one bulk request | WORST | P1 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend; slow answer | Tap **Check N items** twice quickly | One `POST lookups/bulk` | §8.3 |
| TC-BULK-024 | Connection lost while sending | NET | P1 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend; the send fails with no connection | Send a list of 3 | Spec gap 10. No automatic resend; no crash | §12.1 API protection |
| TC-BULK-025 | Back pressed or app closed while sending | WORST | P2 | DEVICE | ✋ | Real phone; slow network | Send a list of 50; press back (then, another time, close the app) | Spec gap 10. Never sent twice without the official asking | §8.3 |
| TC-BULK-026 | All not found | EDGE | P2 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | 3 items; every result `not_found`; turn on "Only items that need attention" | Summary: total 3, not found 3; the switch hides nothing (only valid rows are hidden) | §13.2 |
| TC-BULK-027 | All valid with the switch on | EDGE | P3 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | 3 valid results; turn on the switch | "No item needs attention." | §13.2 |
| TC-BULK-028 | Summary by reason | POS | P1 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | An answer with `by_reason`: `checked_before` 2, `expired` 1 (one item has both) | Each reason shown with its count, as answered | §13.2 |
| TC-BULK-029 | More results than items sent | WORST | P1 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | Send 3; the answer has 4 results | An error; no results shown | §13.2 |
| TC-BULK-030 | Typed hidden codes dropped after the results | SEC | P1 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | Add hidden code `481516234200`; send; open its row; **New list** | Rows show `*****200` only; the typed value is gone from the screen and the state; the new list is empty | §13.2 Hidden codes |
| TC-BULK-031 | Unknown result in a row | EDGE | P1 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | One result is `result: "something_new"` | That row: "Unable to verify", never valid | §13.1.5 |
| TC-BULK-032 | Bulk answered 400 | NET | P3 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | `POST lookups/bulk` answers `400 validation_failed` | "Something went wrong. Try again." with "Reference: …" | §15.4 |
| TC-BULK-033 | Same list after the wait | STATE | P1 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | Send 3 items; `429` with `Retry-After: 5`; after 5 s **Send again** | The second request holds the same items in the same order | §13.2 |
| TC-BULK-034 | Back from a row to the results | STATE | P2 | AUTO | ✅ `flow/bulk_edge_flow_test` | Fake backend | Results; switch on; open row 2; back | The results with the switch still on | §13.2, §9.5 |
| TC-BULK-035 | 3 000 items a minute | NET | P3 | STAGE | ✋ | Staging build, backend test sheet | Send 500-item lists one after another for a minute | `429` with a countdown; after the wait the same list goes through | §13.2 |
| TC-BULK-036 | Fast scanning | PERF | P3 | DEVICE | ✋ | Real phone; 50 different product QR codes | Scan all 50 one after another | Each added once with "Added …" and a vibration; no freeze | §13.2 |
| TC-BULK-037 | Editing the list while it is sent | WORST | P3 | AUTO | ✅ `bulk_lookup_bloc_test` | Fake backend; slow answer | Send 3 items; while sending, try to remove a row or add an item | The results match the items sent, by position | §13.2 |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 10 (a send interrupted by a lost connection, back, or closing the app).
