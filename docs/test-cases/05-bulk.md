# Checking many items - scanner sessions and serial stacks

Updated 2026-11-16. The former TC-BULK scenarios for collecting 500 mixed inputs and POST lookups/bulk are retired. Current cases are TC-MIG-012 through TC-MIG-028 in [16-mobile-migration.md](16-mobile-migration.md).

Scanner mode sends each QR immediately with a UUID, displays the backend result/repeat/counters, keeps rows only in memory, ends on either Back action, and recovers through the saved UUID and permitted history reads. No scan list is submitted later.

Serial stacks accept at most 50 distinct typed/pasted serials. A submission creates one ended serial session; no chunking or mixed QR/hidden-code list exists. Retry confirmed failed requests with the same payload; transport uncertainty is explicit and never automatically replayed.

Both flows require item:bulk_lookup. Neither requires item:lookup. Own session browsing/recovery-history reads independently require history:own.
