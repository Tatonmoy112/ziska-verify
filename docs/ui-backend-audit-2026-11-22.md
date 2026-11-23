# Screens against the backend: logic, match and improvements (2026-11-22)

**What this is:** a recheck of every screen of the app, one area at a time. Each area is checked against:
- the backend's documents in `ProtectB-DOCS/mobileApp/` (the API guide, the build guide, the decisions, SRS v1.2);
- `final.md`;
- what the real test server did.

**How each area is checked:**
1. An independent reviewer reads the documents and the code, and lists what it suspects.
2. Every suspect is then checked against the code and the documents (file and line).

**Each finding is one of:**

| Class | Meaning |
|---|---|
| **Mismatch** | The app does something the backend's rules do not allow, or misses something they require. The app must change |
| **Unclear** | The documents do not settle it. A question for the backend or the client |
| **Wording** | A text on screen could mislead |
| **Improvement** | Not wrong, but it would help the user. Each has its impact and effort |
| **Decided** | A known difference the user or the client chose |

Nothing in the app is changed during the audit. The user picks what to fix.

| Step | Area | State |
|---|---|---|
| 1 | Login and staying logged in | **Done** 2026-11-22 |
| 2 | Passwords (forgot, reset, change, Not now) | **Done** 2026-11-22 |
| 3 | Sign up | **Done** 2026-11-22 |
| 4 | One check | **Done** 2026-11-22 |
| 5 | Scanner mode | **Done** 2026-11-22 |
| 6 | Serial stack | **Done** 2026-11-22 |
| 7 | History | **Done** 2026-11-22 |
| 8 | Reports | **Done** 2026-11-22 |
| 9 | Profile and across the app | Next |

---

## Step 1. Login and staying logged in

**Screens:** the splash screen, Login, "Check your email" (the emailed code), a restart while logged in, the logout dialog, the login renewing itself, and a login ended elsewhere.

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 1.1 | A failed save of the new passes can end the login at the next renewal | **Mismatch** | Medium (rare, but the login ends) |
| 1.2 | After a wrong code, the text offers "send the code again", even when the 5 minutes or 5 tries are spent | **Wording** + **Unclear** | Low |
| 1.3 | A refused resend always says "No more codes can be sent" | **Wording** | Low |
| 1.4 | The logout dialog says the next login "needs no emailed code", which is not always true | **Wording** | Low |
| 1.5 | No hint after a login error for someone whose sign-up is still waiting for approval | **Improvement** | High / small |
| 1.6 | A login ended elsewhere (blocked, new role, password reset) lands on Login with no word of why | **Improvement** | Medium / small |
| 1.7 | The splash screen offers only "Try again" when the profile cannot load | **Improvement** | Medium / small |
| 1.8 | The code screen could save taps: send on the 6th digit, clear the field after a wrong code | **Improvement** | Medium / small |
| 1.9 | The fields stay editable while the login is being sent | **Improvement** | Low / small |
| 1.10 | A restart on the code screen goes back to Login without saying why | **Improvement** | Low / small |
| — | "Not now" is not in the backend's documents yet | **Decided** | Confirmed by the client; the backend is building it (fix list item 3) |
| — | "Sign up" (the backend calls it "Request access") | **Decided** | The user's decision of 2026-11-18 (`final.md:253`) |
| — | Email letter case | **OK** | The server ignores it (the email in capitals logged in, 2026-11-22). The field uses the email keyboard with no automatic capital |

### The details

**1.1 A failed save of the new passes can end the login (Mismatch).**
- **The guide** (`app-api-guide.md` §3.4): a renewal gives "a new access pass and a new refresh pass. Store both before anything else … Sending one that was already used ends the login."
- **The app** (`lib/core/services/session/dio_session_service.dart:194-199`, `_storePasses`): it writes both passes to the phone's secure storage first, and only then keeps them in memory.
- **The problem:** if that write fails (a full phone, a broken keystore), the app keeps the *old* refresh pass in memory, which the server has already used. The next renewal sends it again, and the server ends the login on every phone of this official.
- **The fix:** keep the new passes in memory first, then save them. Small; test first.

**1.2 "Send the code again" after a spent code (Wording, Unclear).**
- **The guide** (§3.2): "A code lives 5 minutes and allows 5 tries; after that, start again at §3.1 [login]."
- **The app** (`app_en.arb` `codeWrong`): "The code is wrong or has expired. Check the latest email, or send the code again."
- **Unclear:** the guide does not say whether a resend gives a fresh 5 minutes and 5 tries. **A question for the backend.**
- **Better text, true either way:** "The code is wrong or has expired. Check the latest email, send a new code, or log in again."

**1.3 A refused resend (Wording).**
- **The guide** (§3.2): 3 resends in all, "then 401: start again at §3.1". A 401 can also mean the code request ended.
- **The app** (`verify_code_bloc.dart:124`, `resendLimitReached`): "No more codes can be sent. Log in again."
- **Better text, true for every 401:** "This code can no longer be sent again. Log in again." The action (back to Login) stays.

**1.4 The logout dialog (Wording).**
- **The app** (`logoutConfirmBody`): "This phone stays trusted, so the next login needs no emailed code."
- **The guide:** a phone stops being trusted after a reset (§3.7), or when a 4th phone is trusted (§2).
- **Better:** "This phone stays trusted, so the next login usually needs no emailed code."

**1.5 A hint for someone who just signed up (Improvement, high / small).**
- **What happens today:** a person who signed up gets a login error, "Email or password is incorrect.", until the office approves the request. The server gives the same answer for every case, on purpose (§3.1). The user met exactly this today.
- **The idea:** under the login error, one line that is true for everyone and reveals nothing: "Just signed up? You can log in after the approval email arrives."
- **Why it helps:** it saves retries, and 5 wrong tries lock an account for 15 minutes.

**1.6 A login ended elsewhere (Improvement, medium / small).**
- **What happens today:** when the server ends a login (an admin blocked the official, moved their role or set their password; a reset; a password change on another phone), the app goes to Login silently (`auth_interceptor.dart:131`, `dio_session_service.dart:183`). An official may think the app crashed.
- **The idea:** a neutral one-line notice on Login: "Your login has ended. Please log in again." No reason is given, since the server gives none.

**1.7 The splash screen's only way out (Improvement, medium / small).**
- **What happens today:** when the profile cannot load at start (offline, or "the app is being prepared"), the splash screen offers only "Try again" (`splash_screen.dart:322-329`).
- **The idea:** a second, quieter button, "Log out", so the official can switch account or start over. Logout works even offline.

**1.8 Fewer taps on the code screen (Improvement, medium / small).**
- **What happens today:** "Continue" must be tapped after the 6 digits, and after a wrong code the field keeps the old digits (`verify_code_screen.dart:36-42`).
- **The ideas:**
  - send the code by itself on the 6th digit or a paste;
  - clear the field and put the cursor back after a wrong code;
  - under the field, "The code works for 5 minutes."

**1.9 Fields while sending (Improvement, low / small).** The email, password and code fields stay editable while the request is sent (`login_screen.dart:105-135`, `verify_code_screen.dart:86-92`). This is harmless, since a second send is ignored, but the design system's own fields expect to be locked meanwhile. Pass `enabled: !submitting`.

