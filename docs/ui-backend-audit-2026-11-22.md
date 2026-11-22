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
| 3 | Sign up | Next |
| 4 | One check | |
| 5 | Scanner mode | |
| 6 | Serial stack | |
| 7 | History | |
| 8 | Reports | |
| 9 | Profile and across the app | |

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
