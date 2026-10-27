# Sheets MCP tools — reference

Every tool takes `sheet_id` (uuid, from `list_sheets` or the sheet URL) where it acts on a sheet, and column **keys** (`col_…`, from `get_sheet`) — never display names. Tools marked **gated** return `needs_confirmation` + `confirmation_token` first; nothing happens until the same arguments are sent again with that token after the user agrees.

Tool names below are the hosted MCP ids. In Claude Code they appear as `mcp__plugin_leadmagic_leadmagic__<name>` (plugin install) or `mcp__leadmagic__<name>` (server added by hand).

Every paid `run_sheet_column` run is gated, including samples, runs of 5 credits or less, and AI billed to the user's own provider key. The first call returns the credit cost and provider billing summary; resend the identical arguments with its `confirmation_token` only after explicit user approval. Only verified free runs (zero LeadMagic credits and no external provider billing) start without a token. Unknown quotes cannot start.

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
| `import_sheet_recipe` | New sheet from a recipe document | API requests are refused; webhook sources are gated |
| `export_sheet_recipe` | Current sheet → recipe JSON (keys replaced by named connections) | Stores nothing; `author_name` is a display name, never an email |

## Rows and cells

| Tool | Does | Notes |
|---|---|---|
| `add_sheet_rows` | Append rows `{column_key: value}` | ≤100 per call; ≤4000 chars per cell; returns row ids + `columns_to_fill`; never runs anything |
| `set_sheet_cells` | Edits `{row_id, column_key, value}` | ≤500 per call; asks before editing live cells |
| `delete_sheet_rows` | Soft delete by id | Gated; undo with `restore_sheet_rows` |
| `restore_sheet_rows` | Bring back deleted rows | |

## Columns

| Tool | Does | Notes |
|---|---|---|
| `add_sheet_columns` | Add + configure up to 50 columns left to right | Manual, enrichment, AI, formula or JSON; `after_column_key` to place |
| `add_sheet_column` | Add one `manual` or `enrichment` column | For ai / formula / json: add manual, then configure |
| `configure_sheet_column` | Set what fills an existing column | Kinds: enrichment, ai, formula, json, manual (manual = stop filling, values stay) |
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
| `run_sheet_column` | Quote and run enrichment / AI columns | `also_column_keys` ≤9 more; dependents start after their inputs; paid stages gated; returns `next_step` + `next_arguments` for the next paid stage |
| `list_sheet_runs` | Runs on a sheet (progress, credits, status) | `active: true`; `wait_seconds` 45 once instead of polling |
| `get_sheet_run` | One run by id | `wait_seconds` ≤45 |
| `list_sheet_run_rows` | How each row ended (no values) | Use to explain failures |
| `pause_sheet_run` | Pause; finished cells stay, no more charges | — |
| `cancel_sheet_run` | Stop for good | Asks before changing the run; unstarted rows not charged |

`run_sheet_column` row selection: `scope` (`column` | `selection` + `row_ids` | `sheet`), `filter`, `q`, `row_state` (`failed`, `insufficientCredits`, `noResult`, `notRun`), `start_row` / `end_row` (1-based), `sample_size` (≤1000), `force` (re-run filled cells), `confirm_max_credits`, `idempotency_key`.

## API (HTTP) columns

Configure and run custom HTTP columns in the LeadMagic app. They are unavailable over hosted MCP.

## Integrations, workspace runs, and saved lists

Connecting a CRM or outbound platform happens in the app (Integrations), not over MCP. Once connected, these tools take only their own named fields:

| Tool | Fields | Notes |
|---|---|---|
| `list_cloud_connections` | none | Connected CRMs and outbound platforms |
| `list_cloud_crm_objects` | `crm_platform` | A CRM connected in the workspace |
| `list_cloud_crm_fields` / `list_cloud_crm_filters` | `crm_platform`, `object` | `object` from `list_cloud_crm_objects`, e.g. `contacts` or `Lead` |
| `import_cloud_crm` | `crm_platform`, `object`, `fields` (`[{field, label?}]`), `idempotency_key`; optional `list_view_id`, `lifecycle_stage`, `name`, `max_rows` | **Gated**; new sheet |
| `list_cloud_campaigns` | `platform`; optional `search`, `limit` | An outbound platform connected in the workspace |
| `import_cloud_sequencer` | `platform`, `campaigns`, `fields`, `idempotency_key`; optional `name`, `max_rows` | **Gated**; new sheet |
| `list_cloud_imports` / `cancel_cloud_import` | `sheet_id`; cancel also takes `import_id` | |
| `list_cloud_runs` | `sheet_id`; optional `status`, `column_key`, `active_only`, `limit`, `offset` | |
| `pause_cloud_run` / `cancel_cloud_run` | `sheet_id`, `run_id` | `run_id` from `list_cloud_runs` |
| `list_cloud_pushes` | `sheet_id`; optional `status`, `destination`, `limit`, `offset` | Delivery status only |
| `list_prospect_lists` | `list_type` (`people` default, or `company`) | |
| `get_prospect_list` / `export_prospect_list` | `list_type`, `list_id` | |
| `create_prospect_list` | `list_type`, `name`; optional `description`, `rows` | `rows` exactly as `search_people` / `search_companies` returned them |
| `add_prospect_list_members` | `list_type`, `list_id`, `rows` | |
| `update_prospect_list` | `list_type`, `list_id`, `name` and/or `description` | |
| `remove_prospect_list_members` | `list_type`, `list_id`, `member_ids` | **Gated** |
| `list_saved_searches` | `search_type` (`people` default, or `company`) | |
| `get_saved_search` / `rerun_saved_search` | `search_type`, `search_id` | |

Generate one `idempotency_key` (a UUID) per import and resend it unchanged on a retry.
