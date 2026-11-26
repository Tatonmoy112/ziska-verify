# LOOK: Single Lookup and Certificate

> **2026-11-16 baseline:** [16-mobile-migration.md](16-mobile-migration.md) replaces conflicting cases for hidden-code input, bulk submission, everyone scope, retail administration, certificates, and email-only access requests. Historical IDs/counts below remain for traceability; do not execute retired cases as release requirements. Current architecture: ../../final.md.


| Field | Value |
|---|---|
| Spec | final.md §12.1, §13.1, §13.3, §13.7 |
| API | `GET formats`, `POST lookups` |
| Automated in | `test/flow/lookup_flow_test.dart`, `input_preparation_test`, `result_card_test`, `verification_contract_test`, `lookup_bloc_test` |
| Format | [Case format and type tags](README.md#3-case-format) |

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-LOOK-001 | Formats load | POS | P1 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Open the Check tab | Serial hint "Up to 19 digits" | §13.1.3 |
| TC-LOOK-002 | Serial accepts digits only | NEG | P1 | MOCK | ✅ `input_preparation_test` | Mock build | Type letters in Serial | Letters not entered | §13.1 |
| TC-LOOK-003 | Too-long serial refused | BVA | P1 | AUTO | ✅ `input_preparation_test` | Fake backend | 20 digits | "A serial has digits only, up to 19 digits."; nothing sent | §13.1.3 |
| TC-LOOK-006 | Valid result screen | POS | P1 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Serial `1000001`, **Check** | "Genuine product"; product, serial, masked code, batch, dates; reference `MA-2026-000123` | §13.1.4, §18.3 Lookup |
| TC-LOOK-007 | Every result has its own display | POS | P1 | AUTO + STAGE | ✅ `result_card_test` | Fake backend; Staging build, backend test sheet | Look up the test-sheet item for each result | Valid / Genuine, needs attention / Not found / Not in a batch, each with its own colour and icon | §13.1.4, §18.3 Lookup |
| TC-LOOK-008 | Every warning reason shown | POS | P1 | AUTO + STAGE | ✅ `result_card_test` | Fake backend; Staging build, backend test sheet | Items for checked_before, recalled, expired, damaged, switched_off | One labelled row per reason; checked before shows the check number and last time in Bangladesh time | §13.1.4 |
| TC-LOOK-009 | Unknown result is never genuine | EDGE | P1 | AUTO | ✅ `result_card_test`, `verification_contract_test` | Fake backend | Result value unknown to the app | "Unable to check" | §13.1.5 |
| TC-LOOK-010 | Copy the reference | POS | P3 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Tap the copy icon by the reference | "Copied"; clipboard holds the reference | §13.1.4 |
| TC-LOOK-011 | Report button only with `incident:report` | POS | P1 | MOCK | ✅ `flow/lookup_flow_test` | Mock build | Result screen as R2, then as R3 | R2: **Report incident** shown; R3: not shown | §13.5 |
| TC-LOOK-012 | One press, one check | WORST | P1 | AUTO | ✅ `lookup_bloc_test` | Fake backend | Tap Check twice quickly | One `POST lookups` | §8.3 |
| TC-LOOK-014 | App being prepared | NET | P2 | AUTO | ✅ `verification_contract_test` | Fake backend | Lookup answered `503 app_preparing` | "The app is being prepared. Try again later." | §13.1.6 |
| TC-LOOK-015 | Scan a product QR | POS | P1 | DEVICE | ✋ | Real phone | Open the Check tab; point the camera at a product QR (no tap) | Result screen; only the value after `/q/` sent | §13.1.2, §18.3 Lookup |
| TC-LOOK-016 | Scan a non-product QR | SEC | P1 | DEVICE | ✅ `input_preparation_test` | Real phone | Scan any website QR | "This QR code is not a product code of this company."; nothing sent; the link is not opened | §12.1 |
| TC-LOOK-017 | Same QR held in front of the camera | WORST | P2 | DEVICE | ✋ | Real phone | Keep the camera on one QR for 5 s | One lookup only | §13.1 |
| TC-LOOK-018 | Camera refused | NEG | P2 | DEVICE | ✋ | Real phone | Deny camera permission | "Camera access is off…" with **Open settings** | §13.1 |
| TC-LOOK-019 | Torch | POS | P3 | DEVICE | ✋ | Real phone | Tap the torch button in the bottom bar | Torch toggles | §13.1 |
| TC-LOOK-020 | Formats fail to load | NET | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | `GET formats` answers `500`; tap **Try again** after it answers `200` | "Could not load the code formats." with "Something went wrong. Try again." with "Reference: …"; no lookup form; after Try again the form appears | §13.1.3, §14.2 |
| TC-LOOK-021 | Formats offline | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend; no connection | Open the Check tab; then **Try again** online | "Could not load the code formats." and "No connection. Check the internet and try again."; the form after Try again | §13.1.3, §15.4 |
| TC-LOOK-022 | Formats loaded once per session | PERF | P3 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Open Check; go to History and back; do 3 lookups | One `GET formats` | §13.1.3 |
| TC-LOOK-024 | Serial length comes from the formats | EDGE | P1 | AUTO | ✅ `input_preparation_test`, `flow/lookup_edge_flow_test` | Fake backend; formats `serial.max_digits: 10` | Look at the hint; type 11 digits; Check | Hint "Up to 10 digits"; refused with "A serial has digits only, up to 10 digits." | §13.1.3 |
| TC-LOOK-025 | New formats after the next login | STATE | P3 | STAGE | ✋ | Staging; the backend changes a format | Log out and log in; type a value of the new format | Accepted under the new format | §13.1.3 |
| TC-LOOK-026 | Serial of 1 digit | BVA | P2 | AUTO | ✅ `input_preparation_test` | Fake backend | Serial `7`; Check | `POST lookups` with `{ "way": "serial", "value": "7" }` | §13.1.1 |
| TC-LOOK-027 | Serial of exactly the maximum | BVA | P1 | AUTO | ✅ `input_preparation_test` | Fake backend; `max_digits: 19` | A 19-digit serial; Check | Sent unchanged | §13.1.3 |
| TC-LOOK-028 | Serial with leading zeros | EDGE | P2 | AUTO | ✅ `input_preparation_test` | Fake backend | Serial `0001000001` | Sent as the text `"0001000001"`, zeros kept | §13.1.1 |
| TC-LOOK-029 | Serial pasted with spaces or dashes | EDGE | P2 | AUTO | ✅ `input_preparation_test` | Fake backend | Paste `1000 001`, then `1000-001` | Sent as `"1000001"` each time | §13.1.2 |
| TC-LOOK-030 | Serial pasted with a letter | WORST | P2 | AUTO | ✅ `input_preparation_test`, `serial_input_formatter_test`, `flow/lookup_edge_flow_test` | Fake backend | Paste `10O0001` (the letter O) | Refused with "A serial has digits only, up to 19 digits."; nothing sent (never silently checked as `100001`) | §13.1.2 |
| TC-LOOK-031 | Empty input | NEG | P3 | AUTO | ✅ `input_preparation_test`, `flow/lookup_edge_flow_test` | Fake backend | Leave the field empty | **Check** disabled; nothing sent | §13.1.2 |
| TC-LOOK-032 | Serial `0` | EDGE | P3 | AUTO | ✅ `input_preparation_test` | Fake backend | Serial `0`; Check | Sent; the answer decides (a value matching no item is `not_found`) | API guide §4.2 |
| TC-LOOK-037 | Value over 64 characters | BVA | P2 | AUTO | ✅ `input_preparation_test` | Fake backend | Paste 65 characters into Hidden code | The field keeps 64, or the input is refused; nothing over 64 characters sent | §12.1 Input safety |
| TC-LOOK-038 | QR link variants | EDGE | P1 | AUTO | ✅ `input_preparation_test` | Fake backend | Scan `https://www.ziskaverify.com/q/Q8F2KD91XA7M`, `http://…/q/Q8F2KD91XA7M`, `https://example.org/q/Q8F2KD91XA7M`, with `?utm=1`, with `#top`, with a trailing `/` | Each sends `{ "way": "qr", "value": "Q8F2KD91XA7M" }`; no link opened | §13.1.1, §13.1.2 |
| TC-LOOK-039 | Two `/q/` in one link | EDGE | P2 | AUTO | ✅ `input_preparation_test` | Fake backend | Scan `https://a.example/q/AAAAAAAAAAAA/q/Q8F2KD91XA7M` | Sends `Q8F2KD91XA7M` (after the last `/q/`) | §13.1.2 |
| TC-LOOK-040 | QR value one short and one long | BVA | P1 | AUTO | ✅ `input_preparation_test` | Fake backend; QR 12 characters | Scan a link whose value has 11, then 13 characters | "This QR code is not a product code of this company."; nothing sent | §13.1.3 |
| TC-LOOK-041 | QR value in lowercase | EDGE | P2 | AUTO | ✅ `input_preparation_test` | Fake backend | Scan `https://www.ziskaverify.com/q/q8f2kd91xa7m` | Sent as read, `q8f2kd91xa7m`: a QR in lower case finds the same item, as the server reads it in capitals (guide §4, "Reading a QR"; updated 2026-11-23, TC-LOOK-128) | §13.1.2; guide §4 |
| TC-LOOK-042 | QR holding only the value | EDGE | P3 | AUTO | ✅ `input_preparation_test` | Fake backend | Scan a QR holding the text `Q8F2KD91XA7M` (no link) | "This QR code is not a product code of this company." (no `/q/`); nothing sent | §13.1.2 |
| TC-LOOK-043 | Every reason at once | EDGE | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answers `warning` with all five reasons | "Genuine, needs attention"; rows "Checked before", "Batch recalled", "Expired", "Marked damaged", "Batch switched off" | §13.1.4 |
| TC-LOOK-044 | Unknown reason next to known ones | EDGE | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answers `warning` with reasons `["expired", "new_reason"]` | "Expired" and a "Needs attention" row; neither hidden | §13.1.5 |
| TC-LOOK-045 | Warning without reasons | WORST | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answers `warning` with `reasons: []` | "Genuine, needs attention" (never "Genuine product"); no crash | §13.1.5 |
| TC-LOOK-046 | Optional fields `null` | EDGE | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answers `valid` with `picture_url`, `short_name`, `made`, `expires` all `null` | Result shown without those values; the text "null" never shown; no crash | §13.1.4 |
| TC-LOOK-047 | Earlier checkers are never shown | POS | P2 | AUTO | ✅ `ui/components_feature_test` | The tracking details of a check made before | Show the card | No "Checked before by" line and no names: who made the earlier checks is never sent (guide §4.2; since 2026-11-17, the tests of `count.by` went with it; production audit P-48) | §13.1.4 |
| TC-LOOK-048 | First check has no last time | EDGE | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answers `valid` with `count: { "this_check": 1, "last_at": null }` | No "Last check" text; no crash | API guide §4.2 |
| TC-LOOK-049 | Not found and not in a batch show no item | POS | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answers `not_found`; then `unassigned` | "Not found" / "Not in a batch" with their texts; the reference number (in the top card and in WHAT YOU ENTERED); no product or batch rows | §13.1.4 |
| TC-LOOK-050 | Very long product name | UI | P3 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answers a 200-character `name` and `generic_name` | Text wraps; no overflow; the reference still shown | §14 |
| TC-LOOK-051 | Very high check number | EDGE | P3 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | `checked_before` with `this_check: 99999` | "This is check number 99999 of this item." fits on a phone screen | §13.1.4 |
| TC-LOOK-052 | Last check time in Bangladesh time | I18N | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend; phone time zone UTC | `count.last_at: "2026-10-12T20:30:00Z"` | Shown as 13 Oct 2026, 02:30 (Bangladesh time, the next day) | §16 |
| TC-LOOK-053 | Expiry on the day itself | EDGE | P2 | STAGE | ✋ | Staging; a batch expiring today (Bangladesh date) | Look the item up today; again tomorrow | Today: no "Expired"; tomorrow: "Expired" | §13.1.4 (DEC-330) |
| TC-LOOK-054 | Masked code shown as received | SEC | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Look up by hidden code; the answer has `item.code: "*****7K2"` | `*****7K2` shown exactly; the typed hidden code is nowhere on the result | §12.1, §13.1.4 |
| TC-LOOK-055 | Unknown fields in the answer | EDGE | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Lookup answer with extra fields (`"new_field": {}` in `data` and in `item`) | Result shown normally | §13.1.5 |
| TC-LOOK-056 | Lookup answered 400 | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | `POST lookups` answers `400 validation_failed` | "Something went wrong. Try again." with "Reference: …" | §13.1.6 |
| TC-LOOK-057 | Lookup rate limited | NET | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | `POST lookups` answers `429` with `Retry-After: 15` | "Too many attempts. Try again in 15 s." counting down; a lookup is possible again at 0 | §13.1.6 |
| TC-LOOK-058 | Lookup when the client is switched off | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | `POST lookups` answers `404 not_found` | "Not available." | §14.2 |
| TC-LOOK-059 | Lookup answered 500 or 503 | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | `500 internal_error`; then `503 service_unavailable` | `500`: "Something went wrong. Try again." with "Reference: …"; `503`: "The service is busy. Try again shortly." | §15.4 |
| TC-LOOK-060 | Lookup timeout | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend; no answer | Check; the request times out | "The answer was lost. This check may already be recorded; checking again counts as another check." (the request was sent, so the check may be recorded; updated 2026-11-23, audit 4.2) | §13.1.6 |
| TC-LOOK-061 | Broken lookup answer | WORST | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | `POST lookups` answers `200` with cut-off JSON, then with `data: null` | An error each time; never a result, never "Genuine product" | §13.1.5 |
| TC-LOOK-062 | Camera permanently denied | NEG | P2 | DEVICE | ✋ | Real phone | Deny the camera with "Don't ask again"; open the Check tab; **Open settings**; allow; return | "Camera access is off. Allow it in Settings to scan QR codes."; settings open; the camera works after returning | §13.1 |
| TC-LOOK-063 | Phone without a camera | EDGE | P3 | DEVICE | ✋ | Device or emulator without a camera | Open the Check tab | "This phone cannot scan QR codes. Type the serial instead." | §13.1 |
| TC-LOOK-064 | Damaged QR | EDGE | P3 | DEVICE | ✋ | Real phone; a printed QR with a corner covered | Point the camera at it | Nothing sent until the code reads; never a wrong value | §13.1.2 |
| TC-LOOK-065 | Two QR codes in view | EDGE | P3 | DEVICE | ✋ | Real phone; two product QR codes side by side | Point the camera at both | One lookup; one result screen | §8.3 |
| TC-LOOK-066 | Scan while offline | NET | P2 | DEVICE | ✋ | Real phone; airplane mode | Scan a product QR | "Unable to check. Check the connection and try again." | §13.1.6 |
| TC-LOOK-067 | Leave the scanner and return | STATE | P3 | DEVICE | ✋ | Real phone | Open Scan; press back; open Scan again; switch to another app and back | The camera starts each time; no leftover lookup | §13.1 |

## Result Screen, Loader, and Product Picture

The result screen after every lookup, the verification loader, and the product picture (final.md §13.1.2, §13.1.4, decisions 46–49). TC-LOOK-089 … -117.

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-LOOK-089 | Every path opens the same result screen | POS | P1 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | Look up by typed serial; by scanned QR; open a row of the Bulk lookup results | The same result screen each time, with the top card, the details, and the picture card | §13.1.4, decision 46 |
| TC-LOOK-090 | Genuine: product details and picture | POS | P1 | AUTO | ✅ `ui/components_feature_test`, `ui/screens_verify_history_test` | Fake backend (`startApp`) | Lookup answered `valid` with every field | **PRODUCT DETAILS**: name, generic name, short name, batch, made, expires, serial, masked code; then **PRODUCT IMAGE** | §13.1.4 |
| TC-LOOK-091 | Checked before: check number, no uses limit | POS | P1 | AUTO | ✅ `ui/screens_verify_history_test` | Fake backend (`startApp`) | `warning` with `checked_before`, `count.this_check` 3, `last_at` set | Badge "CHECKED BEFORE"; "This is check number 3 of this item. Last check: <Bangladesh time>."; **TRACKING DETAILS** with a "Check 3" pill and the previous check time; no uses limit, no network address, no "do not purchase" | §13.1.4, backend D16, D31 |
| TC-LOOK-092 | No "Checked before by" row | EDGE | P2 | AUTO | ✅ `ui/components_feature_test` | `checked_before`, check 3, with the previous check's time | Show TRACKING DETAILS | The check number and the previous check's time; no "Checked before by" row (guide §4.2; production audit P-48) | §13.1.4 |
| TC-LOOK-093 | A warning without `checked_before` | POS | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend (`startApp`) | `warning` with `recalled` and `expired` only | Badge "NEEDS ATTENTION"; one row per reason; **PRODUCT DETAILS** (not tracking) | §13.1.4 |
| TC-LOOK-094 | Not found: what you entered | POS | P1 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | Serial `1000999` answered `not_found` | **WHAT YOU ENTERED**: Serial, `1000999`, the check time in Bangladesh time, "Not found", the reference | §13.1.4, decision 49 |
| TC-LOOK-096 | Hints from the formats | POS | P2 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | `GET formats` with `max_digits` 10 and hidden codes of 12 and 16 characters; a `not_found` | **HINTS** quote "up to 10 digits" and both hidden code lengths; no fixed 12 / 7 digits | §13.1.4, backend D41 |
| TC-LOOK-097 | The QR hint only when not scanned | EDGE | P3 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | `not_found` from a typed serial; then from a scanned QR | Typed: "Scan the QR code instead" shown; scanned: not shown | §13.1.4 |
| TC-LOOK-098 | Try again returns to where it started | STATE | P2 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | `not_found` from the Check tab (hidden code); then from the scanner | Check: the form again, the hidden code field empty; scanner: the camera again | §13.1.4, §12.1 |
| TC-LOOK-099 | Contact support only when set | POS | P2 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | `not_found` with the profile's support email set; then with support `null` | Set: **Contact support** opens an email to the support address with the reference, the way, the value (a hidden code masked), and the check time; phone only: it calls; `null`: no button | §13.1.4, §13.8 |
| TC-LOOK-100 | Back to Check | POS | P3 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | `not_found` from a Bulk lookup row; tap **Back to Check** | The Check tab | §13.1.4 |
| TC-LOOK-101 | Not in a batch and unknown use the same layout | POS | P2 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend (`startApp`) | `unassigned`; then an unknown `result` | What you entered and the actions, with no hints; each with its own colour, title, and badge; never the genuine look | §13.1.4, §13.1.5 |
| TC-LOOK-102 | A slow lookup shows the loader | STATE | P1 | AUTO | ✅ `flow/verifying_flow_test` | Fake backend (`startApp`); lookup answered after 2 s | Check a serial | After 300 ms the loader: "Checking the item…"; **Code format** ticked; **Item record** and **Check count** pending; the bottom bar covered | §13.1.2, decision 48 |
| TC-LOOK-103 | A fast lookup never shows the loader | STATE | P2 | AUTO | ✅ `flow/verifying_flow_test` | Fake backend (`startApp`); lookup answered at once | Check a serial | Straight to the result; the loader never drawn | §13.1.2 |
| TC-LOOK-104 | The result replaces the loader | STATE | P1 | AUTO | ✅ `flow/verifying_flow_test` | Fake backend (`startApp`); lookup answered after 2 s | Check; wait; press back on the result | The result screen; back returns to the Check tab, not to the loader | §13.1.2 |
| TC-LOOK-105 | A failure closes the loader | NET | P1 | AUTO | ✅ `flow/verifying_flow_test` | Fake backend (`startApp`); lookup answered `429` (30 s) after 2 s; then `500` | Check a serial each time | The loader closes; the Check tab shows the countdown banner, then the error with its reference | §13.1.2, §13.1.6 |
| TC-LOOK-106 | Back blocked during the check | WORST | P2 | AUTO | ✅ `flow/verifying_flow_test` | Fake backend (`startApp`); lookup answered after 2 s | Check; press Android back on the loader | The loader stays; one `POST lookups`; the result follows | §13.1.2, §8.3 |
| TC-LOOK-107 | The loader from the scanner | STATE | P2 | AUTO | ✅ `flow/verifying_flow_test` | Fake backend (`startApp`); fake camera; lookup answered after 2 s | Scan a product QR | The loader, then the result | §13.1.2 |
| TC-LOOK-108 | The picture is shown whole | POS | P1 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`); the fake picture service returns a test picture | Genuine result with `picture_url` set | **PRODUCT IMAGE** shows the picture in a 4:3 box, uncropped (`BoxFit.contain`) | §13.1.4, decision 47 |
| TC-LOOK-109 | A skeleton while the picture loads | STATE | P2 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`); the picture arrives late | Open a genuine result | A skeleton in the picture box, then the picture | §13.1.4 |
| TC-LOOK-110 | A picture that fails, then Try again | NET | P1 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`); the picture fails once | Open a genuine result; tap **Try again** | Placeholder and "The picture could not be loaded"; then the picture | §13.1.4 |
| TC-LOOK-111 | No picture | EDGE | P1 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`) | `picture_url` `null` | The placeholder and "No picture for this product"; nothing requested | §13.1.4 |
| TC-LOOK-112 | A picture address that is not HTTPS | SEC | P1 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`) | `picture_url` `http://pictures.example.com/1.jpg` | Treated as no picture; the picture service is never asked | §12.1, §13.1.4 |
| TC-LOOK-113 | The picture full screen | POS | P2 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`) | Tap the picture; pinch; tap **Close** | A full-screen view that zooms; Close returns to the result | §13.1.4 |
| TC-LOOK-114 | The picture read by TalkBack | A11Y | P2 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`) | Semantics on; a genuine result | The picture is read as "Picture of Paracetamol 500"; the full-screen Close has a label | §13.1.4, §12.1 |
| TC-LOOK-115 | No picture card without an item | EDGE | P2 | AUTO | ✅ `ui/screens_verify_history_test` | Fake backend (`startApp`) | `not_found` and `unassigned` | No **PRODUCT IMAGE** card | §13.1.4 |
| TC-LOOK-116 | A real picture on a phone | NET | P1 | DEVICE + STAGE | ✋ | Real phone, staging build; a test-sheet product with a 5 MB picture | Look the item up on Wi-Fi, then on slow 3G; zoom; rotate | The picture loads over HTTPS (skeleton first on 3G), zooms sharp, and the app stays smooth | §13.1.4, decision 47 |
| TC-LOOK-117 | The picture decoded at the size shown | PERF | P3 | AUTO | ✅ `ui/product_picture_test` | Fake backend (`startApp`) | A genuine result | The picture is decoded at the box width × the pixel ratio (`cacheWidth`), not at its full size | §13.1.4 |
| TC-LOOK-118 | A checked-before warning keeps every item field | POS | P1 | AUTO | ✅ `flow/result_screen_flow_test` | Fake backend; a warning `[checked_before, expired]` | Look up | Product, generic, short name, batch, made, expires, serial, masked code, and "Check 3" with the previous check | SRS FR-LKP-06 |
| TC-LOOK-119 | The check count on every found item; a missing field is blank | POS | P2 | AUTO | ✅ `flow/result_screen_flow_test`, `ui/consistency_fit_test` | Fake backend; a warning `[recalled]` with `made: null` | Look up | "Check 3"; Made shows "—" | SRS FR-LKP-06 |
| TC-LOOK-120 | A formats failure keeps the camera and the tools | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend; `formats` offline once | Open Check; **Try again** | The serial form shows the error and **Try again**; Scan QR code and Scanner mode stay | final.md §13.7 |
| TC-LOOK-121 | Scan again after a failed QR lookup | NET | P1 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend; the first lookup offline | Scan a QR; **Scan again**; scan the same QR | **Scan again** above the bottom bar; the same QR is sent again and answers | Guide §4.6 |
| TC-LOOK-122 | The camera shows a formats failure | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend; `GET formats` offline once | Open the Check tab; **Try again** | The camera says "Scanning waits for the code formats." (no spinner); the card under it has the error and **Try again**; then a scan is sent | Guide §1, build guide §4.4 |
| TC-LOOK-123 | A 429 on the formats counts down | NET | P2 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend; `GET formats` 429 with `Retry-After: 20` | Check tab; tap **Try again** before and after 20 s | "Too many attempts. Try again in 20 s." on the button; nothing sent before the end; one request after | Guide §1 |
| TC-LOOK-124 | A scan on the Check tab is sent at once | POS | P1 | AUTO | ✅ `flow/check_tab_camera_flow_test` | Fake backend; fake camera | Log in; show a QR to the camera (no tap) | One `POST lookups {"way":"qr","value":"Q8F2KD91XA7M"}`; the result; back: the camera runs again | Guide §4.2, final.md §13.10 |
| TC-LOOK-125 | The camera runs only while seen | STATE | P1 | AUTO | ✅ `flow/check_tab_camera_flow_test` | Fake backend; fake camera | Switch to History and back; open Scanner mode and back; app to the background and back | Stopped on another tab, under a tool, and in the background; running again on return; a stopped camera reads nothing | final.md §13.10 |
| TC-LOOK-126 | Camera refused on the Check tab | NEG | P2 | AUTO | ✅ `flow/check_tab_camera_flow_test`, `ui/screens_verify_history_test` (TC-UI-095) | Fake camera answering "denied" | Open the Check tab; type a serial; **Check** | "Camera access is off…" with **Open settings**; the serial is sent as `{"way":"serial"}` | §13.1 |
| TC-LOOK-127 | No camera without item:lookup | ROLE | P2 | AUTO | ✅ `flow/check_tab_camera_flow_test` | Role with `incident:report` only | Log in | No camera is made or shown; the tools only | §7, §13.7 |
| TC-LOOK-128 | A QR in lower case is sent as read | EDGE | P2 | AUTO | ✅ `input_preparation_test`, `flow/check_tab_camera_flow_test` | Fake backend; formats' characters A–Z and 0–9 | Scan `…/q/q8f2kd91xa7m` on the Check tab and in Scanner mode; also `Q8f2Kd91xA7m`, a value one short, one with `!` or `_`, one with the ligature `ﬆ` | Lower and mixed case sent as read (with the `session_id` in Scanner mode); a wrong length, a symbol, or a character whose capitals are two letters still refused before sending | guide §4 ("Reading a QR") |
| TC-LOOK-129 | Back from a result: the same QR is not checked again | NEG | P1 | AUTO | ✅ `flow/check_tab_camera_flow_test` | Fake backend; the camera still sees the same pack | Scan a QR; go Back from the result; the camera reads the same QR again after 1 s, after 6 s; a different QR; a typed serial's result, then a QR | The same QR within 5 s of coming back is not sent (one `POST lookups`); after 6 s it is sent (a check on purpose); a different QR, and a QR after a typed serial, are sent at once; Scan again after a failure still sends the same QR (TC-LOOK-121) | guide §4.3 ("Do not send the same QR twice in a row while it stays in front of the camera") |
| TC-LOOK-130 | A scan without an answer: lost or never sent | NET | P1 | AUTO | ✅ `flow/check_tab_camera_flow_test` | Fake backend; `POST lookups` times out, or there is no connection | Scan a QR on the Check tab | Timed out after sending: "The answer was lost. This check may already be recorded; checking again counts as another check."; never sent: "Unable to check. Check the connection and try again." | final.md §13.10; audit 4.2 |
| TC-LOOK-131 | Back from Scanner mode: the Check tab camera runs | STATE | P1 | AUTO | ✅ `flow/check_tab_camera_flow_test` | Fake backend; fake camera that, as the plugin, lets one session hold the phone's one camera | Open Scanner mode, leave by Android Back, by the back arrow, and by Done after Finish | Scanner mode lets its camera go before it leaves; the Check tab holds the camera, no start is refused, no "The camera could not start.", and a QR is read and sent | final.md §13.1, §13.2; emulator run 2026-11-23, finding F-2 |
| TC-LOOK-132 | A refused serial's message goes with the text | STATE | P3 | AUTO | ✅ `flow/lookup_edge_flow_test` | Fake backend | Type `10O0001` and tap Check; then empty the field, or correct the serial; separately, a typed serial whose answer is lost, then change the text | "A serial has digits only, up to 19 digits." goes as soon as the text changes, nothing sent; the lost-answer message ("may already be recorded") stays until the next Check | final.md §13.1; emulator run 2026-11-23, finding F-1 |

