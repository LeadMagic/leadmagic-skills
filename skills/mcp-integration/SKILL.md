---
name: mcp-integration
description: "LeadMagic hosted MCP setup for Claude Code, Claude Desktop, Cursor, Windsurf, and VS Code. Use when installing the LeadMagic MCP server at mcp.leadmagic.io, configuring OAuth, choosing between MCP and REST, or mapping MCP tools to REST enrichment endpoints."
license: MIT
compatibility: "Requires network access to mcp.leadmagic.io. OAuth by default on the hosted MCP."
metadata:
  author: LeadMagic
  version: "3.1.0"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs/mcp/setup?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, mcp, claude-code, cursor, oauth, enrichment]
---

# LeadMagic — MCP integration

Prefer the **hosted MCP** over hand-rolled `curl` in agent sessions: OAuth (no key in shell history), server-side token handling, and composite tools that replace multi-call chains.

- **URL:** `https://mcp.leadmagic.io/mcp`
- **Setup docs:** [leadmagic.io/docs/mcp/setup](https://leadmagic.io/docs/mcp/setup?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills)
- **Plugin (bundles this + skills + hooks):** [LeadMagic/leadmagic-skills](https://github.com/LeadMagic/leadmagic-skills)

## Config

Claude Code: `claude mcp add --transport http leadmagic https://mcp.leadmagic.io/mcp`

Cursor configuration (other clients use their own formats; consult the setup docs):

```jsonc
{
  "mcpServers": {
    "leadmagic": { "url": "https://mcp.leadmagic.io/mcp" }
  }
}
```

Claude web / desktop custom connector: URL `https://mcp.leadmagic.io` (no `/mcp`). Per-client steps: [mcp.leadmagic.io/clients](https://mcp.leadmagic.io/clients).

New users: sign up at [app.leadmagic.io](https://app.leadmagic.io/sign-up?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills), run one thing in the app (e.g. a first sheet in Sheet Enrichment — see the `sheets` skill), then connect the MCP. OAuth signs the client into a **workspace**; pick the one that owns the user's sheets and credits.

Complete OAuth in the browser on first use. **401 later → reconnect OAuth in the client** (do not add a REST API key to this OAuth configuration). 402 → credits/billing.

## Tool → REST map (core)

| MCP tool | REST equivalent |
|----------|----------------|
| `check_credit_balance` / `preview_cost` | `GET /v1/credits` / `POST /v1/batch/preview-cost` (free) |
| `find_work_email` / `validate_work_email` | email-finder / email-validation |
| `find_personal_email` / `find_mobile_number` | personal-email-finder / mobile-finder |
| `b2b_profile_to_work_email` / `email_to_b2b_profile` | b2b-profile-email / b2b-profile |
| `search_profile` / `enrich_contact` | profile-search (+composite) |
| `search_people` / `find_people_by_role` / `find_company_employees` | v3 people search / role-finder / employee-finder |
| `enrich_company` / `account_intel` / `research_account` | company-search (+composite brief) |
| `find_company_funding` / `get_company_technographics` | company-funding / technographics |
| `find_lookalike_companies` / `list_company_competitors` | v3 lookalike / competitors-search |
| `find_decision_makers` | role/employee composite |
| `find_jobs` / `search_jobs` / `get_job_search_catalogs` | jobs search + free catalogs |
| `get_company_hiring_signals` | `/v1/jobs/companies/{domain}/hiring-signals` |
| `detect_job_change` | job-change-detector |
| `search_google_ads` / `search_meta_ads` / `search_b2b_ads` / `get_b2b_ad_details` | ads endpoints |
| `submit_bulk_job` / `process_attached_csv` / `get_bulk_job_status` | `/bulk/*` |
| `get_account_analytics` | `/v1/analytics/*` (free) |
| `list_sheets` / `get_sheet` / `add_sheet_columns` / `run_sheet_column` / `read_sheet_rows` (+ ~40 more) | Sheets (MCP + app only, no public REST) — see the `sheets` skill |

Sheets tools only appear when the signed-in workspace has Sheets (paid plan). If they're missing, check the plan and the workspace chosen during OAuth, then reconnect.

## Usage rules

- Prefer composites (`account_intel`, `enrich_contact`, `find_decision_makers`) over long primitive chains.
- Free first: `check_credit_balance` + `preview_cost` before expensive or bulk work.
- One record → single tools; CSV/list → bulk path or a sheet; poll `get_bulk_job_status` ≥45s apart.
- Single-record lookups and small sheet runs (≤5 credits) run directly; don't ask first. Bulk jobs, larger sheet runs, imports, pushes, and deletes return `needs_confirmation` + `confirmation_token` first. Show the summary, resend with the token only after the user agrees, and never invent a token.
- Claude Code names plugin-bundled tools `mcp__plugin_leadmagic_leadmagic__<tool>` and hand-added ones `mcp__leadmagic__<tool>`. Permission rules and hooks must match both (the plugin's approval hook does).
- Pass `company_domain` (e.g. `stripe.com`) when identifying companies.
