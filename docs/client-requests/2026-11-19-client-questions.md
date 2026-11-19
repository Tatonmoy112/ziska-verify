# Questions for Ziska (2026-11-19)

> **Status 2026-11-19: ready to send.** Each question says what the app does today; until you answer, it stays that way.

**From:** the mobile app team. **To:** Ziska Pharmaceuticals. **About:** the Track & Trace app.

The app is built and runs on the test (mock) server. Before it can be released, we need the decisions and materials below from you.

## B5. Check the Bangla texts

The app now switches between English and Bangla (Profile → Language). We drafted every Bangla text ourselves, so a Bangla reader at Ziska should check them.

- **What to do:** go through `docs/bangla-drafts-for-review.md` (326 texts, English beside Bangla). Mark each one as fine or write the correction. Then use the app in Bangla on a phone and note anything that reads oddly.
- **Today:** the drafts are in the app as they are.

## B6. The company name in the copyright line

The bottom of the Login screen reads: "© 2026 Ziska Pharmaceuticals Ltd. All rights reserved."

- **What to do:** confirm the exact legal name, or send the right one.

## B7. The app icon

The icon and the start-up screen show the Ziska Pharma logo, redrawn by us from the logo in the app.

- **What to do:** confirm it, or send the official artwork: a square logo of at least 1024 × 1024 pixels, as PNG or SVG, with a version that works on a white background.

## B8. The live server and the store key

To make the version for real users we need:

- the live server's address and Ziska's client name on it (from the ProtectB backend team);
- the office email and phone number that Sign up offers when no role can be requested in the app ("Ask the office for an account");
- **who owns the app's signing key** for the Google Play Store. The key proves future updates come from you; whoever holds it can publish updates. We suggest Ziska keeps it, and we can make it with you.

**Today:** builds for testing use a temporary key, which works on any phone but cannot go to the Play Store.

## B9. Four choices about the app

| # | Question | Today |
|---|---|---|
| 14 | Should screens that show a first password or a check result be hidden from screenshots and from the recent-apps preview? | Visible, like any app |
| 15 | Is a dark mode wanted? | No dark mode; the app is always light |
| 18 | Which language should the app start in, the first time? | English, until the official chooses Bangla on Profile |
| 19 | If an official types Bangla digits (১২৩) into a serial, should the app accept them? | Accepted: read as 1, 2, 3 |

The options for each are in `docs/decision-sheet.md`.

## B10. Crash reports

The app can send crash reports to Firebase Crashlytics so problems on officials' phones are seen and fixed. This needs a Firebase project owned by Ziska.

- **What to do:** create the Firebase project, or tell us whose account to use, and add us to it.
- **Today:** no crash reports are sent.