## Certificate

**Blocked until built** (`final.md` §13.3). Entry criteria: `CertificateComposer` (domain), `PdfService` and `ShareService` (core), the route `/home/result/certificate`, the action on a valid or warning result, and the bundled TTF font (§2.2). Test fakes to add with it, in `test/flow/harness.dart`: `FakePdfService` (keeps the composed fields and text) and `FakeShareService` (records the file shared; can cancel). The case plan: [remaining-work-test-plan.md §4.1](../remaining-work-test-plan.md#41-certificate).

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 1 (the certificate is not built: LOOK-068 … -088 are ⛔), 16 (a certificate that cannot be made), 17 (the certificate's language).

## Withdrawn by the backend (2026-11-16)

Not counted and not run: kept so the IDs stay traceable. IDs are not reused.

**Certificates: withdrawn (SRS v1.2 FR-LKP-13).**

- TC-LOOK-068 · Certificate from a valid result
- TC-LOOK-069 · Certificate from a warning lists its reasons
- TC-LOOK-070 · No certificate for not found or not in a batch
- TC-LOOK-071 · Certificate time with its offset
- TC-LOOK-072 · Certificate file removed after sharing
- TC-LOOK-073 · Certificate restored without its result
- TC-LOOK-074 · The official's name on the certificate
- TC-LOOK-075 · Check time on a phone in another time zone
- TC-LOOK-076 · Optional fields missing
- TC-LOOK-077 · Long names wrap on the page
- TC-LOOK-078 · Bangla and symbols print
- TC-LOOK-079 · Only the masked code
- TC-LOOK-080 · Every reason, and an unknown one
- TC-LOOK-081 · Reference printed exactly
- TC-LOOK-082 · Share cancelled
- TC-LOOK-083 · The PDF cannot be made
- TC-LOOK-084 · Certificate needs `item:lookup`
- TC-LOOK-085 · One press, one certificate
- TC-LOOK-086 · Opens and prints on a phone
- TC-LOOK-087 · The client's layout
- TC-LOOK-088 · Certificate language

**Typing or looking up a hidden code: withdrawn (backend D62; `way: hidden_code` answers 400).**

- TC-LOOK-004 · Wrong hidden code refused
- TC-LOOK-005 · Spaces and dashes in a hidden code
- TC-LOOK-013 · Hidden code cleared after use
- TC-LOOK-023 · Several hidden-code formats
- TC-LOOK-033 · Hidden code one short and one long
- TC-LOOK-034 · Hidden code in lowercase
- TC-LOOK-035 · Hidden code with a character outside its format
- TC-LOOK-036 · Hidden code pasted with a line break or tab
- TC-LOOK-095 · Not found by hidden code: masked only
