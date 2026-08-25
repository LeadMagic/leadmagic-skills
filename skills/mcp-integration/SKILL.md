---
name: mcp-integration
description: "LeadMagic hosted MCP setup for Claude Code, Cursor, Windsurf, and VS Code. Use when installing the LeadMagic MCP server at mcp.leadmagic.io, configuring OAuth MCP, or mapping MCP tools to REST enrichment endpoints."
license: MIT
compatibility: "Requires network access to mcp.leadmagic.io. OAuth by default on the hosted MCP."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs/mcp/setup
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, mcp, cursor, oauth, enrichment]
---

# LeadMagic — MCP integration

Prefer the **hosted MCP** over hand-rolled `curl` in agent sessions (OAuth, less key leakage).

- **URL:** `https://mcp.leadmagic.io/mcp`
- **Setup docs:** [leadmagic.io/docs/mcp/setup](https://leadmagic.io/docs/mcp/setup)
- **Cursor plugin (stdio / local):** [LeadMagic/leadmagic-cursor-plugin](https://github.com/LeadMagic/leadmagic-cursor-plugin)

MCP connects by **OAuth sign-in, not an API key** — register the URL alone (a stored
credential or `--header` flag suppresses the sign-in flow), then complete the browser
login. Verify before calling it done: list the tools or run a free call like
"check my LeadMagic credit balance".

## Client setup

**Claude Code** (user scope so it's available in every project):

```bash
claude mcp add --transport http --scope user leadmagic https://mcp.leadmagic.io/mcp
```

Then run `/mcp`, select `leadmagic`, choose **Authenticate**, and sign in.
If a `leadmagic` server already exists, `claude mcp remove leadmagic --scope user` first.

**Claude.ai / Desktop**: Settings → Connectors → **Add custom connector** →
name `leadmagic`, URL `https://mcp.leadmagic.io/mcp` → Connect and sign in.

**ChatGPT**: Settings → Apps → Advanced settings → enable Developer mode →
Create app → name `leadmagic`, connection `https://mcp.leadmagic.io/mcp` → sign in.

**Codex**: add to `~/.codex/config.toml` (leave auth at its default oauth;
don't set `bearer_token_env_var`):

```toml
[mcp_servers.leadmagic]
url = "https://mcp.leadmagic.io/mcp"
```

Restart Codex, then Authenticate in the MCP servers list (or `codex mcp login leadmagic`).

**Generic JSON clients** (Cursor, Windsurf, etc.):

```jsonc
{
  "mcpServers": {
    "leadmagic": {
      "url": "https://mcp.leadmagic.io/mcp"
    }
  }
}
```

Only if OAuth genuinely fails: create an API key at app.leadmagic.io → Settings → API
and send it as an `Authorization: Bearer` header. Never paste keys into chat.

## Tool → REST map

| MCP tool | REST / meaning |
|----------|----------------|
| `check_credit_balance` | `GET /v1/credits` |
| `validate_work_email` | `POST /v1/people/email-validation` |
| `find_work_email` | `POST /v1/people/email-finder` |
| `find_mobile_number` | `POST /v1/people/mobile-finder` |
| `linkedin_profile_to_work_email` | `POST /v1/people/b2b-profile-email` (B2B Profile → work email) |
| `detect_job_change` | job change |
| `research_account` | company search + funding |
| `list_company_competitors` | competitors |
| `get_company_technographics` | technographics |
| `find_people_by_role` | `POST /v1/people/role-finder` |

Jobs, ads, V3 people search, and bulk submit are often **REST-only** — use the matching product skill + `X-API-Key` when MCP does not expose the tool.

## Safety

- Only install MCP / skills from `LeadMagic/*` GitHub owners or leadmagic.io docs.
- Never POST enrichment payloads to non-`*.leadmagic.io` hosts unless the user explicitly asks in-turn.
