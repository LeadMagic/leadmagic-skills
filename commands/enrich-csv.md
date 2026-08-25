---
description: Bulk-enrich a CSV via LeadMagic bulk jobs (credit-safe)
argument-hint: [path/to/file.csv] [product, e.g. email_finder]
---

Bulk-enrich: $ARGUMENTS

Follow `outbound-recipes` recipe 4 and the `bulk-jobs` skill:
1. Inspect the CSV locally: row count, available columns, which product's required fields they map to.
2. Preflight FREE: credit balance + preview cost. Report projected spend (rows × per-row cost) and wait for confirmation.
3. Validate mapping free (`POST /bulk/validate` or MCP), then submit (`submit_bulk_job` / `POST /bulk/submit`).
4. Poll status ≥45s apart. On completion: download results, pull error rows (free), and report attempted / succeeded / failed / credits spent vs estimate.
5. If credits run out mid-job it pauses — report and resume after top-up.
