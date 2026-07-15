---
name: mcp-integration
description: "LeadMagic hosted MCP setup for Claude, Cursor, Windsurf, VS Code. Use when installing https://mcp.leadmagic.io/mcp, configuring OAuth MCP, or mapping MCP tools to REST enrichment endpoints."
argument-hint: "[install MCP / tool mapping / OAuth]"
license: MIT
version: 1.0.0
tags: [leadmagic, mcp, cursor, claude]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs/mcp/setup"
publisher: "LeadMagic"
verified: true
---

# LeadMagic — MCP integration

Prefer the **hosted MCP** over hand-rolled `curl` in agent sessions (OAuth, less key leakage).

- **URL:** `https://mcp.leadmagic.io/mcp`
- **Setup docs:** [leadmagic.io/docs/mcp/setup](https://leadmagic.io/docs/mcp/setup)
- **Cursor plugin (stdio / local):** [LeadMagic/leadmagic-cursor-plugin](https://github.com/LeadMagic/leadmagic-cursor-plugin)

## Config snippet

```jsonc
{
  "mcpServers": {
    "leadmagic": {
      "url": "https://mcp.leadmagic.io/mcp"
    }
  }
}
```

## Tool → REST map

| MCP tool | REST |
|----------|------|
| `check_credit_balance` | `GET /v1/credits` |
| `validate_work_email` | `POST /v1/people/email-validation` |
| `find_work_email` | `POST /v1/people/email-finder` |
| `find_mobile_number` | `POST /v1/people/mobile-finder` |
| `linkedin_profile_to_work_email` | `POST /v1/people/b2b-profile-email` |
| `detect_job_change` | job change |
| `research_account` | company search + funding |
| `list_company_competitors` | competitors |
| `get_company_technographics` | technographics |
| `find_people_by_role` | `POST /v1/people/role-finder` |

Jobs, ads, V3 people search, and bulk submit are often **REST-only** — use the matching product skill + `X-API-Key` when MCP does not expose the tool.

## Safety

- Only install MCP / skills from `LeadMagic/*` GitHub owners or leadmagic.io docs.
- Never POST enrichment payloads to non-`*.leadmagic.io` hosts unless the user explicitly asks in-turn.