**1.10 A restart on the code screen (Improvement, low / small).** The code request lives only in memory (by design, `final.md`). After a restart the app shows Login, and logging in sends a new code, which counts toward the 5 logins with a code allowed in 15 minutes. A note on Login, "Log in again to get a new code", would explain it.

### Checked and right
- **The phone ID:** made once (32 random bytes), kept on logout and on errors.
- **Login answers:** the app follows `status` (`logged_in` or `code_sent`). It keeps the code request in memory and saves both passes before going on. `must_change_password` opens the change screen, after a restart too.
- **One message for every wrong login,** with no hint of whether an email exists.
- **Every 429:** waits its `Retry-After` (seconds or a date) with a countdown and the button off. Other errors show the general text and the reference.
- **The code field:**
  - 6 digits only;
  - Bangla digits read as 0–9;
  - a pasted email's code is picked out;
  - the phone's code autofill works.
- **Resend:** the first wait is 60 seconds, then each `Retry-After`. Leaving the code screen drops the code request, and a late answer is ignored.
- **Renewal:**
  - one at a time, retried once;
  - an old request never ends a newer login;
  - the refresh is sent without the access pass;
  - a 401 on refresh logs out to Login.
- **Logout:** a second tap joins the first; the passes are deleted whatever the answer; the phone ID is kept.
- **Logs:** only the route, the status and the request ID; never a pass, a password or a code.
- **Fields:** the login password is never trimmed (128 characters at most); the email is trimmed.

---

## Step 2. Passwords

**Screens:**
- Forgot password (ask for a code);
- Reset password (the code and the new password twice);
- Change password, both from Profile and forced after a login;
- "Not now";
- the password rule's ticks.

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 2.1 | The error says "the rules **below**", but the rules are above it (also in Bangla, and on Sign up) | **Wording** | Medium (sends the official to look in the wrong place) |
| 2.2 | A forced change can be "done" by typing the same password again, so the official keeps a password someone else knows | **Unclear** + **Improvement** | Medium / small |
| 2.3 | Log out on the forced screen shows no spinner, and Save and Not now stay tappable while it runs | **Mismatch** (`final.md:250`: "Log out spins until the login has ended") | Low |
| 2.4 | "Not now" answered 404 (the route is missing) keeps the button, which can never work | **Mismatch** | Low |
| 2.5 | Any 401 on a change reads "The current password is incorrect.", even when the login ended meanwhile | **Unclear** | Low |
| 2.6 | "Send a new code" on Reset has no wait, so quick taps use up the 5 codes allowed in 15 minutes (login codes included) | **Improvement** | Medium / small |
| 2.7 | After too many codes, or the 10-wrong-codes lock, no email comes and nothing says to wait | **Improvement** | Medium / small |
| 2.8 | After a reset, the important notice ("every phone needs the emailed code at its next login") shows for only 4 seconds, and Login starts with an empty email | **Improvement** | High / small |
| 2.9 | The reset screen does not say the code works for 5 minutes; one typo already says "Ask for a new code" though 4 tries are left | **Wording** | Low / small |
| 2.10 | When the answer is lost after sending, a reset or change that worked looks failed; the retry then says "code wrong" or "current password incorrect" | **Improvement** | Low-medium / small |
| 2.11 | The fields stay editable while saving (as in 1.9) | **Improvement** | Low / small |
| 2.12 | After a change, the app could confirm "Your other phones were logged out."; "Not now"'s screen could say it asks again at each login | **Wording** | Low / small |
| — | "Not now" goes against the backend's guide as written ("only the change") | **Decided** | Confirmed by the client; on only when the server allows it |

### The details

**2.1 "The rules below" (Wording).**
- **The text:** `app_en.arb` `passwordRuleBroken` says "The password does not meet the rules below." The Bangla says the same.
- **The layout:** on Reset (`reset_password_screen.dart:91, 105`) and Change, the ticks come under "New password", and the error at the bottom, so the rules are **above** it.
- **What the guide asks** (build guide §4.9): after a 403, "show the three rules again".
- **Better:** "The password does not meet the rules shown above."

**2.2 The same password at a forced change (Unclear, Improvement).**
- **What happens:** a forced change means someone else set the password (guide §3.2; SRS FR-ACC-07). The server accepts the same password as the new one (seen 2026-11-22; backend fix list item 6), and the app does not compare them.
- **The idea:** on the change screen the official types the current password, so the app can say "Choose a password different from the current one" without asking the server. It reveals nothing.
- **Ask the client** whether they want it.

**2.3 Log out on the forced screen (Mismatch, low).**
- **The spec** (`final.md:250`): "Log out spins until the login has ended."
- **The app** (`change_password_screen.dart:229-246`): no spinner, and `busy` (line 128) does not count a running logout. A second tap is harmless.

**2.4 "Not now" answered 404 (Mismatch, low).**
- **The app** (`change_password_screen.dart:67, 104`): it hides the button only on 403. A 404 shows "Not available." and the button stays.
- **The fix:** treat 404 like 403: hide the button and say "Not now is not available for your account."
- This matters only if a server sends `password_change_skippable` before the route exists.

**2.5 A 401 on a change (Unclear).**
- **The guide** (§3.6): "401: the old password is wrong". But a login that ended also answers 401 (§3.3).
- **What happens:** if the admin blocks the official while this screen is open, the app keeps saying "The current password is incorrect." The official can still go Back or log out.
- **A question for the backend:** can the two be told apart?

**2.6 A wait on "Send a new code" (Improvement, medium / small).**
- **What happens:** "Send a new code" goes back to the email step (`reset_password_screen.dart:137-147`), where only a 429 slows it.
- **The guide** (§3.7): at most 5 emailed codes in 15 minutes, login codes included. Past that, no mail comes and the answer is still 200.
- **The idea:** a 60-second countdown, as on the login code screen.

**2.7 When no email comes (Improvement, medium / small).**
- **What happens:** past the code cap, or after 10 wrong codes (the reset closes for 15 minutes), the server answers as usual and no mail comes (guide §3.7).
- **The idea:** a neutral line on Reset: "No email? Wait 15 minutes before asking again. If you remember your password, you can still log in." It reveals nothing about the account.

**2.8 The notice after a reset (Improvement, high / small).**
- **What happens:** the sentence is right, but it is a snackbar that goes in about 4 seconds (`reset_password_screen.dart:57-60`). Then Login starts with an empty email, and at the next login an unexpected "Check your email" appears.
- **The idea:** show it as a lasting note on Login, and fill in the email.

**2.9 The code's 5 minutes (Wording, low).**
- **The texts:** `resetSubtitle` does not say how long the code lasts, and `resetCodeWrong` says "Ask for a new code" after one typo.
- **Better:**
  - "The code works for 5 minutes."
  - "The code is wrong or has expired. Check it, or ask for a new one."

**2.10 A lost answer (Improvement, low-medium / small).**
- **What happens:** `password_cubits.dart` shows "No connection" when the answer is lost after sending, but the password may have changed.
- **The idea:** "It may have worked. Try logging in with the new password."

