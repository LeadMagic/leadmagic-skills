# Sheets MCP tools — reference

Every tool takes `sheet_id` (uuid, from `list_sheets` or the sheet URL) where it acts on a sheet, and column **keys** (`col_…`, from `get_sheet`) — never display names. Tools marked **gated** return `needs_confirmation` + `confirmation_token` first; nothing happens until the same arguments are sent again with that token after the user agrees.

Tool names below are the hosted MCP ids. In Claude Code they appear as `mcp__plugin_leadmagic_leadmagic__<name>` (plugin install) or `mcp__leadmagic__<name>` (server added by hand).

`run_sheet_column` runs quoted at 5 credits or less start without a token; larger runs are gated.

## Find and inspect

| Tool | Does | Notes |
|---|---|---|
| `list_sheets` | Workspace sheets: name, id, rows, status | Start here when the user names a sheet |
| `get_sheet` | Column card: keys, what fills each, how to read/write | Read before any write |
| `get_sheet_stats` | Per-column filled / empty / unique / duplicates / run states | Optional `filter` / `q`; cheaper than paging |
| `read_sheet_rows` | Rows as `{row_id, cells}` | `limit` ≤500; `cursor` (unsorted) or `offset` (sorted); `ids` ≤200; `columns` to trim; `sort` ≤3 |
| `list_sheet_column_fields` | Fields inside enrichment/API responses (sampled) | Run after the source column; `sample_size` 3 is enough |

`read_sheet_rows` / `run_sheet_column` filter grammar:

```json
{"type":"group","join":"and","children":[
  {"type":"cond","columnKey":"col_email","op":"empty"},
  {"type":"cond","columnKey":"col_domain","op":"notEmpty"}
]}
```

Ops: `eq`, `contains`, `empty`, `notEmpty`, `hasResults`, `noResults`, `hasError`, `hasNotRun`. Groups nest one level.

## Create and organize

| Tool | Does | Notes |
|---|---|---|
| `create_sheet` | Empty sheet, optional manual columns in order | Free; needs a paid plan; returns keys |
| `update_sheet` | Rename, file in a folder (`null` = unfiled), archive / unarchive | Archived sheets keep their data |
| `import_sheet_recipe` | New sheet from a recipe document | Gated when the recipe carries API requests or webhook sources |
| `export_sheet_recipe` | Current sheet → recipe JSON (keys replaced by named connections) | Stores nothing; `author_name` is a display name, never an email |

## Rows and cells

| Tool | Does | Notes |
|---|---|---|
| `add_sheet_rows` | Append rows `{column_key: value}` | ≤100 per call; ≤4000 chars per cell; returns row ids + `columns_to_fill`; never runs anything |
| `set_sheet_cells` | Edits `{row_id, column_key, value}` | ≤500 per call; live in the user's grid |
| `delete_sheet_rows` | Soft delete by id | Gated; undo with `restore_sheet_rows` |
| `restore_sheet_rows` | Bring back deleted rows | |

## Columns

| Tool | Does | Notes |
|---|---|---|
| `add_sheet_columns` | Add + configure up to 50 columns left to right | Any kind; `after_column_key` to place |
| `add_sheet_column` | Add one `manual` or `enrichment` column | For ai / formula / json: add manual, then configure |
| `configure_sheet_column` | Set what fills an existing column | Kinds: enrichment, http, ai, formula, json, manual (manual = stop filling, values stay) |
| `update_sheet_column` | Rename, hide, or turn an empty manual column into enrichment | |
| `extract_sheet_json_field` | New column reading one field of another column's response | Free; placed after the source by default |
| `reorder_sheet_columns` | Set full left-to-right order | Pass every key from `get_sheet` |
| `delete_sheet_column` | Delete and hide values | Gated; undo with `restore_sheet_column` |
| `restore_sheet_column` | Bring back a deleted column with its values | |
| `draft_sheet_ai_prompt` | Goal → AI prompt + output shape for this sheet | Writes nothing |
| `set_sheet_column_auto_run` | AI column auto-runs on `rowAdded` / `inputsChanged`, or `manual` | Admins only; gated; `max_credits` required; `max_rows`, `existing_value` (`skip` / `fillEmpty` / `overwrite`) |

