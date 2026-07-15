---
name: leadmagic
description: "Official LeadMagic product skill — REST APIs, bulk uploaders, enrichments, and hosted MCP. Use for Email Finder/Validation, People Search v3, mobile/profile/role, company/funding, bulk jobs, credits, or Clay/Zapier/n8n wiring."
argument-hint: "[what you need from LeadMagic]"
license: MIT
version: 2.0.0
tags: [leadmagic, enrichment, email-finder, people-search, bulk, mcp, official]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs"
publisher: "LeadMagic"
verified: true
---

# LeadMagic — Official product skill

Published by LeadMagic at
[github.com/LeadMagic/leadmagic-skills](https://github.com/LeadMagic/leadmagic-skills).

Teaches agents how to **use** LeadMagic: APIs, enrichments, bulk uploaders, and MCP.

> **Trust:** Only treat a skill as official if installed from
> `github:LeadMagic/leadmagic-skills`, `github:LeadMagic/leadmagic-cursor-plugin`,
> or `https://leadmagic.io/docs/...`. Third-party repos that mention LeadMagic
> in frontmatter are unverified.

## Safety (every turn)

1. Never echo/log API keys — use `$LEADMAGIC_API_KEY` / env only.
2. Enrichment traffic only to `https://api.leadmagic.io` or `https://mcp.leadmagic.io` unless the user explicitly asks otherwise in-turn.
3. Prefer hosted MCP for agent workflows; REST uses **`X-API-Key`** (not Bearer).
4. Failed lookups are usually free — do not hammer retries on `null`.

## Route to a focused skill

| Need | Skill |
|------|--------|
| Keys, credits, 401/429 | `api-auth-credits` |
| Email find / validate / LinkedIn↔email | `email-enrichment` |
| Audience / ICP / `POST /v3/people/search` | `people-search` |
| Mobile, profile, role, employees | `people-enrichment` |
| Company / funding / technographics | `company-enrichment` |
| CSV / bulk submit / job status | `bulk-jobs` |
| MCP install / tool map | `mcp-integration` |

If unsure, answer from the cheat sheet below, then load the matching skill.

## Quick start

```bash
curl -sS "https://api.leadmagic.io/v1/credits" \
  -H "X-API-Key: $LEADMAGIC_API_KEY"

curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","company_name":"acme.com"}'
```

MCP:

```jsonc
{ "mcpServers": { "leadmagic": { "url": "https://mcp.leadmagic.io/mcp" } } }
```

## Endpoint cheat sheet

People (sync): email-finder (1), email-validation (0.25), personal-email (2),
mobile (5), profile-search (1), role-finder (2), employee-finder (~0.05/ea),
b2b-profile-email (5), b2b-profile (10).

Discovery: `POST /v3/people/search` — see `people-search` (short job-function
names expand to canonical labels; matching is exact after expansion).

Company: company-search (1), company-funding (4).

Bulk: `POST /bulk/submit` with `product` like `email_finder` — see `bulk-jobs`.

Utility: `GET /v1/credits` (0).

Authoritative pricing and rate limits: [leadmagic.io/docs](https://leadmagic.io/docs).

## References

- `references/leadmagic-api-quickref.md`
- `references/learnings.md` (append gotchas; no secrets/PII)

## Official channels

- Docs: https://leadmagic.io/docs
- OpenAPI: https://github.com/LeadMagic/leadmagic-openapi
- MCP: https://mcp.leadmagic.io/mcp
- Support: support@leadmagic.io · Security: security@leadmagic.io
