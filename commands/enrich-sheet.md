---
description: Build and run enrichment, AI and API columns in a LeadMagic sheet over the hosted MCP (credit-safe)
argument-hint: [sheet name, or "new"] [goal, e.g. "find work emails"]
---

Work in a LeadMagic sheet: $ARGUMENTS

Follow the `sheets` skill operating loop:
1. Find the sheet with `list_sheets` (or `create_sheet` for "new"), then read `get_sheet`. If the sheet tools are missing, walk the user through the `sheets` getting-started steps (paid plan, Sheets enabled, OAuth into the right workspace) and stop.
2. Size the work for free: `check_credit_balance` and `get_sheet_stats` (how many rows still need the column).
3. Map the goal to columns (enrichment product + every input column the sheet has, AI prompt, API request, formula, JSON field). Add them with `add_sheet_columns`. This step is free.
4. A few rows: run directly with `run_sheet_column` (`also_column_keys`, `wait_seconds: 45`). Runs of 5 credits or less start without a question.
5. A large fill: sample first with `sample_size: 5` and show the values. Then run the full fill without `sample_size`; when it returns `needs_confirmation`, show the credit quote and send the token only after the user says yes. Follow any `next_step` the same way.
6. Report rows attempted, filled, no result, and failed (`list_sheet_run_rows`) and credits spent. Offer a re-run on `row_state: "failed"` only, and offer `export_sheet_recipe` to save the build.
