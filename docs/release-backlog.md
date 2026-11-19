# Release backlog outside the mobile contract migration

Updated 2026-11-19. These items are intentionally separate from the implemented D56-D63 app migration.

| Item | Dependency / acceptance |
|---|---|
| Staging acceptance | Backend HTTPS test host, client slug, fixture accounts/items, mail page, and office portal access; never use a live client |
| Date filter day boundary | Backend confirmation whether inclusive dates denote UTC or Bangladesh calendar days; preserve current date strings until answered |
| Complete Bangla and locale switch | Remaining translations, client language review, persisted preference and locale state; migration strings alone are not complete localization |
| Crashlytics | Registered Firebase projects/platform configs and release-symbol setup; existing no-op service stays until provisioned |
| iOS flavors and device run | Mac/Xcode, signing and mock/staging/live schemes |
| Password postponement (Not now) | The backend team ships `POST me/password/later` and `password_change_skippable`/`password_change_pending` in the guide, Postman and the test server; then `DEMO_PASSWORD_LATER` is removed and TC-AUTH-095 runs on staging |
| Device/release checks | Camera permissions/torch/lifecycle, process-kill recovery, OS back, gallery metadata, release log inspection, larger sessions |
| Store release signing | The client decides who owns the upload key; then the keystore and `android/key.properties` (git-ignored). Until then the debug key, fine for testing only |
| Bangla review | The client reviews `docs/bangla-drafts-for-review.md` and confirms or corrects each text |

Done since 2026-11-16 (kept here for the record):

| Item | Done |
|---|---|
| Postman mock | 2026-11-18: a mock of the 2026-11-17 collection, `PostmanMockRouting`; `docs/postman-mock-setup.md` |
| App icon and launch screen | 2026-11-19: the Ziska Pharma logo replaces Flutter's default |
| Offline banner | 2026-11-19: `NetworkStatusShell` above every screen (TC-ERR-037…045); TC-ERR-036 on a phone |

Certificates, hidden-code entry, everyone scope and app retail administration are withdrawn requirements, not blocked release features. Preserve historical decisions in the architecture archive and use the migration acceptance document for current behavior.
