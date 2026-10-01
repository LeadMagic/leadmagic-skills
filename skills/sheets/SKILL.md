---
name: sheets
description: "LeadMagic Sheets (Sheet Enrichment) end to end — getting a workspace started in the app, then driving the same live sheet from an AI client over the hosted MCP: create or import a sheet, add enrichment, AI, API, formula and JSON columns, quote and run them with confirmation, read results, and save the build as a reusable recipe. Use when the user mentions a sheet, Sheet Enrichment, a spreadsheet of leads, enriching rows or columns, an AI or API column, a recipe or template, or wants an agent to work inside their LeadMagic sheet."
license: MIT
compatibility: "Requires the hosted MCP at mcp.leadmagic.io (OAuth) and a paid LeadMagic plan with Sheets enabled for the workspace."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs/mcp/setup?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, sheets, sheet-enrichment, spreadsheet, enrichment, ai-columns, recipes, mcp, onboarding]
---

# LeadMagic — Sheets

A LeadMagic sheet is a live grid in the app (**Sheet Enrichment** in the sidebar). Each column is either typed data or something that fills itself per row: a LeadMagic enrichment product, an AI prompt, an HTTP API call, a formula, or a field pulled out of another column's response. The hosted MCP drives the **same** sheet the user has open — every write shows up in their browser live.

**The app is home; the agent is a co-pilot.** Keys (Vault), integrations, billing, recipes with secrets, and reviewing results all live in the app. Send the user there for those, and use the MCP to build columns, fill rows, and run things on their behalf.

References in this folder:

- `references/sheets-tools.md` — every Sheets MCP tool, grouped by job, with limits.
- `references/sheet-recipes.md` — recipe (template) format plus ready-to-import recipes.
- `references/formulas-and-ai.md` — the formula language, AI columns on OpenRouter, and seven sheet ideas to build.

## Getting started (person first, then agent)

Walk a new user through this order. Steps 1–3 happen in the app; step 4 plugs in the agent.

