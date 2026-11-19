# Retail-user picking

Updated 2026-11-16. Retail creation, role administration, and emailing first passwords from the app are withdrawn. Their old TC-RTL cases are historical, not release gates.

Current behavior: an official with incident:report opens the picker from a report, searches active retail users by name/email, sees backend-masked email addresses, pages with an opaque cursor, selects or clears one optional retail_user_id, and files the report. The backend rejects unavailable/blocked users without exposing which condition applied. Existing reports retain their chosen user.

Coverage is retained in the incident/report flow and contract tests. Account creation and password administration belong to the office portal. Public applicants instead use the access-request cases in [16-mobile-migration.md](16-mobile-migration.md).
