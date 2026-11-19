# PROF: Profile

| Field | Value |
|---|---|
| Spec | final.md §13.8, §16 |
| API | `GET me`, `POST me/password` |
| Automated in | `test/flow/profile_a11y_flow_test.dart`, `test/flow/language_flow_test.dart` |
| Format | [Case format and type tags](README.md#3-case-format) |

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-PROF-001 | Profile details | POS | P2 | MOCK | ✅ `flow/profile_a11y_flow_test` | Mock build | Open Profile | Initials "AR", Asha Rao, role, organisation, email | §13.8 |
| TC-PROF-002 | Support contact | POS | P2 | DEVICE | ✋ | Real phone | Tap **Support contact** | Mail app to `help@ziska.example` | §13.8 |
| TC-PROF-003 | Support not set | EDGE | P3 | MOCK | ✅ `flow/profile_a11y_flow_test` | Mock build | Profile with `support` emails `null` | "Not set by your office"; row not tappable | §13.8 |
| TC-PROF-004 | App version | POS | P3 | MOCK | ✅ `flow/profile_a11y_flow_test` | Mock build | Look at App version | `v0.1.0 · build 1` | §13.8 |
| TC-PROF-005 | Voluntary password change | POS | P2 | STAGE | ✋ | Staging build, backend test sheet | Profile → Change password → save | "Your password was changed."; back on Profile; other phones logged out | §6.6 |
| TC-PROF-007 | Initials of a one-word name | EDGE | P3 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; `name: "Karim"` | Open Profile | One initial, "K" | §13.8 |
| TC-PROF-008 | Initials of a Bangla name | I18N | P3 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; `name: "আশা রাও"` | Open Profile | The first whole character of each word, never a broken one: "আরা" ("রা" is one character) | §13.8 |
| TC-PROF-009 | Very long name | UI | P3 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; a 100-character name | Open Profile and the Check tab | Name wraps or ends with "…"; no overflow on either screen | §14 |
| TC-PROF-010 | Name with extra spaces | EDGE | P3 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; `name: "  Asha   Rao "` | Open Profile | Initials "AR" | §13.8 |
| TC-PROF-011 | No organisation | EDGE | P2 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; `organisation: null` | Open Profile and the Check tab | No organisation value; the text "null" never shown | §13.8 |
| TC-PROF-012 | Support email only | EDGE | P2 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; support phone `null` | Tap **Support contact** | The mail app is opened (`mailto:` to the support email) | §13.8 |
| TC-PROF-013 | Support phone only | EDGE | P2 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; support email `null` | Tap **Support contact** | The dialler is opened (`tel:` with the support phone) | §13.8 |
| TC-PROF-014 | Voluntary change returns to Profile | POS | P2 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend | Profile → **Change password**; fill; Save | "Choose a new password. Your other phones will be logged out." before; "Your password was changed." after; back on Profile; still logged in | §6.6 |
| TC-PROF-015 | Back from a voluntary change | STATE | P3 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend | Profile → Change password; press back | Profile (back is blocked only on the forced change) | §9.5 Back |
| TC-PROF-016 | Profile after a reload | STATE | P3 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend | A `403 forbidden` reloads `GET me`, which now has another role name | Profile shows the new role | §7.2 |
| TC-PROF-017 | Log out confirm text | POS | P3 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend | Tap **Log out** | "Log out?" with "This phone stays trusted, so the next login needs no emailed code." | §13.8 |

## Language

**Built 2026-11-19** (`final.md` §13.7, §16, §12.1): `PreferencesService` (core, `shared_preferences`), `LocaleCubit` read by `App`, the **Language** row on Profile, and every text of `app_en.arb` in `app_bn.arb`. The Bangla texts are drafts until a Bangla reader approves them ([bangla-drafts-for-review.md](../bangla-drafts-for-review.md), client question B5). Test fake: `FakePreferencesService` (in memory), passed to `startApp` so a restart keeps the choice. Times in Bangla digits on History: TC-HIST-044 in [06-history.md](06-history.md).

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| TC-PROF-006 | Language | I18N | P2 | MOCK | ✋ | Mock build | Switch to Bangla | Texts change to Bangla at once; the row names the current language | §16 |
| TC-PROF-018 | Switch to Bangla | I18N | P2 | MOCK | ✋ | Mock build | Profile → language → Bangla; visit every screen | Every app text in Bangla; "Reference: …" in Bangla too | §16 |
| TC-PROF-019 | Language kept after a restart | STATE | P2 | AUTO | ✅ `flow/language_flow_test` | Fake backend | Choose Bangla; restart the app | Still Bangla (a stored preference) | §12.1 Local data, §16 |
| TC-PROF-020 | Every English text has a Bangla text | I18N | P1 | AUTO | ✅ `l10n/arb_completeness_test` | `app_en.arb` and `app_bn.arb` | Compare the keys of both files | Every key of `app_en.arb` has a non-empty value in `app_bn.arb`; no extra keys | §16, §20.3 |
| TC-PROF-021 | Placeholders kept in Bangla | I18N | P1 | AUTO | ✅ `l10n/arb_completeness_test` | Both ARB files | Compare the `{placeholders}` of every text | Each Bangla text has the same placeholders as its English text (`{seconds}`, `{name}`, `{id}`, …) | §16 |
| TC-PROF-022 | The switch on Profile | POS | P2 | AUTO | ✅ `flow/language_flow_test` | `FakePreferencesService` | Profile → language | English and Bangla offered; the current one marked | §13.8 |
| TC-PROF-023 | The switch applies at once | STATE | P2 | AUTO | ✅ `flow/language_flow_test` | Fake backend | Choose Bangla on Profile; go to the Check tab | Bangla texts at once, without a restart | §13.8, §16 |
| TC-PROF-024 | Reference line in Bangla | I18N | P2 | AUTO | ✅ `flow/language_flow_test` | App in Bangla; a lookup answered `500` with `request_id: "req-9"` | Look up | The reference line in Bangla; the reference `req-9` itself unchanged | §16 |
| TC-PROF-025 | Messages chosen by error code in Bangla | I18N | P1 | AUTO | ✅ `flow/language_flow_test` | App in Bangla | Login answered `401 unauthenticated`; a lookup answered `503 app_preparing` | The Bangla texts for those codes; never the server's English message | §16 |
| TC-PROF-026 | Unknown code: the server text stays | I18N | P3 | AUTO | ✅ `flow/language_flow_test` | App in Bangla | A lookup answered `400` with an unknown `error.code` and a server message | The server message as sent (the fallback, §16), with the reference | §16 |
| TC-PROF-027 | Times in Bangla digits outside History | I18N | P2 | AUTO | ✅ `flow/language_flow_test` | App in Bangla | A result with a last check; My reports | Bangladesh time with Bangla digits on both | §16 |
| TC-PROF-028 | Date picker in Bangla | I18N | P3 | AUTO | ✅ `flow/language_flow_test` | App in Bangla; History | Filters → Choose dates | The calendar in Bangla; the dates sent still `YYYY-MM-DD` with Latin digits | §10.2, §16 |
| TC-PROF-029 | Kept after logout | STATE | P2 | AUTO | ✅ `flow/language_flow_test` | App in Bangla | Log out; log in again | Login and every screen after it still in Bangla (a preference, not part of the login) | §6.5, §12.1 |
| TC-PROF-030 | Language at the first start | I18N | P2 | AUTO | ✅ `flow/language_flow_test` | Fresh install; phone language Bangla, then English | Start the app | English, whatever the phone's language (the app's answer to open question 18; the client may change it) | §16 |
| TC-PROF-031 | Bangla at large fonts | A11Y | P2 | AUTO | ✅ `flow/device_a11y_flow_test`, `ui/consistency_fit_test` (goldens `bn_*`) | App in Bangla; text scale 2.0 and 3.0 | The screen tour of `device_a11y_flow_test` | No layout error on any screen | §14, §16 |
| TC-PROF-032 | TalkBack in Bangla | A11Y | P3 | DEVICE | ✋ | Real phone; app in Bangla; TalkBack on | Swipe through Login, Check, a result | Every item read in Bangla | §14, §16 |
| TC-PROF-033 | Password rules in Bangla | I18N | P3 | AUTO | ✅ `flow/language_flow_test` | App in Bangla | Set a new password; type `পাসওয়ার্ড১` | The three rules in Bangla, all ticked; Save enabled | §6.6, §16 |
| TC-PROF-034 | A Bangla reader checks the texts | UI | P2 | DEVICE | ✋ | Real phone; app in Bangla; a Bangla reader | Visit every screen and every error | Every text correct and natural; none in English except server fallbacks | §16 |
| TC-PROF-035 | Bangla digits typed into a serial | EDGE | P2 | AUTO | ✅ `flow/language_flow_test`, `verification/presentation/serial_input_formatter_test` | App in Bangla; a Bangla keyboard | Type `১০০০০০১` as a serial | The field shows `1000001` and `1000001` is sent: Bangla digits are read as 0–9 (the app's answer to open question 19) | §13.1.2, §16 |
| TC-PROF-036 | The check counts | POS | P2 | AUTO | ✅ `ui/screens_reports_profile_test`, `features/history/check_totals_cubit_test` | Fake backend; R2 (field inspector, `history:own`); totals 120 / 80 / 30 / 9 / 1 | Open Profile | **Checks** 120, **Valid** 80 (green), **Not verified** 10 (red: not found + not in a batch); one `GET checks` with `limit=1` and no filters | §13.8 |
| TC-PROF-037 | No counts without History | ROLE | P2 | AUTO | ✅ `ui/screens_reports_profile_test` | Fake backend; a retail seller without `history:own` | Open Profile | No count cards and no failure line; no `GET checks` sent | §13.8, §7 |
| TC-PROF-038 | Counts that cannot load | NEG | P2 | AUTO | ✅ `ui/screens_reports_profile_test`, `features/history/check_totals_cubit_test` | Fake backend; `GET checks` answers 500 once, then the first page | Open Profile; tap **Try again** | "Your counts couldn't load." with **Try again**; then the counts; a first page without `totals` counts as not loaded; the last counts stay while asked again | §13.8 |
| TC-PROF-039 | Counts again when the tab comes back | STATE | P3 | AUTO | ✅ `ui/screens_reports_profile_test` | Fake backend | Open Profile; go to Check; back to Profile | A second `GET checks` with `limit=1` | §13.8 |
| TC-PROF-040 | The counts on the phone | UI | P3 | DEVICE | ✋ | Real phone, staging build, an official with checks | Open Profile; check an item; open Profile again; pull down | The counts match History's **All** chip; after the check, **Checks** is one more | §13.8 |
| TC-PROF-041 | What the role allows | POS | P2 | AUTO | ✅ `flow/profile_edge_flow_test` | Fake backend; R1 (all four), a role with `item:bulk_lookup` and an unknown key, a role with none | Open Profile | **What you can do** lists Check one item, Check many items, Own history, Report incidents for what the role has; unknown keys are not shown; none: "None. Ask your office." | SRS FR-ACC-15 |

## Spec gaps in this file

See [README §7](README.md#7-open-questions-spec-gaps): 2 (the language switch, built 2026-11-19; the Bangla texts wait for the client's review), 18 (the language at the first start: English, the app's answer), 19 (Bangla digits typed into a serial: read as 0–9, the app's answer).
