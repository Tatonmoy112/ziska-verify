# Figma Matching Plan

The app's screens are matched to the 12 Figma screens in `figma/`, one screen group per step. Figma is a look-and-feel reference only: `final.md` and the backend documents (`docs/protectb-api/`, the backend team's ProtectB documents) decide what a screen shows and does. Every Figma element is either adopted, or left out for a reason recorded below and in `final.md`.

Status on 2026-11-15: steps 1 to 7 are done; step 8 (closeout) is next.

| | |
|---|---|
| Test cases | 790 (606 automated, 132 by hand, 52 blocked) |
| `flutter test` | 1043 passed (138 goldens; CI runs the other 905) |
| `flutter analyze`, `dart format` | Clean |

## Decisions (2026-11-15)

- **Splash:** takes the Figma Landing look. There are no intro pages, so the page dots are not shown.
- **Profile counts:** three cards, **Checks · Valid · Not verified** (not verified = not found + not in a batch).
- **History:** result chips with counts. A chosen chip is navy with white text, which closes decision sheet Q21 (option A).
- **Field names:** stay **Serial** and **Hidden code**, not Figma's "Label ID" and "Sequence #".

## Figma Screen to App Screen

| Figma screen | App screen | Step | Status |
|---|---|---|---|
| Landing Page | Splash | 1 | Done |
| Login | Login | 1 | Checked; no change needed |
| Request for id | Request access | 2 | Done |
| scan by barcode | QR scanner | 3 | Done |
| Home page | Verify tab | 4 | Done |
| product history | History | 5 | Done |
| batch details by id | History, serial search (tracking log) | 5 | Done |
| 11 _ Profile 1 | Profile | 6 | Done |
| verification loader | Loader | 7 | Done |
| verified product, already verified product, invalid product | Result screens | 7 | Done |

## Not Adopted, and Why

| Figma shows | Why it is not in the app | The app shows instead |
|---|---|---|
| A Batch tab | No batch endpoint; "batch details by id" is item tracking | History, serial search |
| Scan Label ID / Scan Sequence barcode tiles | Only QR codes are scanned (final.md decision 38; backend D41) | One Scan QR code card |
| "Label ID" / "Sequence #" | User decision; final.md names | Serial / Hidden code |
| IP address, city | Backend D16 | Nothing |
| "Uses 1/3" | Backend D31: no uses limit | "Checked before" and the check number |
| "Already verified" / "Invalid" | A check answers valid, warning, not_found, or unassigned only | The backend's result words |
| Last login | `GET me` does not send it | Nothing |
| "Last changed 32 days ago" | No password date in any answer | Nothing |
| User ID under the name ("auth.verifier_2284") | `GET me` has no user name; the user ID is the email (backend D13) | The email |
| Profile menu (top right) | It would hold nothing that is not already on the screen | Nothing |
| "1–2 business days" | Neither final.md nor the backend promises a time | Steps without a time |
| Landing page dots | No intro pages | The progress (or the error with **Try again**) |
| A second torch button | One torch control is enough | The torch in the scanner's bottom bar |

## Done: Steps 1 to 7

### Step 1: Splash in the Figma Landing look
- **Splash:** a dot pattern, the logo on a white card, "Track & Trace" and "Product Verification System", and a navy glow at the bottom. The glow holds "Verify genuine products instantly" and the progress, or the error with **Try again** (a white button).
- **Login:** no change. EMAIL with an envelope icon (backend D13) and **Forgot password?** differ from Figma by design.
- **New:** `PatternBackground`, the `display` text style, a colour option on `ReferenceText`.
- **Cases:** TC-UI-169 and TC-UI-170.

### Step 2: Request access
- **New HOW IT WORKS card**, with three numbered steps:
  1. Send your request.
  2. Your office checks it.
  3. Receive your login.
- **Please include:** two columns of details (one column at large text sizes).
- **Buttons:** Email the office, Call the office and Back to login stay.
- **New:** `NumberedStepRow`.
- **Cases:** TC-UI-086 (updated) and TC-UI-171.

### Step 3: QR scanner
- **Camera view:** the camera is dimmed in navy around a square scan window with green corners and a moving scan line. The line holds still with the phone's "Remove animations" setting.
- **Text:** **PLACE THE QR CODE INSIDE THE FRAME** above the window; "Looking for a QR code · hold steady" below it.
- **Bottom bar:** **Enter manually** (back to Verify with the field focused) and the torch.
- **Tests:** flow tests run with animations off.
- **Cases:** TC-UI-094 and -095 (updated); TC-UI-172 to -174.

### Step 4: Verify tab
- **Decoration:** a faint honeycomb on the header and a large faint QR corner on the Scan QR code card.
- **Icon:** a hidden code shows a tag icon everywhere (Verify, Bulk lookup, History).
- **New token:** `onPrimaryFaint`.
- **Case:** TC-UI-087 (updated).