**2.12 Two small texts (Wording, low).**
- **After a change:** "Your password was changed." could add "Your other phones were logged out." (guide §3.6).
- **"Not now"'s screen:** it says "Choose your own now, or later from Profile.". It could add that the app asks again at each login (`password-change-later.md`).

### Checked and right
- **The password rule:**
  - 8 to 128 characters, counted as characters;
  - a letter of any alphabet, a digit of any script;
  - no control characters;
  - never trimmed.

  The field stops at 128 characters.
- **The ticks:** shown before typing, ticked live. A fourth ("no tabs or line breaks") appears only when broken. The button is off until the rules are met and both passwords match. Show/hide is on every field, and "Repeat" says when they differ.
- **Reset code and email:** the code is 6 digits (Bangla digits and paste read). The email is checked and trimmed.
- **Forgot password:** always the neutral sentence, then Reset with the email kept. A 429 shows a countdown.
- **Reset:**
  - a 401 gives the neutral "wrong or expired" text and "Send a new code", as the guide asks for the lock too;
  - a 403 shows the rules;
  - success goes to Login.
- **Voluntary change:** keeps the refresh pass, stores the new access pass, and stays logged in. A 401 keeps the login. On success Profile reloads and its reminder goes.
- **Forced change:**
  - only this screen opens, and Back is blocked;
  - Log out works;
  - after the change the app opens once the profile loads;
  - a restart brings the forced state back from `GET me`;
  - a renewal that says `must_change_password` reopens it.
- **"Not now":**
  - shown only when the server sends `password_change_skippable`; the mock-only switch is refused on staging and live;
  - 200 stores the new pass and opens the app;
  - 403 hides it with its message and keeps Log out;
  - Profile's reminder follows `password_change_pending`.
- **Second taps** are ignored. Every error shows its reference.

---

## Step 3. Sign up

**Screens and pieces:**
- the roles from the server ("Ask the office for an account" when there are none);
- the form: name, role, password with its ticks, email;
- "Send code", the code, then "Sign up";
- the "Thanks for signing up" screen.

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 3.1 | After "Try again" loads the roles, the old error ("No connection…") stays above a form that works | **Mismatch** | Medium |
| 3.2 | A roles reload drops a running 429 countdown on "Send code" or "Sign up", so the next tap is refused again | **Mismatch** | Low |
| 3.3 | The office contact is still a placeholder in the live settings ("replace-with-office-email"), and staging and mock use example addresses. "Contact the office" would open mail to a non-address, and the app does not refuse a placeholder at start | **Mismatch** + **Unclear** (the client supplies the real contact) | Medium (must be set before release) |
| 3.4 | "Role not found" is recognised by reading the message's words, not its code | **Unclear** (ask the backend for its own code) | Low |
| 3.5 | "A code was sent to the address." is not true for an address that already has an account: no code comes, and the person may loop | **Wording** | Medium |
| 3.6 | "Create your account…" and the button "Sign up" suggest the account exists at once; it exists only after the office approves | **Wording** | High (the user met this) |
| 3.7 | The "Thanks for signing up" screen does not say what happens next (approval email, then the first login asks for an emailed code) | **Improvement** | High / small |
| 3.8 | The Login screen gives no hint for someone who just signed up (same as 1.5) | **Improvement** | Medium / small |
| 3.9 | When the answer to "Sign up" is lost, the retry says "wrong or expired code", though the request may have arrived | **Improvement** | Low / small |
| 3.10 | "Send a new code" can be tapped again at once; past 5 emails in 15 minutes the server sends none and says nothing | **Improvement** | Low / small |
| 3.11 | A long 429 wait on "Sign up" outlasts the code's 5 minutes, so the next try is sure to fail | **Improvement** | Low / small |
| 3.12 | Small things: no spinner while the roles reload; retyping the same email drops the code step; leaving mid-way discards the form without asking | **Improvement** | Low / small |
| — | The name "Sign up" (the backend says "Request access") | **Decided** | The user's decision of 2026-11-18 (`final.md:253`); 3.6 proposes only a clearer subtitle |

### The details

**3.1 The old error stays (Mismatch, medium).**
- **The app** (`request_access_cubit.dart:69-80`): when the roles load, the new state copies the old `failure` and `retryAt`. The copy is meant to keep the "role no longer available" text after a reload, but it keeps every old error.
- **Example:** offline at first, then "Try again" works, and "No connection. Check the internet and try again." still shows over the form.
- **The fix:** keep only the role text.

**3.2 A reload drops the waits (Mismatch, low).**
- **The guide** (§1): over a limit, "429 with Retry-After. Go by that header".
- **The app:** the same success branch does not copy `codeRetryAt` and `submitRetryAt`, though the failure branch does (lines 90-91). After a "role not found", which reloads the roles, a running countdown disappears.

**3.3 The office contact (Mismatch, Unclear).**
- **The settings:** `config/live.json` still has `"OFFICE_EMAIL": "replace-with-office-email"` and `"OFFICE_PHONE": "replace-with-office-phone"`. Staging and mock have `office@example.com` and `+8800000000000`.
- **The app:** it refuses placeholders only in the server address and the client name (`app_config.dart:143`), and shows "Contact the office" whenever the value is not empty (`app_router.dart:229`).
- **The fix:**
  - the client gives the real office email and phone;
  - the app refuses "replace-with" in these two values at start, as it does for the server address.

**3.4 "Role not found" by its words (Unclear, low).**
- **The guide** (§1): "Decide what the app does from `error.code`, never from the message". But §3.9 gives the role's refusal only as `404 not_found "Role not found."`.
- **The app** (`request_access_screen.dart:141-144`): it looks for "role" in the message. If the backend rewords it, the person sees "Not available." instead; the roles still reload.
- **Ask the backend** for its own code, such as `role_not_found`.

**3.5 "A code was sent to the address." (Wording, medium).**
- **The guide** (§3.9): it prescribes this text, but an address with an account gets "a mail saying so … and no code". The user saw that email today.
- **What happens:** the person sees a code field, no code comes, and a guess gets "wrong or expired".
- **A neutral text, true for every address:** "We sent an email to this address. It has your code, or tells you what to do next."

