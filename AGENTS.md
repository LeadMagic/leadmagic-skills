# AGENTS.md — LeadMagic Skills

## What this repo is

Official **product** skills for AI agents that call LeadMagic:

- REST API (`https://api.leadmagic.io`, `X-API-Key`)
- Enrichments (email, people, company, mobile, …)
- Bulk jobs / CSV uploaders (`POST /bulk/submit`, …)
- Hosted MCP (`https://mcp.leadmagic.io/mcp`)
- Credits, auth, and safe integration patterns

**Not in scope:** building LeadMagic's internal apps (Workers, Next.js, Hono, etc.).

## Skills to prefer

| Skill | Purpose |
|-------|---------|
| `leadmagic` | Entry router |
| `api-auth-credits` | Keys & credits |
| `email-enrichment` | Email find/validate |
| `people-search` | V3 people search |
| `people-enrichment` | Profile / mobile / role |
| `company-enrichment` | Company / funding |
| `bulk-jobs` | Async bulk + uploaders |
| `mcp-integration` | MCP setup |

## Hard rules for agents editing this repo

1. **No secrets** in commits, skills, or learnings — use `YOUR_API_KEY` / `$LEADMAGIC_API_KEY` in examples.
2. **No customer PII** or raw enrichment payloads in references.
3. **Docs are source of truth** — [leadmagic.io/docs](https://leadmagic.io/docs); keep skill credit tables marked as typical.
4. **Frontmatter:** `name` must match folder; `description` required; keep `SKILL.md` ≤ 500 lines.
5. **Install path:** only `skills/*`.

## Validation

```bash
# CI runs .github/workflows/validate-skills.yml on skills/**
for d in skills/*/; do test -f "$d/SKILL.md" || exit 1; done
./scripts/build.sh
```

## Related repos

- [LeadMagic/leadmagic-openapi](https://github.com/LeadMagic/leadmagic-openapi) — OpenAPI snapshot
- [LeadMagic/leadmagic-cursor-plugin](https://github.com/LeadMagic/leadmagic-cursor-plugin) — Cursor / local MCP
- Product apps live in the all-repos workspace under `repos/leadmagic`, `lm-workers`, etc. — do not confuse those with this skills repo.