## Running

| Tool | Does | Notes |
|---|---|---|
| `run_sheet_column` | Quote and run enrichment / AI / API columns | `also_column_keys` ≤9 more; dependents start after their inputs; paid stages gated; returns `next_step` + `next_arguments` for the next paid stage |
| `list_sheet_runs` | Runs on a sheet (progress, credits, status) | `active: true`; `wait_seconds` 45 once instead of polling |
| `get_sheet_run` | One run by id | `wait_seconds` ≤45 |
| `list_sheet_run_rows` | How each row ended (no values) | Use to explain failures |
| `pause_sheet_run` | Pause; finished cells stay, no more charges | Resume with `resume_cloud_run` |
| `cancel_sheet_run` | Stop for good | Unstarted rows not charged |

`run_sheet_column` row selection: `scope` (`column` | `selection` + `row_ids` | `sheet`), `filter`, `q`, `row_state` (`failed`, `insufficientCredits`, `noResult`, `notRun`), `start_row` / `end_row` (1-based), `sample_size` (≤1000), `force` (re-run filled cells), `confirm_max_credits`, `idempotency_key`.

## API (HTTP) columns

| Tool | Does | Notes |
|---|---|---|
| `search_sheet_http_catalog` | Search verified third-party endpoints | `q`, `provider`, `list_providers` |
| `get_sheet_http_catalog_endpoint` | One catalog endpoint: inputs, where the key goes, how to get one | With `sheet_id`, returns a template bound to matching columns |
| `parse_sheet_http_request` | cURL → template | Sends nothing; strip keys from the cURL first |
| `draft_sheet_http_request` | Goal (+ optional `docs_url`) → validated request | Reads the vendor docs |
| `test_sheet_http_request` | Send ONE sample request | Private / internal addresses are refused |
| `save_sheet_http_request` | Save template; attach via `column_name` or `column_key` | Gated; `fields` = response fields offered as columns |
| `list_sheet_http_requests` | Saved requests in the workspace | Never includes credentials |
| `get_sheet_http_request` | One saved request | Secret headers come back as `[stored securely]` — send unchanged to keep |
| `update_sheet_http_request` | Edit in place | Cells made by the old request are marked outdated |
| `list_sheet_http_credentials` | Keys connected in Sheets → Vault (id, provider, label) | Never returns a key; pass `credential_id` |

## Imports, pushes and workflows (low-level)

The `*_cloud_*` tools are the lower-level surface the Sheets tools are built on. Prefer the Sheets tool when one exists (`read_sheet_rows` over `get_cloud_rows`, `run_sheet_column` over `run_cloud_workflow`, etc.).

| Tool | Does |
|---|---|
| `list_cloud_connections` | Workspace CRM connections |
| `list_cloud_crm_objects` / `list_cloud_crm_fields` / `list_cloud_crm_filters` | Discover what a connected CRM can import |
| `import_cloud_crm` / `import_cloud_sequencer` | Import rows from a connected CRM / outbound platform (gated; stable `idempotencyKey` UUID) |
| `list_cloud_imports` / `cancel_cloud_import` | Inspect / cancel imports |
| `list_cloud_campaigns` | Campaigns in a connected outbound platform |
| `push_cloud_rows` / `list_cloud_pushes` | Deliver rows to a connected CRM / outbound platform (gated; deduplicated) and inspect outcomes |
| `list_cloud_workflows` / `create_cloud_workflow` / `update_cloud_workflow` / `quote_cloud_workflow` / `publish_cloud_workflow` | Multi-step per-row pipelines one column runs; quote is free; scheduling needs admin + hard limits |
| `list_cloud_runs` / `get_cloud_run_trace` / `resume_cloud_run` | Inspect workflow runs, per-row node attempts, resume a paused run |

Connecting a CRM or outbound platform happens in the app (Integrations), not over MCP.
