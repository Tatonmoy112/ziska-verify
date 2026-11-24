# Release backlog outside the mobile contract migration

Updated 2026-11-23. These items are intentionally separate from the implemented D56-D63 app migration.

| Item | Dependency / acceptance |
|---|---|
| Staging acceptance | **Run 2026-11-22** against `https://testapp.protecb.com` (`ziska-test`): all 11 steps done (`docs/staging-integration-2026-11-22.md`). Still needed from the backend: [the backend fix list](backend-requests/2026-11-22-backend-fix-list.md) (test data first); never use a live client |
| Code-point lengths on the test server | The backend documents code points for every length (DEC-429), but on 2026-11-23 the test server still counted an emoji as 2 in a request's name and a retail search. When it runs DEC-429, merge `hold/code-point-lengths` and rerun the checker's `signup-probe` and `lengths` |
| Crashlytics | **Staging on 2026-11-24**: the Firebase project `ziska-verify` holds the staging Android app; its four values are in `config/staging.json`; a test crash from the staging release on the emulator reached Firebase (upload answered 200). Crashlytics only: no Analytics, no Cloud Messaging (TC-SEC-039). No Gradle plugin is needed: FlutterFire sets `RequireBuildId` false. Still to do: **live**, a production Firebase project of its own, its Android app `com.ziskapharma.trackandtrace`, its values in `config/live.json`; for readable native (Java/Kotlin) stack traces of R8 builds, the Crashlytics Gradle plugin with mapping upload, which needs the Google Services file; **iOS** on a Mac; restrict each API key in Google Cloud to its package and signing SHA-1; the privacy notice. Earlier, **code ready** (production audit P-10): `FirebaseCrashReportingService`, on only in a staging or live release build given the `FIREBASE_*` values (final.md §17); without them the no-op service, and the app builds and runs as before. Needed from Ziska: a Firebase project with the Android apps `com.ziskapharma.trackandtrace.staging` and `com.ziskapharma.trackandtrace` (and the iOS apps). Then: (1) put the six values in `config/staging.json` and `config/live.json`; (2) add the Crashlytics Gradle plugin, which writes the build ID Crashlytics needs on Android, and check that a release build starts and a test crash arrives; (3) for obfuscated builds, upload the Dart symbols (`--split-debug-info`, `firebase crashlytics:symbols:upload`); (4) iOS: the dSYM upload script, on a Mac; (5) say in the privacy notice that crash reports go to Google |
| iOS flavors and device run | Mac/Xcode, signing and mock/staging/live schemes |
| Device/release checks | Camera permissions/torch/lifecycle, process-kill recovery, OS back, gallery metadata, release log inspection, larger sessions |
| Store release signing | The client decides who owns the upload key; then the keystore and `android/key.properties` (git-ignored; steps in `docs/run.md`, "Release signing"). The build already reads that file when it exists (2026-11-19); until then the debug key, fine for testing only |
| Bangla review | The client's Bangla reader reviews all 327 texts in `docs/bangla-drafts-for-review.md` (TC-PROF-034) and confirms or corrects each; the client also confirms open questions 18 (English at the first start) and 19 (Bangla digits read as 0–9) |

Done since 2026-11-16 (kept here for the record):

| Item | Done |
|---|---|
| Postman mock | 2026-11-18: a mock of the 2026-11-17 collection, `PostmanMockRouting`; `docs/postman-mock-setup.md` |
| App icon and launch screen | 2026-11-19: the Ziska Pharma logo replaces Flutter's default |
| Offline banner | 2026-11-19: `NetworkStatusShell` above every screen (TC-ERR-037…045); TC-ERR-036 on a phone |
| Date filter day boundary | 2026-11-23: answered by the backend (whole UTC days); the app asks for the UTC days a Bangladesh day overlaps and keeps the rows inside it (TC-HIST-051 … -054) |
| Password postponement (Not now) | 2026-11-23: withdrawn by the backend (D65); removed from the app with its route, fields, Profile reminder and mock demo |
| Language switch | 2026-11-19: Profile → Language, English and বাংলা, kept on the phone; every text drafted in Bangla (TC-PROF-019…035 automated; TC-PROF-006, -018, -032, -034 on a phone) |

Certificates, hidden-code entry, everyone scope and app retail administration are withdrawn requirements, not blocked release features. Preserve historical decisions in the architecture archive and use the migration acceptance document for current behavior.