### Step 5: History
- **Result chips with counts:** the counts stay the same when a chip is picked. With a chip picked, a one-check request without the result counts them.
- **Filter sheet:** keeps way, dates and Everyone's checks. Reset keeps the search and the chip.
- **Rows:** serial and badge; product and batch; "Today · 4:02 PM"; a grey sentence; the way and the reference.
- **Tracking log:** an ITEM card, then TRACKING LOG with checks numbered 01, 02, ….
- **Q21 closed:** chosen segments and chips are navy with white text.
- **Cases:** TC-HIST-047, TC-HIST-048, and the updated History cases.

### Step 6: Profile
- **Layout:** the identity card reaches into the navy band, with the avatar over its top edge and the role as a green pill.
- **Counts:** Checks / Valid / Not verified, from `GET checks` with `limit=1`.
  - Shown only with `history:own` or `history:all`.
  - Grey bars while loading; **Try again** on failure.
  - Asked for again when the tab comes back and on pull to refresh.
- **Cases:** TC-UI-130 (updated), TC-UI-175 to -178, TC-PROF-036 to -040.

### Step 7: Loader and result polish
- **Loader:** a filled navy shield, a filled green tick for the done step, and a navy dot for the waiting steps.
- **Result icon:** a soft halo of its colour on every result.
- **Case:** TC-UI-165 (updated). The result-card cases check the halo.

## Next: Step 8, Closeout

### 8.1 final.md
1. **New section, "Figma reference: adopted and not adopted":** the screen map and the Not Adopted table above, so the gaps are documented in the spec, not only here.
2. **New decisions 50 to 54** in the decision list, worded as decided:
   - **50:** the Splash takes the Figma Landing look, without intro pages.
   - **51:** the QR scanner layout. Enter manually returns to Verify with the field focused; one torch, in the bottom bar; the scan line holds still with "Remove animations".
   - **52:** History result chips with counts. They count without the result filter (a `limit=1` request when a chip is picked) and replace the totals line; the sheet keeps way, dates and scope.
   - **53:** a chosen segment or chip is navy with white text (Q21, option A).
   - **54:** Profile check counts from `GET checks?limit=1` for profiles with History. They are asked for again when the tab comes back.
3. **Check** that §9.4, §13.1.2, §13.4, §13.7, §13.8 and §13.9 read as one consistent description, with no leftover "totals line", "lavender" or "first-password note" wording.

### 8.2 Test documents
1. **`docs/test-cases/15-ui.md`, section F ("Figma by eye", TC-UI-147 … -158):**
   - Each manual case names the differences that are by design. For example, TC-UI-148 Login: EMAIL and Forgot password.
   - The tester then notes only real look differences.
2. **`docs/test-cases/README.md`:** a progress row for the Figma matching work, with the case counts.
3. **`docs/test-plan.md`:**
   - **§12.1:** bug rows for the problems found during the work:
     - the History row-numbering crash;
     - the History reference not at the row end;
     - the Profile avatar over the title;
     - the Splash and scanner spacing tokens.
   - **Status line:** the final totals.
4. **`docs/manual-test-checklist.md`:**
   - Session A19 ("Figma by eye") gets the same by-design notes as 8.2.1.
   - New device checks:
     - the scan line and "Remove animations";
     - the History chips;
     - the Profile counts.
5. **Recount** the cases and run the document checks: the counts table, the traceability IDs, the manual cases against the checklist, and the links.

### 8.3 Verification
1. `dart format --output=none --set-exit-if-changed lib test`
2. `flutter analyze`
3. `flutter test`, and `flutter test --exclude-tags golden` as CI runs it.
4. **On the emulator** (`flutter run --flavor mock --dart-define-from-file=config/mock.json`): each of the 12 Figma screens beside its app screen.

## Open Items That Need a Decision

| # | Item | Found | Proposed |
|---|---|---|---|
| 1 | `android:allowBackup` is not set in the Android manifest, so Android may back up the app's stored data, including the encrypted login session, and restore it on a reinstall or a new phone | Step 3, on the emulator | Set `android:allowBackup="false"` and add backup rules that leave out the secure storage |
| 2 | The launcher icon (`ic_launcher`) is still Flutter's default logo; Android's own launch screen shows it | Step 1 | Replace it with the client's logo when supplied, or a placeholder from the drawn Ziska mark now |
| 3 | At 2× text the Profile email breaks mid-word ("…example.co / m") | Step 6 | Let the email shrink to fit or wrap only at the "@" and "." |
| 4 | With no filters set, an empty History says "No check matches these filters." | Step 5, on the emulator | A separate empty text when no filter is set, such as "No checks yet." |

## Known Limits of the Postman Mock

- **History:** its first-page example is matched only by the full example URL (result, way, dates and search all set). An ordinary History request gets the "later page" example: an empty list with no totals. So the History rows and the Profile counts show only in the automated tests, not on the emulator.
- **Login:** the answer varies between examples: a direct login, an emailed code, or a forced password change.
- **Session at start-up:** the profile check at start can end the session, which then shows Login.