**3.6 "Create your account" (Wording, high).**
- **The texts** (`app_en.arb`): the subtitle is "Create your account. Your office checks it and emails you its answer.", and the button is "Sign up".
- **The guide** (§3.9): the account exists only after the office approves. Until then, login answers "Email or password is incorrect.".
- **Keep the name "Sign up"** (the user's decision), but make the subtitle clear: "Ask for an account. Your office checks the request and emails you the answer."

**3.7 What happens next (Improvement, high / small).**
- **The guide** (§3.9) says:
  - the approval email says the person can log in;
  - the first login on a phone needs an emailed code;
  - the office may change the details;
  - an unanswered request is deleted after 20 days.
- **The idea:** under "Thanks for signing up", add: "You can log in after the office approves your request. The approval email tells you how. Your first login on this phone asks for a code we email you."

**3.9 A lost answer (Improvement, low).** If the network drops after "Sign up" was sent, the request may have arrived; a retry then gets "wrong or expired code". A note could say: "If you got a confirmation email, your request arrived." Sending again only replaces the request.

**3.10 and 3.11 Waits (Improvement, low).**
- **"Send a new code":** a 60-second wait, or the hint "Check spam; asking too often stops the emails for a while."
- **A 429 on "Sign up" longer than 5 minutes:** say that a new code will be needed.

### Checked and right
- **Roles:** in the server's order, name and ID only. An empty list shows "Ask the office for an account."; a failed load shows Try again, never "Ask the office"; the first load shows a spinner.
- **Field order** as the guide asks: name, role, password (with live ticks), email; then "Send code"; then the code and "Sign up".
- **Inputs:**
  - "Send code" is on only when the form is valid;
  - the code is 6 digits (Bangla digits read);
  - the email and the name are trimmed, and the name is kept within 100 as the server counts;
  - exactly the five documented fields are sent.
- **Every answer:**
  - 200: the "Thanks" screen; the password and code cleared;
  - 401: "wrong or expired", the code step kept;
  - 403: the rules shown, everything kept;
  - 404: the role text, the roles reloaded, a gone role cleared;
  - 409: "Try again later", a new code needed;
  - 400: the general text.

  Which refusals keep the code matches the guide.
- **Limits:** separate countdowns for codes and requests, from `Retry-After`; no number built in.
- **Taps and email edits:** second taps are ignored, and leaving mid-way is safe. Editing the email after a code asks for a new code.
- **Routing:** "Back to login" and Back return to Login, and Sign up starts fresh each time. It works without a login.

---

## Step 4. One check

**Screens and pieces:**
- the Check tab: the camera, the serial field, Check and Clear, and the tools under them;
- the "checking" loader;
- the result screen: every result and reason, the product details, the check count, the reference, the picture, and "Report incident".

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 4.1 | **Back from a QR result sends the same QR again** if the pack is still in front of the camera. A second check is recorded, and the official sees "Checked before, check number 2" for their own check | **Mismatch** | **High** (wrong counts the office sees) |
| 4.2 | A lost answer (timeout) shows the same text as "no connection", though the check may already be recorded; checking again then shows a "checked before" the official caused | **Mismatch** (`final.md:224`) | Medium |
| 4.3 | A QR value in lower case is refused as "not a product code", though the backend reads a QR value in capitals | **Mismatch** (minor) | Low |
| 4.4 | A future, unknown result is titled "Unable to check" and offers "Try again", though the check was made and has a reference; trying again records another check | **Wording** | Medium |
| 4.5 | A QR that matched nothing gets only a hint about typing digits ("A serial has digits only…") | **Wording** | Low |
| 4.6 | The 40-character limit for a padded serial is built into the app, not taken from `GET formats`; a 41-character serial is refused with "up to 19 digits", which is confusing | **Unclear** (ask the backend to add it to `formats` or the guide; fix list item 5) | Low |
| 4.7 | While the formats load, the camera says "Looking for a QR code · hold steady" but reads are ignored; a pack held still is never read | **Improvement** | Low / small |
| 4.8 | The result screen offers "Report incident" for a warning the lookup already sent to the office (recalled, expired, damaged, switched off), so officials may file reports nobody needs | **Improvement** | Medium / small |

### The details

**4.1 The same QR sent again after Back (Mismatch, high).**
- **The app** (`verify_screen.dart:203-206`): after the result closes, it forgets the last QR (`_lastRaw = null`) and restarts the camera. The camera's own repeat filter (`DetectionSpeed.noDuplicates`, `scanner_service.dart:38`) also starts over when it restarts.
- **What happens:** if the pack is still in the frame, it is read and sent again.
- **The spec** (`final.md:226`): "nothing is sent again by itself". The guide (§4.2) says `count.this_check` is "this check's number for the item", so an accidental second check changes what the office sees.
- **The fix:** after coming back from a result, ignore the same QR for a few seconds, or until it has left the frame. Test first.

**4.2 A lost answer (Mismatch, medium).**
- **The spec** (`final.md:224`): "a lost answer may have been recorded".
- **The app:** a timeout after sending (`error_mapper.dart:21-24`) and a request that never left both show "Unable to check. Check the connection and try again." (`lookup_messages.dart:25`).
- **The fix:** for a lost answer, say "The answer was lost. The check may have been recorded; checking again counts as another check." The serial stack already warns like this.

**4.3 A QR in lower case (Mismatch, minor).**
- **The backend:** it reads a QR value in capitals (`ProtectB-DOCS/mobileApp/phase-4-lookups.md:59`).
- **The app** (`verification_usecases.dart:56-58`): it sends the QR value as read, then refuses it when it is not in A–Z0–9. So a QR printed in lower case is called "not a product code".
- **The fix:** change the QR value to capitals before checking it. QR values are made in capitals (D32), so this is rare.

**4.4 An unknown result (Wording, medium).**
- **The guide** (§4.2): every answer has a reference.
- **The app** (`app_en.arb` `resultUnknownTitle`): "Unable to check", with "Try again". The body is right: "This result is not known to this app version. Update the app or contact your office."
- **Better:** the title "Unknown result", and no "Try again", since the check was recorded. The same "Try again" on "not in a batch" suggests a retry helps when it does not.

**4.5 A QR that matched nothing (Wording, low).** The not-found card adds "A serial has digits only, up to 19 digits." even when the official scanned a QR (`result_entry_cards.dart:90-91`). For a QR, "Type the serial printed on the label to compare." would help.

**4.8 Reports for warnings (Improvement, medium / small).**
- **The guide** (§6): a lookup with `recalled`, `expired`, `damaged` or `switched_off` "already tells the office by itself".
- **The app:** the result screen shows "Report incident" the same for every result, and the advice "No report is needed for a warning…" appears only on the report screen.
- **The idea:** on such a result, say "Your office was already told by this check." and make Report the quieter button.

### More ideas to improve the Check tab

| Idea | Impact | Effort |
|---|---|---|
| One line saying what to do next for each result. A warning: "Set the item aside; your office was already told." Not found: "This may not be genuine. Set it aside and report it" (Report as the main button). Not in a batch: "Ask your office." | High | Small |
| A short meaning under each reason, e.g. "The batch's expiry date has passed" (the reason chip has a slot for it that is never filled) | Medium | Small |
| A vibration when a QR is read, and a different one for a warning or not found, as Scanner mode already does | Medium | Small |
| The last 3 checks of this run on the Check tab (kept in memory only, as the guide allows) | Medium | Medium |
| The Expires row in amber when the reason is "expired" | Low | Small |
| A Share button next to Copy for the reference number | Low | Small |
| "(Bangladesh time)" after the last-check time | Low | Small |
| On a no-item result, one way back instead of "Try again" and "Back to Check" going to the same place | Low | Small |

### Checked and right
- **Shown data:**
  - every value comes from the documented fields, and an empty name, date or batch shows "—";
  - no picture shows "No picture for this product"; a picture has its loading, error with "Try again", and full-screen view;
  - the serial and the masked code are shown as the server sends them;
  - the reference, with Copy, is on every result;
  - the check count, the last check time (Bangladesh time) and the previous check are shown;
  - an unknown result or reason is never shown as genuine;
  - "not found" and "not in a batch" with only a reference and a result read fine.
- **Inputs:**
  - the serial's length and the QR's length and characters come from `GET formats`, loaded once, with Retry and the 429 wait;
  - spaces and dashes are removed, Bangla digits read, leading zeros allowed;
  - a QR link gives the part after its last `/q/` from any host;
  - a wrong-length QR or a link that is not a product is refused on the phone, and the link is never opened;
  - the field stops at 64 characters, the API's limit.
- **Permissions:**
  - one-item checks for `item:lookup`;
  - Scanner mode and Serial stack for `item:bulk_lookup`;
  - Report and My reports, and the result's Report link, for `incident:report`;
  - an empty state with none;
  - a 403 reloads the profile.
- **Answers:**
  - a 429 counts down and turns Check and Scan again off;
  - "The app is being prepared" for 503 `app_preparing`; "Try again shortly" for a busy server; "Not available" for 404; others show the general text and the reference;
  - a failed scan holds the camera until "Scan again", and nothing is sent by itself.
- **Flow and states:**
  - second taps are ignored, and Back waits while a check runs;
  - the camera stops in the background, on another tab, under a result and under a tool;
  - the loader shows after 300 ms;
  - the offline banner shows;
  - a refused camera permission offers "Open settings", and no camera says to type the serial.

---

## Step 5. Scanner mode

**Screens and pieces:**
- opening: a new session, or resuming a saved one after a crash;
- the camera, each scan's result, and "Already scanned";
- the counters, and the line of reads waiting;
- the waits;
- a session that is full, ended or another official's;
- Finish and its summary, Scan more, Done, and Back.

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 5.1 | **Finish can hang for good** on "Checking the last scans…" if the official opens a scan's result while reads are still waiting | **Mismatch** (bug) | **High** (only Back gets out, and the summary is lost) |
| 5.2 | When a session fills up or closes itself (15 minutes idle), the app moves to a new one and the list and counters drop to 1 with no notice; Finish then shows only the new session | **Unclear** + **Improvement** | Medium |
| 5.3 | After resuming a session of more than 100 products, the summary says "350 products scanned" but lists only the first 100 | **Mismatch** | Medium |
| 5.4 | When the session was another official's, the product in hand is not checked, and nothing says "scan it again" | **Wording** | Medium |
| 5.5 | "N more scans were not checked. Scan them again." goes away at the next scan, does not say which products, and reads "1 more scans" | **Wording** + **Improvement** | Medium / small |
| 5.6 | When loading a resumed session's old scans fails, the banner says "No connection, scan again." with a Scan again button, though no scan was made | **Wording** | Low |
| 5.7 | A timeout says "No connection, scan again.", though the scan may have been counted; scanning again then says "Already scanned" for a product whose result was never seen | **Wording** | Low |
| 5.8 | During a 429 wait the banner says "Try again in N s", but the app sends the scan again by itself; the supervisor may scan twice | **Wording** | Low |
| 5.9 | Without History permission, a saved session from days ago still says "Resumed session"; the first scan then starts a new one | **Wording** | Low |
| 5.10 | "Remaining" reads like products left in the pile; it is how many more the session can take (5,000 in all) | **Wording** | Low |
| 5.11 | On a phone that cannot scan, Scanner mode says "Type the serial instead", but it has no serial field | **Wording** | Low |
| 5.12 | If reading a saved session fails (offline, busy), the only way forward is Retry | **Improvement** | Low / small |
| 5.13 | Without History permission, a product scanned before a crash comes back as "Already scanned" and appears nowhere, so Finish stays off | **Unclear** | Low |

### The details

**5.1 Finish can hang (Mismatch, high).**
- **The spec** (`final.md:186`): after Finish, "the reads already taken are still sent and answered … Then `…/end` is sent".
- **The app:** during Finish, a scan's card can still be opened.
  - Opening it pauses the line (`scan_session_screen.dart:105`).
  - On return the line is resumed only when not finishing (`:113`).
  - The paused line never sends the waiting reads (`scan_session_cubit.dart:273`), so Finish waits for them forever (`:453`).
- **The fix:** resume the line on return during Finish too, or make the cards not tappable while finishing. Test first.

**5.2 A new session starts silently (Unclear, Improvement).**
- **The guide** (§4.3): on `session_full` or `session_ended`, "start a new session and send the scan again in it, without asking". The spec (`final.md:175`) clears the old list.
- **What happens:** the list and the counters drop to 1, and no notice is shown (`scan_session_cubit.dart:334-344`). Only `session_not_yours` shows "A new session started.".
- **The ideas:**
  - say "A new session started (the last one was full or closed after 15 minutes)";
  - better, keep the earlier rows on screen, marked, so Finish shows everything scanned on this visit.

**5.3 The summary after a resume (Mismatch, medium).**
- **The spec** (`final.md:186`): the summary shows "every product with its result".
- **The app:** it lists only the rows already loaded (`scan_session_screen.dart:868`), and "load more" is off once finished (`scan_session_cubit.dart:540`). The count comes from the server.
- **The fix:** load the rest before the summary, or show "Showing 100 of 350" with "Load more".

**5.4 Another official's session (Wording, medium).** The scan is let go (`scan_session_cubit.dart:346-352`) and the text is only "A new session started.". Better: "A new session started. Scan the last product again."

**5.5 Scans not checked (Wording, Improvement).** The count resets at the next scan (`scan_session_cubit.dart:307`), and the text has no singular form. Keep it until a scan succeeds, and say "1 more scan was not checked" or "3 more scans were not checked".

**5.10 "Remaining" (Wording, low).** The guide (§4.3) says `left` is "how many more different items the session can take (5,000 in all)". Better: "Can take" or "Room left".

**5.11 "Type the serial instead" (Wording, low).** Scanner mode reads QR codes only. Better: "This phone cannot scan QR codes. Use Serial stack to type serials."

### More ideas to improve Scanner mode

| Idea | Impact | Effort |
|---|---|---|
| A different sound or vibration for genuine, needs attention and not found (today all vibrate the same) | High | Small |
| A "Needs attention" filter in the list and the summary (warnings, not found, not in a batch) | High | Medium |
| Keep the previous session's rows after a new session starts (see 5.2) | High | Medium |
| On a not-found row, "Report this product" with its reference filled in | Medium | Medium |
| Show the reference on each found product's row (today the row shows the serial) | Medium | Small |
| When the same QR is shown again, a short "already sent" tick instead of nothing | Medium | Small |
| The torch shows when it is on, and is hidden on the summary | Low | Small |
| "Start a new session" next to Retry when a saved session cannot be read (5.12) | Low | Small |

### Checked and right
- **Permissions:** hidden without `item:bulk_lookup`; a 403 reloads the profile and leaves.
- **Starting:** a new UUID is saved before the first scan. Each scan is sent at once with `way: qr` and the session ID, and the answer's session is checked to be the one sent.
- **Shown data:** the six counters come from the server's answer. A repeat shows the first answer, adds no row and changes no count.
- **The pace:**
  - one scan at a time, at most 2 a second;
  - the same QR held still is not sent again;
  - the QR is the part after the last `/q/`.
- **Answers:**
  - a full or ended session moves to a new one and sends the scan again once;
  - 503: "nothing was recorded; scan again";
  - a 429 waits its `Retry-After` and sends the scan again;
  - a 403 says so and leaves.
- **Resume:** a saved session that answers 404, is ended, or is a stack, starts fresh. With History permission, the summary and the scans are read; without it, History is never asked.
- **Leaving:** Back ends the session without waiting, and forgets the list and the ID; the end is sent with no body.
- **After Finish:** Scan more starts a new session, and Done goes back to Check.
- **Pausing:** the line and the camera stop in the background.
- **The camera:** a refused permission offers "Open settings".

---

## Step 6. Serial stack

**Screens and pieces:**
- the text box, and the live count ("N of 50 serials · M repeated, sent once");
- a bad serial named by its place;
- "Check serials", and the results (counters and one row per serial);
- "View this session's checks" and "Start another stack";
- a 503 sent again once, a lost answer, an answer that cannot be read, and the waits.

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 6.1 | After any failed send, the text box stays locked; to change one serial the official must Clear and type all of them again | **Mismatch** | Medium |
| 6.2 | After a lost answer, one tap on "Send the same stack again" sends it, and the app gives no way to check first whether it was recorded; if it was, every serial is checked twice | **Mismatch** + **Improvement** | High / small |
| 6.3 | Going to the background (even pulling down the notifications) cancels the automatic resend after a 503 or a 429, and coming back does not start it again | **Mismatch** | Low (the button still works) |
| 6.4 | A gateway error (502 or 504) is taken as "nothing recorded" and can be sent again at once, though the server may have recorded the stack | **Unclear** (ask the backend) | Low |
| 6.5 | "Recorded, but … could not be shown. See them in History → Sessions" also shows to roles without History, and gives no link | **Wording** | Low |
| 6.6 | During a 503 or 429 the texts say "Try again shortly" or "Try again in N s", though the app sends again by itself; they do not say nothing was recorded | **Wording** | Low |
| 6.7 | A bad serial over 40 characters is told "up to 19 digits"; "Serial 3 (12AB) is not a serial" reads awkwardly | **Wording** | Low |
| 6.8 | When the formats fail to load, the banner says "Nothing was sent; send the stack again", though no stack was sent | **Wording** | Low |
| 6.9 | The 50 is built into the app and its texts; the SRS says 50 in FR-STK-01 but "up to 200" in its overview | **Unclear** (the SRS) | Low |
| 6.10 | Back is blocked while a stack is sent, which can take up to about 105 seconds, with only a spinner on the button | **Improvement** | Low / small |

### The details

**6.1 The locked text box (Mismatch, medium).**
- **The app:** the box is off when `submitted` (`serial_stack_screen.dart:183`), and `submitted` is never turned back off after an error (`serial_stack_cubit.dart:142-159`).
- **The spec** (`final.md:193`): "lock the submitted payload through retries". That is right for a 503, a 429 and a lost answer. For a refusal (400) or a server error (500) the same stack gets the same refusal every time.
- **The fix:** an "Edit stack" button for a refusal, a server error or "not sent". Never for a lost answer, so it is not sent twice by mistake.

**6.2 A lost answer (Mismatch, Improvement, high).**
- **The spec** (`final.md:224`): "a stack then warns before sending again". The warning shows ("These checks may already be recorded. Retrying may record them again."), but one tap sends, with no confirmation and no way to look.
- **The guide** (§4.7): a recorded stack becomes a session of kind `serial` in the sessions list.
- **The idea:** before sending again, a "Check whether it was recorded" link to History → Sessions (the newest stack, with its count), then a confirmation.

**6.3 The background cancels the resend (Mismatch, low).**
- **The app:** `pause()` cancels the timer and `resume()` does not set it again (`serial_stack_cubit.dart:175-180`).
- **What happens:** after a 429 the countdown ends and the box stays locked, with no message. "Check serials" still sends.
- **The fix:** set the timer again on return.

**6.4 A gateway error (Unclear, low).** The guide says "when the answer is not 200, nothing was recorded", which is about the server's own answers. A 504 from a gateway can come after the server recorded the stack. Ask the backend, or treat a 504 like a lost answer.

### More ideas to improve the serial stack

| Idea | Impact | Effort |
|---|---|---|
| The rows that need attention first (warnings, not found, not in a batch), or a filter | High | Small |
| "Check whether it was recorded" after a lost answer (6.2) | High | Small |
| Name a bad serial in the count before sending, with "Remove it" | Medium | Small |
| "Edit stack" after a refusal (6.1) | Medium | Small |
| Copy or share the results as text (serial, result, reference) | Medium | Small |
| Over 50 serials: "send the first 50 now, the rest next" (the guide allows splitting; `final.md:189` refuses it, so the owner decides) | Medium | Medium |
| Accept `;` between serials (lists from some spreadsheets) | Low | Small |
| "Checking 37 serials…" while waiting | Low | Small |

### Checked and right
- **Shown data:**
  - the counters come from the server (no "remaining" for a stack);
  - the rows follow the server's order, each with the serial as sent, its result, product, reference and reasons;
  - a row opens the full result and comes back;
  - the answer is checked against what was sent;
  - an answer that cannot be read counts as recorded and is never sent again.
- **Inputs:**
  - split by spaces, commas, new lines and tabs;
  - Bangla digits read;
  - serials that differ only by leading zeros are one (the first typed is sent);
  - `0` and padded serials up to 40 characters are accepted;
  - the 50 is counted after repeats;
  - a bad serial is named by its place;
  - the digit limit comes from `GET formats`.
- **Permissions:** the screen needs `item:bulk_lookup`, and "View this session's checks" needs `history:own`. A 403 reloads the profile and leaves.
- **Answers:**
  - a 503 is sent again once, after a second, by itself;
  - a 429 waits its `Retry-After`;
  - "Nothing was sent" when the request never left;
  - a lost answer is never sent again by itself;
  - second taps are ignored.
- **Flow:** "Start another stack" starts fresh, and the results stay after opening a row.

---

## Step 7. History

**Screens and pieces:**
- the Checks list: rows, result chips with counts, search, the serial's tracking log, filters and dates, paging, pull to refresh;
- the Sessions view: Open and Ended, the last 7 days, Choose dates;
- a session's checks.

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 7.1 | A filter tapped during a 429 wait on a later page loads the **new** filter's rows with the **old** list's cursor, mixing two lists | **Mismatch** (bug) | Medium |
| 7.2 | In Sessions, "Try again" after a failed later page starts over at page 1 and drops the rows already loaded | **Mismatch** (bug) | Low-medium |
| 7.3 | A serial searched in Bangla digits is not read as 0–9 (as Check does), so nothing is found and the tracking log does not show; the same in the check picker | **Mismatch** (decision N5) | Medium |
| 7.4 | A serial searched with leading zeros lists the right checks, but the item card is hidden (`0001000001` is not `1000001` as text) | **Mismatch** | Low |
| 7.5 | Coming back to History (another tab, or a session's checks) reloads the list: pages after the first are dropped and the place is lost | **Mismatch** (`final.md:199` asks for a refresh, not a loss of place) | Medium |
| 7.6 | A pull to refresh that fails replaces a full list with an error screen | **Mismatch** | Low |
| 7.7 | The dates are sent as Bangladesh days and the screen says nothing about time; if the server reads UTC days, checks made between 00:00 and 06:00 fall on the wrong day | **Unclear** (backend fix list item 4) | Medium |
| 7.8 | A search the server refuses (400) shows "Something went wrong. Try again." and Try again fails again | **Unclear** | Low |
| 7.9 | The tracking log shows "TRACKING LOG" and "N checks"; "Your checks of serial X" is only read to screen readers, so sighted users may think it is every official's log | **Wording** (decision N2) | Medium |
| 7.10 | The tracking count stays the total while the list follows the chosen result chip ("12 checks" above 3 rows) | **Wording** | Low |
| 7.11 | Rows say "Session 7F3C2A10", but no session card shows its ID and the text cannot be tapped | **Wording** + **Improvement** | Low |
| 7.12 | A stack shows one time in the sessions list but "Started" and "Last scan" on its own card | **Wording** | Low |

### The details

**7.1 Two lists mixed (Mismatch, medium).**
- **The guide** (§5): the cursor belongs to the list that gave it ("pass it back as it is").
- **The app:**
  - during a 429 wait, a new filter is only stored (`history_bloc.dart:143-147`);
  - when the wait ends, "retry the next page" runs (`:111-112`), which sends the new filter with the old cursor (`:197-199`).
- **The fix:** load the new filter's first page instead.

**7.2 Sessions' "Try again" (Mismatch).** `sessions_view.dart:68` reloads the first page (`cubit.load`). History's own retry loads only the failed page, as the list's contract says (`app_paginated_list.dart:37`).

**7.3 Bangla digits in the search (Mismatch, medium).**
- **The decision** (`final.md`, N5): "Bangla digits in a serial are read as 0–9", and the backend counts only 0–9 (fix list item 5).
- **The app:** the search is sent as typed (`history_bloc.dart:96`), and the tracking log checks `^\d+$`, which matches 0–9 only (`history_screen.dart:231`).
- **The fix:** read Bangla digits as 0–9 before searching, as the Check tab does.

**7.4 Leading zeros (Mismatch, low).** The server finds the same checks for `0001000001` and `1000001`, but the item card shows only when the text is equal (`history_screen.dart:360`). Compare without the leading zeros.

**7.5 Coming back loses the place (Mismatch, medium).**
- **The app:** every return to History refreshes it (`history_screen.dart:68-72`), including the Back from a session's checks. The refresh keeps only the first page, and Sessions shows its loading skeleton again.
- **The idea:** refresh quietly and keep the loaded rows and the scroll.

**7.7 Dates (Unclear, medium).** This waits for the backend's answer (fix list item 4). Then: if Bangladesh days, add "Times in Bangladesh time" under the dates; if UTC days, the app sends the right range.

**7.9 "Your checks" (Wording, medium).**
- **The decision** (`final.md`, N2): a searched serial shows "Your checks of serial X", "never suggesting other officials' checks".
- **The app:** that sentence is only the screen reader's label (`history_screen.dart:369`), and the screen shows "TRACKING LOG".
- **The fix:** show "Your checks of serial X" on screen.

### More ideas to improve History

| Idea | Impact | Effort |
|---|---|---|
| Date shortcuts: Today, Yesterday, Last 7 days, This month | High | Small |
| A row opens its details, with "Report a problem" (the check linked) | High | Medium |
| Day headings: Today, Yesterday, then the date | Medium | Small |
| A "Needs attention" chip (warnings, not found, not in a batch together); the API takes one result, so it needs several requests or a filter on the phone | Medium | Small-medium |
| The session's short ID on its card, and the row's "Session …" opens it | Medium | Small |
| Share or export the loaded list or a session's checks as text (own checks only) | Medium | Medium |
| "Times in Bangladesh time" under the dates, once item 4 is answered | Medium | Small |
| The empty Sessions view says "in the last 7 days" and offers "Choose dates" | Low | Small |

### Checked and right
- **Rows:**
  - every field of a row is shown, as the SRS asks (FR-HIS-04);
  - not-found rows without a product are handled;
  - reasons show only on warnings;
  - an unknown result or way is safe;
  - older rows checked by hidden code still show.
- **Filters and requests:**
  - counts come from the first page only;
  - no `scope` is sent, and empty filters are left out;
  - 50 a page;
  - the search waits for typing to stop (400 ms);
  - Sessions leaves its 7-day default to the server.
- **Paging:** goes on until `next_cursor` is empty. An empty last page ends cleanly. A failed later page keeps the loaded rows in Checks, and an old answer is dropped.
- **Permissions:** the History tab and a session's checks are hidden without `history:own`, and the stack's "View this session's checks" too.
- **Answers:**
  - a 429 counts down, and Retry and pull wait;
  - network, busy and server errors say so with the reference;
  - a 403 reloads the profile;
  - empty lists say "no checks yet" or "no match".
- **Display:** "Checked by …" is always the official's own name, and times are in Bangladesh time. Checks and Sessions keep the filters.

---

## Step 8. Reports

**Screens and pieces:**
- the report: the note, "Link one of your checks", "Choose a retail user", photos (camera or gallery, up to 3), "File report" and Done;
- a report opened from a check's result;
- My reports and a report's details.

### Findings

| # | Finding | Class | Severity or impact / effort |
|---|---|---|---|
| 8.1 | **Back leaves the report screen without asking**, so photos not yet sent, and a typed note, are lost. Back while filing: the report is filed, but its photos are never sent and an error is thrown | **Mismatch** | **High** |
| 8.2 | **A photo sent just after the 15-minute pass expired always fails once**: the app renews the pass and sends again, but the photo's bytes were already used, so it says "Not sent" with a working network | **Mismatch** (bug) | Medium |
| 8.3 | "The report may have been filed" leads only to My reports: the note and the photos picked are dropped, and My reports cannot add photos to a report, though the server allows it for an hour | **Improvement** | Medium / medium |
| 8.4 | A refused photo shows only "This photo was refused.", not the server's reason ("The photo must be at most 1 MB.", "The file is not a JPEG or PNG photo.", "Report not found.") | **Wording** | Low |
| 8.5 | The check picker says "Your checks appear here after your first check." when a search finds nothing | **Wording** | Low |
| 8.6 | A server error (500/503) while filing offers "File report" again, though the report may have been saved; a second tap could make a second report | **Unclear** (ask the backend) | Low |
| 8.7 | Photos waiting their turn look like photos with nothing to do; after a 429 they wait until the official taps the 429 photo | **Improvement** | Medium / small |
| 8.8 | After the photo hour is over, Done still says photos "can be sent again", though they cannot | **Wording** | Low |
| 8.9 | The retail search field limits what is seen, and the search is then cut again in another unit, with no sign | **Mismatch** (minor) | Low |
| 8.10 | With no retail users at all, the picker says only "No retail user found", so officials keep searching | **Wording** | Low |
| 8.11 | "Report 1042 filed." here, "#1042" in My reports | **Wording** | Low |
| 8.12 | "…already sent to your office by the lookup" may not hold if the client switches a kind of warning off (SRS FR-INC-02) | **Unclear** | Low |
| 8.13 | "1 MB" is counted as 1,048,576 bytes; the backend does not say whether it means 1,000,000 | **Unclear** | Low |

### The details

**8.1 Back without asking (Mismatch, high).**
- **The guide** (§6.2): "When a photo fails with 503 or a lost connection, keep it and send it again". The spec (`final.md:234`): "Done asks before leaving photos that are not sent".
- **The app:** only Done asks (`report_incident_screen.dart:91-121`). The screen has no Back guard, while 6 other screens have one.
- **What happens on Back while filing:** the request still files the report, then the app starts the photo sending on a closed screen (`report_incident_bloc.dart:319`). That throws an error, and the photos are never sent.
- **The fix:**
  - Back asks the same question as Done;
  - the screen cannot be left while filing;
  - an "is the screen still open?" check before going on after the answer.

**8.2 A photo after the pass expired (Mismatch, medium).**
- **The app:** a photo is sent as a one-time stream (`api_client.dart:61`). On `401 token_expired` the app renews the pass and sends the same request again (`auth_interceptor.dart:91`), but the stream was already read, so the second try fails as "no connection".
- **When it happens:** the access pass lasts 15 minutes, so this hits the first photo after a quiet spell. Tapping the photo again works.
- **The fix:** send the bytes themselves, which can be sent again.

**8.3 "May have been filed" (Improvement, medium).**
- **The app:** after a lost answer, the button goes to My reports (`report_incident_screen.dart:327-334`), and the note and photos are dropped.
- **The guide** (§6.2): photos can be added "within 1 hour of filing".
- **The ideas:**
  - keep the draft in memory and offer it back;
  - on My reports, "Add photos" on the official's reports under an hour old with fewer than 3 photos.

**8.4 The reason a photo was refused (Wording, low).** The app shows the server's text only for a 409 (`report_incident_screen.dart:149-158`). For a 400, 404 or 415 it shows "This photo was refused.". Showing the server's reason, as the guide's table gives it, would help.

**8.6 A server error while filing (Unclear).** The guide says "nothing was recorded" for lookups and stacks, but says nothing about a 5xx when filing (§6.1). The app lets the official file again (`report_incident_bloc.dart:320-322`). Ask the backend, or treat a 5xx as "may have been filed".

### Checked and right
- **My reports:**
  - rows and details show only documented fields: number, time, note, photo count, check, retail user;
  - no photo thumbnails, since the app cannot download photos;
  - 50 a page, with the cursor sent back as given;
  - empty, error, retry and 429 handled;
  - New report refreshes the list.
- **The note:** counted in code points to 1,000, without the spaces around it; File report is off when empty; trimmed before sending.
- **Photos:**
  - made at most 2,048 pixels on the longer side, JPEG quality 85 (75 or 65 only if over 1 MB); PNG, HEIC and WebP are turned into JPEG, upright;
  - **location and other details are really removed:** the picker does not ask for them, and the re-encoding keeps none. No test checks this yet;
  - sent as the file itself, with its type and size, one at a time, up to 3, within the hour;
  - the same photo again is shown once ("That photo is already on the report.");
  - a 409 shows the server's text; a busy server or a lost connection can be tapped to send again; a 429 counts down.
- **Filing:**
  - filed once (a second tap is ignored);
  - a lost or unreadable answer is "may have been filed" and is never filed again;
  - a 404 says whether the check or the retail user is gone, and a gone retail user is cleared;
  - a 429 waits;
  - offline before sending lets the official try again.
- **Permissions:** both screens need `incident:report`. The check picker needs `history:own` and shows only the official's own checks. Report from a result links its check.
- **Retail picker:** the search waits for typing to stop; it has paging and masked emails; a search typed during a 429 is sent when the wait ends.
- **Texts:** "Up to 3 photos", "Photo N" and the 1-hour text are true to the backend.

### More ideas to improve Reports

| Idea | Impact | Effort |
|---|---|---|
| Back asks like Done, and the draft (note, links) is offered back (8.1, 8.3) | High | Small |
| Quick reasons ("Label looks fake", "Seal torn", "Selling where it should not") that add words to the note | Medium | Small |
| "Sending photo 2 of 3", and a "waiting" label on photos in line | Medium | Small |
| "Add photos" on a recent report in My reports (8.3) | Medium | Medium |
| On a warning result, "No report needed: your office already knows" next to Report (as 4.8) | Medium | Small |
| From the Check tab, offer the last check of the past few minutes as the linked check | Low-medium | Small |

## Fixed against ProtectB-DOCS e163a52 (2026-11-23)

The backend's docs are the source of truth. These findings are closed:

| # | Finding | How |
|---|---|---|
| 7.7 | Dates | Whole UTC days (guide §4.5, §5): the app asks for the UTC days a Bangladesh day overlaps, keeps the rows inside it, ends the list at the first day, and counts the kept rows (TC-HIST-051 … -054) |
| 4.1 | The same QR sent again after Back | The QR is kept after its result and not read again for 5 seconds (guide §4.3; TC-LOOK-129) |
| 4.3 | A QR in lower case refused | Accepted in either case and sent as read (guide §4; TC-LOOK-128) |
| 8.1 | Back without asking; Back while filing lost the photos | Back asks what Done asks; the screen cannot be left while the report is filing; the photos are sent only while the screen is open, never on a closed one (TC-REP-064, -065) |
| 6.2 | A lost stack re-sent by one tap | "Send the same stack again" asks first: the serials may already be recorded, look in History, then Sessions; only **Send again** sends. A stack never sent goes again at once (TC-MIG-069) |
| 5.1 | Finish can hang | Back from a result opened during Finish lets the line go on, so the reads already taken are sent and Finish ends; the camera stays off. Coming back to the app during Finish no longer starts the camera (TC-MIG-070) |
| 1.1 | A failed save of the renewed passes reused the spent refresh pass | The new passes are kept in memory first; if the phone cannot store them, the renewal still works from memory and the spent pair is deleted from the phone, so neither a later renewal nor a restart sends it (TC-SESS-045) |
| 4.2 | A lost check answer read as "no connection" | A timeout after sending says the answer was lost and the check may already be recorded; a request that never left the phone still says to check the connection (TC-LOOK-060, -130) |
| 7.1 | A filter during a wait mixed two lists | The list remembers the filter its rows and cursor belong to; after the wait, or on the next page, a changed filter loads its own first page (TC-HIST-055) |
| 5.3 | A resumed session's summary listed only the first page | The summary says "Showing X of Y" and loads the rest with **Load more**; reading an ended session's checks is allowed after Finish (TC-MIG-071) |
| 2.4 | "Not now" answered 404 | No longer applies: "Not now" is removed (D65; TC-AUTH-095) |
| Step 3 texts | "Sign up" read as an account made at once | "Request access", "Send request", and the guide's answer text (§3.9; TC-AUTH-118) |
| — | A 409 `conflict` showed the general text | The server's message (guide §1; TC-ERR-051) |

**Held:** the name and the search counted in code points (DEC-429), ready on `hold/code-point-lengths` until the test server runs it.
**Kept as the app's choice:** Bangla digits in a serial read as 0–9 before sending.