1. **Sign up / sign in** — [app.leadmagic.io/sign-up](https://app.leadmagic.io/sign-up?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills). Sheets needs a paid plan: [Settings → Billing](https://app.leadmagic.io/settings/billing?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills).
2. **Make the first sheet** — open [Sheet Enrichment](https://app.leadmagic.io/sheet-enrichment?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills). Drop a CSV on the card, or pick **Paste rows**, **Blank sheet**, **From a recipe**, **Webhook**, or a connected CRM / outbound platform under **More sources**.
3. **Fill one column by hand once** — add an enrichment column (e.g. work email from first name + last name + domain), run it on a few rows, look at the result. This is the "aha" — do it before automating.
4. **Optional: turn on AI columns** — create an [OpenRouter key](https://openrouter.ai/keys), add it under Sheet Enrichment → **Vault**, and make it the default. Details in `references/formulas-and-ai.md`.
5. **Connect the MCP** so an agent can do the rest:
   - Claude Code: install the plugin (`/plugin marketplace add LeadMagic/leadmagic-skills` → `/plugin install leadmagic@leadmagic`), which bundles the MCP, these skills, and an approval hook; or add only the server with `claude mcp add --transport http leadmagic https://mcp.leadmagic.io/mcp`.
   - Cursor / VS Code / Windsurf / other clients: add an HTTP server with URL `https://mcp.leadmagic.io/mcp`.
   - Claude (web/desktop custom connector): URL `https://mcp.leadmagic.io` (no `/mcp`).
   - Complete the OAuth sign-in in the browser and pick the **same workspace** that owns the sheet. No API key goes in the client config. Per-client steps: [mcp.leadmagic.io/clients](https://mcp.leadmagic.io/clients) and the `mcp-integration` skill.
6. **Hand off** — in the AI client: "open my sheet *<name>* and add a column that …". The agent follows the loop below.

**Sheet tools missing from the client?** The tool list follows the workspace's Sheets access. Check the user is on a paid plan, signed into the right workspace during OAuth, then reconnect. A tool call answering 403 "Sheets are not enabled" means the same thing. Never fall back to inventing data.

## Agent operating loop

Always in this order. Use column **keys** (`col_…`) from `get_sheet`, never display names.

1. **Find** — `list_sheets` (the user names a sheet) or `create_sheet` (new; free, returns column keys).
2. **Read the card** — `get_sheet` before any write: columns, keys, what fills each, and how to write this sheet.
3. **Size** — `get_sheet_stats` answers "how many rows are missing an email" without paging. Use `read_sheet_rows` with `columns` + `filter` only when you need values.
4. **Add rows if needed** — `add_sheet_rows` (≤100 per call, values keyed by column key). Correct cells with `set_sheet_cells` (batch ≤500 edits — never one call per cell). For thousands of rows, ask the user to drop the file into Sheet Enrichment instead of streaming rows through chat.
5. **Build columns** — `add_sheet_columns` adds and configures several at once, left to right. Configuring is free and fills nothing.
6. **Try a sample** (for large fills) — `run_sheet_column` with `sample_size: 5`, `also_column_keys` for the dependent columns, `wait_seconds: 45`. Show the user the values (`read_sheet_rows` on those row ids).
7. **Run the rest** — same tool, no `sample_size`. Small runs (a few rows, ≤5 credits) start right away — don't ask the user before filling a handful of new rows. Bigger runs come back `needs_confirmation` + `confirmation_token`: show the summary, and send the identical arguments plus the token **only after the user agrees**.
8. **Follow through** — when a run returns `next_step`, it is the next paid stage of the pipeline: show it, and on approval send `next_arguments` + its token. Don't call separate status/quote tools in between.
9. **Explain gaps** — `list_sheet_run_rows` shows how each row ended (`completed`, `failed`, `insufficient_credits`, no result). Re-run only the failures with `row_state: "failed"`; re-run filled cells only with `force: true` and explicit consent.
10. **Save it** — `export_sheet_recipe` turns a working sheet into a template; `import_sheet_recipe` builds new sheets from it.

## Column kinds

| Kind | Fills from | Cost | Set with |
|---|---|---|---|
| `manual` | typed by user or `set_sheet_cells` | free | `add_sheet_column` |
| `enrichment` | a LeadMagic product + `input_mapping` {product input → column key} | same per-row credits as the matching API product; failed lookups usually free | `add_sheet_column(s)` / `configure_sheet_column` |
| `ai` | per-row `prompt` naming columns as `{Column Name}` | user's own AI key from the Sheets Vault; plus credits for any `leadmagic_tools` it calls | `add_sheet_columns` / `configure_sheet_column` |
| `http` | a saved API request (`provider_id`), row values bound to `{Column Name}` placeholders | no LeadMagic credits; the third-party API's own billing | `save_sheet_http_request` |
| `formula` | expression, e.g. `NAME_FIRST(CLEAN_PERSON_NAME({Full Name}))` — full language in `references/formulas-and-ai.md` | free | `configure_sheet_column` |
| `json` | one field of another column's response (`source_column_key` + `path`) | free | `extract_sheet_json_field` |

### Enrichment products and inputs

| Product | Inputs (map every one the sheet has) |
|---|---|
| `email_finder` | `first_name`, `last_name`, `domain`, `company_name`, `profile_url` |
| `email_validation` | `email` |
| `personal_email_finder` | `profile_url` |
| `profile_search` | `profile_url` |
| `mobile_finder` | `profile_url` |
| `role_finder` | `domain`, `company_name`, `job_title` |
| `job_change_detector` | `profile_url`, `domain`, `company_name` |
| `email_to_b2b_profile` | `email` |
| `b2b_profile_to_email` | `profile_url` |
| `company_search` | `domain`, `company_name` |
| `company_funding` | `domain`, `company_name` |
| `technographics` | `domain` |

- `email_finder` with first name + last name + domain finds far more than a profile URL alone. If the sheet has only a full name, split it with a `json` column on `role_finder`'s `first_name` / `last_name`, or a formula.
- Sheets has **no job-postings product** — use `job-search` / `jobs-hiring-intent` for that.
- After an enrichment column runs, `list_sheet_column_fields` (sample 3) shows its response fields; then `extract_sheet_json_field` adds columns like `company.industry` for free.

### AI columns

- `output_type`: `text`, `category` (with ≥2 `categories`), `number` (`decimals`), `boolean`, `json`.
- `draft_sheet_ai_prompt` turns a plain-language goal into a prompt + output shape for this sheet. It writes nothing.
- AI runs on the user's saved provider key (Sheets → Vault). OpenRouter is the easiest single key: `provider: "openrouter"`, `model` in `vendor/model` form (default `openai/gpt-5.4-mini`). If a run reports `ai_key_required`, send the user to the Vault; never ask them to paste a key into chat.
- `web_search: true` and `leadmagic_tools` make it a per-row research agent. Bound it: `max_steps` (default 10), `max_credits_per_row` (default 5), `max_wall_seconds` (default 150).
- `set_sheet_column_auto_run` (admins only) makes an AI column run on `rowAdded` or `inputsChanged`. Turning it on needs `max_credits` and a confirmation. Enrichment and API columns never auto-run — fill them with `run_sheet_column` after adding rows.

### API (HTTP) columns

1. Find a verified endpoint: `search_sheet_http_catalog` → `get_sheet_http_catalog_endpoint` (with `sheet_id` it binds row inputs). Or build one: `parse_sheet_http_request` (from a cURL) or `draft_sheet_http_request` (from a goal).
2. Keys: `list_sheet_http_credentials` lists keys the user connected in the app (never the secret). Pass `credential_id`. If none fits, send the user to Sheets → Vault — keys never go through chat.
3. `test_sheet_http_request` sends **one** sample call. Show the response.
4. `save_sheet_http_request` with `column_name` (new column) or `column_key` (existing). It asks for confirmation because running it sends each row's values to that host.

## Run controls

- `scope`: `column` (default, the whole column), `selection` (+ `row_ids`), `sheet`. Narrow further with `filter`, `q`, `row_state`, `start_row` / `end_row`.
- `confirm_max_credits` — the user's ceiling; the run is refused if the quote is higher.
- `idempotency_key` — reuse it when retrying the same submission.
- `pause_sheet_run` keeps finished cells and stops charging; resume with `resume_cloud_run`. `cancel_sheet_run` stops for good; unstarted rows are not charged.
- Waiting: pass `wait_seconds: 45` once (`run_sheet_column`, `get_sheet_run`, `list_sheet_runs`) instead of polling.

## Safety rules

1. **Free first**: `check_credit_balance` before paid runs; sample before full runs.
2. **Ask only when the server asks.** Single-record lookups and small runs need no question. When a call returns `needs_confirmation`, never invent a `confirmation_token` and never resend one without the user's explicit yes to *that* summary. Deletes (`delete_sheet_rows`, `delete_sheet_column`), recipe imports with API requests, HTTP saves, and auto-run use the same gate. Deletes are soft: `restore_sheet_rows` / `restore_sheet_column`.
3. Report only values the sheet returned. Empty / no-result cells stay empty — don't fill them from memory.
4. Secrets live in the app's Vault. Never put API keys, AI keys, or personal data into prompts, recipes, or chat.
5. 402 / `insufficient_credits` → [billing](https://app.leadmagic.io/settings/billing?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills) or [auto top-up](https://app.leadmagic.io/settings/auto-top-up?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills), then re-run with `row_state: "insufficientCredits"`. 401 → reconnect OAuth in the client.

## Sheets vs bulk jobs

Use **Sheets** when the user wants to see and iterate on the list, chain several columns (find → validate → classify), or reuse the build. Use **`bulk-jobs`** for a one-shot file in / file out with no grid. Both bill the same per-product credits.
