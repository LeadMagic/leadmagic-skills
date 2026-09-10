---
description: Bulk-enrich a CSV via LeadMagic bulk jobs (credit-safe)
argument-hint: [path/to/file.csv] [product, e.g. email_finder]
---

Bulk-enrich: $ARGUMENTS

Follow `outbound-recipes` recipe 4 and the `bulk-jobs` skill:
1. Inspect the CSV locally: row count, available columns, which product's required fields they map to.
2. Preflight FREE: credit balance + preview cost. Report projected spend (rows × per-row cost) and wait for confirmation.
3. Validate mapping free (`POST /bulk/validate` or MCP). Save the exact submitted row order and original record IDs, submit (`submit_bulk_job` / `POST /bulk/submit`), and bind that manifest to the returned job ID.
4. Poll status ≥45s apart. On completion: download results, pull error rows (free), and report attempted / succeeded / failed / credits spent vs estimate.
5. If credits run out mid-job it pauses — report and resume after top-up.
6. Before merging, follow the `bulk-jobs` identity contract: verify the fetched job ID and every result's `lm_input` against the submission manifest at `row_index`. Stop before any write on a mismatch or ambiguous duplicate. Never zip results onto the original CSV or reuse row indices across jobs. Use the bundled profile checker for single-product profile jobs.
