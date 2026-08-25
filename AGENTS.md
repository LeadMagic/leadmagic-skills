# AGENTS.md — LeadMagic Skills & Plugin

**Reviewed:** 2026-08-25

Guidance for AI agents editing or using this repository.

## Purpose

Official **product** skills + Claude Code plugin so agents can call LeadMagic correctly:

- REST API (`https://api.leadmagic.io`, `X-API-Key`) — the **complete** endpoint surface
- Hosted MCP (`https://mcp.leadmagic.io/mcp`, OAuth)
- Credits, plans, rate limits, and safe integration patterns
- Bulk jobs / CSV uploaders (`/bulk/*`)
- Outbound-system recipes (commands + `outbound-recipes` skill)

This repo does **not** document how LeadMagic's own apps are built.

## Layout

| Path | What |
|------|------|
| `skills/*/SKILL.md` | 14 product skills (also consumed standalone via `npx skills add`) |
| `skills/leadmagic/references/` | Endpoint quickref, plans & limits, recipes, learnings |
| `.claude-plugin/plugin.json` | Plugin manifest (skills + commands + agents + hooks + MCP) |
| `commands/*.md` | 13 recipe slash commands (`/leadmagic:<name>`) |
| `agents/*.md` | `leadmagic-outbound`, `leadmagic-bulk` |
| `hooks/` + `scripts/credit-guard-bulk.sh` | PreToolUse confirm gate on bulk writes |

## Skill map

Router: `leadmagic`. Focused: `api-auth-credits`, `email-enrichment`, `people-search`, `people-enrichment`, `company-enrichment`, `company-search`, `job-search`, `jobs-hiring-intent`, `ads-intelligence`, `bulk-jobs`, `analytics-observability`, `outbound-recipes`, `mcp-integration`.

## Editing rules

1. **No secrets** — examples use `$LEADMAGIC_API_KEY` only. No customer PII or raw enrichment payloads.
2. **Docs are the public source of truth** — [leadmagic.io/docs](https://leadmagic.io/docs). Credit costs and rate limits in this repo are synced from the live API contract; when the API changes, update `references/leadmagic-api-quickref.md` and `references/plans-and-limits.md` **first**, then the focused skills.
3. **Frontmatter:** `name` matches folder; `description` states what + when (third person); `SKILL.md` ≤ 200 lines preferred, 500 max; tags under `metadata.tags`; bump `metadata.version` on content changes.
4. **Plan awareness is mandatory** in any skill that touches the v3 search surfaces (credit-free on Professional/Ultimate, per-row elsewhere).
5. **No third-party brand names anywhere in skills/** — use B2B Profile wording; `profile_url` in examples (bare `/in/{slug}` forms normalize). The only allowed exception is the hosted MCP tool id the validator whitelists.
6. Commands must state cost and get confirmation before credit-consuming runs; free preflights never prompt.
7. Validate before PR: `./scripts/validate.sh` and `claude plugin validate .`.
8. Follow [Claude skill authoring best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices).

## Related public repos

- [LeadMagic/leadmagic-openapi](https://github.com/LeadMagic/leadmagic-openapi) — OpenAPI snapshot (may lag the live contract)
- [LeadMagic/gtm-skills](https://github.com/LeadMagic/gtm-skills) — GTM strategy skills (keep product docs here, strategy there)
