# Track & Trace — Decision Sheet

> **2026-11-16 contract migration:** final.md v2.0 and [the migration acceptance cases](test-cases/16-mobile-migration.md) supersede conflicting requirements below. Hidden-code submission, the 500-item bulk endpoint, everyone scope, retail administration and certificates are retired. Old counts/status tables are historical, not current completion evidence. Use [the release backlog](release-backlog.md) for unrelated unfinished work.


**For:** the app owner, the client (Ziska Pharma), and the backend team.
**Why:** the behaviours below are not defined by `final.md` or the backend documents. Until one option is chosen, their test cases say "Spec gap" instead of an expected result, so they cannot pass or fail.

**How to fill it in:** tick one option per question (`[x]`), write who decided and the date, and send it back. A question may also be answered with your own option; write it on the "Other" line.

| Field | Value |
|---|---|
| Version | 1.0 — 2026-11-14 |
| Questions | 20 (the same numbers as [test-cases README §7](test-cases/README.md#7-open-questions-spec-gaps)) |
| Plan | [remaining-work-test-plan.md §5](remaining-work-test-plan.md#5-item-3--open-questions) |

## Summary

| # | Question | Decided by | Status |
|---|---|---|---|
| 3 | Which time zone defines a History day | Backend | Open |
| 4B | Are emails matched without case | Backend | Open |
| 6 | May a new password equal the current one | Backend | Open |
| 12B | Is `Retry-After` always whole seconds | Backend | Open |
| 19B | Does the server accept only Latin digits | Backend | Open |
| 1 | Certificate: when | Client | Open |
| 2 | Language switch: when, and the Bangla texts | Client | Open |
| 14 | Hide sensitive screens from screenshots | Client | Open |
| 15 | Dark mode | Client | Open |
| 17 | Certificate language | Client | Open |
| 4A | Which email addresses the app refuses | App owner | Open |
| 5 | An unknown login status | App owner | Open |
| 7 | "Call the office" without a dialler | App owner | Open |
| 8 | Secure storage that cannot be read | App owner | Open |
| 9 | A profile without a permissions list | App owner | Open |
| 10 | A bulk send cut off | App owner | Open |
| 11 | Camera or gallery access denied for a photo | App owner | Open |
| 12A | A `429` without a usable `Retry-After` | App owner | Open |
| 13 | Offline banner: when | App owner | Open |
| 16 | A certificate that cannot be made | App owner | Open |
| 18 | The language at the first start | App owner, client | Open |
| 19A | Bangla digits typed into a serial | App owner | Open |
| 20 | The §14.1 component list against what is built | App owner | Open |
| 21 | The colour of a chosen segment or chip | App owner | Open |

---

## Part 1 — Backend Team

### Q3. Which time zone defines a day in History filters?
The app's date picker shows Bangladesh dates and sends `from=2026-10-28&to=2026-10-28` (both included). The portal reads such a date as a UTC day (06:00 to 06:00 Bangladesh time). **Cases:** HIST-010 (and HIST-016 … -018).

| | Option | What the official sees |
|---|---|---|
| [ ] | A. A Bangladesh day: 00:00 to 24:00 `+06:00` | A check at 02:00 Bangladesh time is in that day's list |
| [ ] | B. A UTC day, as the portal | A check at 02:00 Bangladesh time is in the previous day's list; the app adds a note under the date filter |

Other: ______________________ Decided by: __________ Date: ________

### Q4B. Are emails matched without case?
An official may type `Rahim.Store@Gmail.com` for `rahim.store@gmail.com`, at login or when a retail user is added. **Cases:** AUTH-028, RTL-015.

| | Option | Effect |
|---|---|---|
| [ ] | A. The backend matches without case | Login works in any case; adding the same address in other capitals answers `409` |
| [ ] | B. The backend matches exactly | The app lowercases every email before sending |

Other: ______________________ Decided by: __________ Date: ________

### Q6. May a new password be the same as the current one?
**Cases:** AUTH-063.

| | Option | Effect |
|---|---|---|
| [ ] | A. Refused by the backend with `403 policy_denied` | The app also refuses it before sending: "Choose a password different from the current one." |
| [ ] | B. Accepted | No change |

Other: ______________________ Decided by: __________ Date: ________

### Q12B. Is `Retry-After` always a whole number of seconds?
**Cases:** ERR-025, ERR-027.

| | Option | Effect |
|---|---|---|
| [ ] | A. Always seconds, on every `429` | The app keeps reading seconds only; the answer to Q12A covers a missing header |
| [ ] | B. It may be an HTTP date | The app also reads a date and counts down to it |

Other: ______________________ Decided by: __________ Date: ________

### Q19B. Does the server accept only Latin digits (0–9) in a serial or hidden code?
**Cases:** PROF-035, LOOK-026 … -036.

| | Option | Effect |
|---|---|---|
| [ ] | A. Latin digits only | Q19A decides what the app does with Bangla digits |
| [ ] | B. Bangla digits accepted too | The app sends them as typed |

Other: ______________________ Decided by: __________ Date: ________

---

## Part 2 — Client

### Q1. The certificate: when is it built?
`final.md` §13.3 describes a PDF certificate from a valid or warning result. It is not built. **Cases:** LOOK-068 … -088 (21, blocked).

| | Option | Effect |
|---|---|---|
| [ ] | A. In v1, with the client's layout | The client sends the layout and branding (§20.3); release waits for it |
| [ ] | B. In v1, with a plain layout now; the client's layout later | Built from the design tokens (§13.3 allows this); LOOK-087 waits for the layout |
| [ ] | C. After v1 | §13.3 moves to Future (§20.4); its cases stay blocked and leave the release criteria |

Other: ______________________ Decided by: __________ Date: ________

### Q2. The language switch: when, and who writes the Bangla texts?
The switch (Profile, §13.8) is not built, and only the app title is in Bangla; about 470 texts are missing. **Cases:** PROF-006, -018 … -035, HIST-044 (20, blocked).

| | Option | Effect |
|---|---|---|
| [ ] | A. In v1; the client sends all Bangla texts by: ________ | Release waits for the texts and a Bangla reader's check (PROF-034) |
| [ ] | B. Built in v1 but hidden until the texts are complete | English only at release; the switch appears in an update |
| [ ] | C. After v1 | §13.8 language and §16 Bangla move to Future |

Other: ______________________ Decided by: __________ Date: ________

### Q14. Should screens with a first password or a result be hidden from screenshots and the app-switcher preview?
Today they are visible like any app. **Cases:** SEC-012.

| | Option | Effect |
|---|---|---|
| [ ] | A. Only "… was added" (the first password shown) | That screen blocks screenshots and shows a blank preview in recent apps |
| [ ] | B. The whole app | Every screen; officials cannot screenshot a result to share it |
| [ ] | C. No change | §12 stays as it is |

Other: ______________________ Decided by: __________ Date: ________

### Q15. Dark mode
§12.1 stores a "theme" preference, but no dark theme is designed and the app has none. **Cases:** NFR-020.

| | Option | Effect |
|---|---|---|
| [ ] | A. Light only | The theme preference is removed from §12.1 |
| [ ] | B. A dark theme, following the phone's setting | A dark design is needed (Figma); every screen is checked in both |
| [ ] | C. Later | Moves to Future |

Other: ______________________ Decided by: __________ Date: ________

### Q17. The certificate's language
**Cases:** LOOK-088.

| | Option | Effect |
|---|---|---|
| [ ] | A. English always | Same certificate for every official |
| [ ] | B. The app's language | Needs a Bangla font in the PDF (bundled TTF, §2.2) |
| [ ] | C. Both on one certificate | Longer layout; part of the client's layout (Q1) |

Other: ______________________ Decided by: __________ Date: ________

---

## Part 3 — App Owner

### Q4A. Which email addresses does the app refuse before sending?
Today: spaces around the address are removed; an address without `@` is refused ("Enter a valid email address"); anything else is sent, and an unknown address answers "Email or password is incorrect.". **Cases:** AUTH-027, -029, -030, RTL-014.

| | Option | Effect |
|---|---|---|
| [ ] | A. Keep today's rule | Cases written as today's behaviour |
| [ ] | B. A full format check (`name@domain.tld`, no spaces inside) | `a@b`, `a@@b.com`, `official@` refused before sending |

Other: ______________________ Decided by: __________ Date: ________

### Q5. A login answer with an unknown status
Today: not logged in; the Login screen stays. **Cases:** AUTH-036.

| | Option | Effect |
|---|---|---|
| [ ] | A. "Something went wrong. Try again." with the reference; logged as an app defect | One general message |
| [ ] | B. "This app version cannot finish the login. Update the app." | A new text; points the official to an update |

Other: ______________________ Decided by: __________ Date: ________

### Q7. "Call the office" on a phone without a dialler (a tablet)
**Cases:** AUTH-084.

| | Option | Effect |
|---|---|---|
| [ ] | A. "No phone app found. Call {phone}." | Like the mail message |
| [ ] | B. The Call button is hidden where calls are not possible | The number is still shown as text |

Other: ______________________ Decided by: __________ Date: ________

### Q8. Secure storage that cannot be read at start
Today: the phone ID is not replaced (§6.1 forbids a new one on an error); the screen is not defined. **Cases:** SESS-025.

| | Option | Effect |
|---|---|---|
| [ ] | A. The start screen shows an error, the reference, and Try again | Nothing is replaced; the official retries or contacts support |
| [ ] | B. Treated as a new install: a new phone ID, Login, an emailed code | Changes the §6.1 rule for this one case |

Other: ______________________ Decided by: __________ Date: ________

### Q9. A profile without a permissions list
Today: read as no permission, "No features yet". **Cases:** ROLE-012.

| | Option | Effect |
|---|---|---|
| [ ] | A. Keep today's behaviour | The case is written as today |
| [ ] | B. A broken answer: the start screen shows an error with Try again | The official is not shown "No features yet" by mistake |

Other: ______________________ Decided by: __________ Date: ________

### Q10. A bulk send cut off by a lost connection, Android back, or closing the app
The items may already have been checked and recorded. Today: nothing is sent again by itself. **Cases:** BULK-024, -025.

| | Option | Effect |
|---|---|---|
| [ ] | A. The list stays, with "The connection dropped. The items may have been checked: look in History before sending again." | Like a report cut off (REP-015); no double checks by mistake |
| [ ] | B. The list stays with the plain connection message; Send again allowed | Simpler; may record every item twice |
| [ ] | C. The list is cleared | The official builds it again |

Other: ______________________ Decided by: __________ Date: ________

### Q11. Camera or gallery access denied while adding a report photo
**Cases:** REP-040.

| | Option | Effect |
|---|---|---|
| [ ] | A. "Camera access is off. Allow it in Settings to add photos." (and the same for photos), with **Open settings** | Like the scanner |
| [ ] | B. Nothing shown; the photo is not added | No change |

Other: ______________________ Decided by: __________ Date: ________

### Q12A. A `429` without a usable `Retry-After`
Today: a 60-second countdown; nothing is retried by itself. **Cases:** ERR-025, -027.

| | Option | Effect |
|---|---|---|
| [ ] | A. Keep the 60-second countdown | The case is written as today |
| [ ] | B. "Too many attempts. Try again later." with no countdown; a retry is allowed at once | The server decides again on the next try |

Other: ______________________ Decided by: __________ Date: ________

### Q13. The offline banner: when is it built?
§14.2 lists an offline banner; it is not built. **Cases:** ERR-036 … -046 (11, blocked).

| | Option | Effect |
|---|---|---|
| [ ] | A. In v1 | Its 11 cases run before release |
| [ ] | B. After v1 | §14.2 marks it Future; each screen keeps its own connection message (as today) |

Other: ______________________ Decided by: __________ Date: ________

### Q16. A certificate that cannot be made (no space left, a font error)
**Cases:** LOOK-083.

| | Option | Effect |
|---|---|---|
| [ ] | A. "Something went wrong. Try again." | The general message |
| [ ] | B. "The certificate could not be made. Try again." | A new text |

Other: ______________________ Decided by: __________ Date: ________

### Q18. The language at the first start
**Cases:** PROF-030.

| | Option | Effect |
|---|---|---|
| [ ] | A. The phone's language when it is Bangla, otherwise English | No choice needed for most officials |
| [ ] | B. English until the official chooses | Same start for everyone |
| [ ] | C. Asked once at the first start | One extra screen before Login |

Other: ______________________ Decided by: __________ Date: ________

### Q19A. Bangla digits (১২৩) typed into a serial or hidden code
**Cases:** PROF-035.

| | Option | Effect |
|---|---|---|
| [ ] | A. Refused with the format message | The official retypes with 0–9 |
| [ ] | B. Read as 0–9 before checking and sending | A Bangla keyboard works as is (the code normalizer converts them) |

Other: ______________________ Decided by: __________ Date: ________

### Q20. The §14.1 component list against what is built
`final.md` §14.1 named components; some were built under other names (`ErrorBanner` and `FailureBanner` for `AppErrorState`) and some were not built (none since final.md v2.0). **Settled 2026-11-16 by final.md v2.0 (option A): §14.1 lists the built set only.** Before it, AppIconButton, AppCard, AppProductCard, AppLoading, AppSkeleton, AppScaffold, AppDialog, PermissionGate and NetworkStatusBanner were listed and not built. The full list: [15-ui.md, section G](test-cases/15-ui.md#g-component-inventory). **Cases:** UI-159.

| | Option | Effect |
|---|---|---|
| [x] | A. §14.1 is changed to the built set | The spec lists `ErrorBanner`, `FailureBanner`, `GradientHeader`, `AppLogo`, `PasswordRules`, and the plain Flutter widgets used; nothing is rebuilt |
| [ ] | B. The code follows §14.1 | The missing components are built and the screens moved onto them; renames where only the name differs |
| [ ] | C. Per component | Decided row by row in section G |

Other: ______________________ Decided by: __________ Date: ________

### Q21. The colour of a chosen segment or chip
**Decided 2026-11-15: A.** The theme's `secondaryContainer` is `primary` and `onSecondaryContainer` is `onPrimary`: a chosen segment (Serial | Hidden code), a chosen chip (the History result chips, the Filters sheet), and tonal icon buttons (History Filters, a photo's remove) are navy with white text.

Today: the chosen side of Serial | Hidden code (Verify, Bulk lookup) and a chosen filter chip are filled light lavender (#DDE1FF), a colour Material makes from the navy; it is not one of the tokens, and the Figma has no segmented control or chip. Every other Material colour is a token (TC-UI-018). **Cases:** UI-018, UI-087, UI-101, UI-111. For reference, the Figma History chips ("All 47") are navy with white text, as in option A.

| | Option | Effect |
|---|---|---|
| [x] | A. Navy fill, white text (`primary`, `onPrimary`) | The strongest mark, like the main button; no new token |
| [ ] | B. A light navy token (`primary` at 12 %, added to the tokens) | Close to today's look, from the brand colour |
| [ ] | C. Grey fill, navy text (`surfaceMuted`, `primary`) | Quiet; the chosen side is told mostly by its text colour |

Other: ______________________ Decided by: __________ Date: ________

---

## After a Decision

1. **Spec:** a row in `final.md` §19 Decision log (from #46), and the section the question names updated.
2. **Cases:** "Spec gap n" in the Expected column replaced by the decided behaviour; a blocked feature moved to Future (§20.4) when it is postponed.
3. **Tests:** the automated test added or changed; the app changed where the decision needs it.
4. **Sheet and README:** the Summary row here set to "Decided (option)", and the question moved to a "Settled" list in [test-cases README §7](test-cases/README.md#7-open-questions-spec-gaps).
