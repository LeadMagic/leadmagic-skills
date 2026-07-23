# AGENTS.md — LeadMagic Skills

Guidance for AI agents editing or using this repository.

## Purpose

Official **product** skills so agents can call LeadMagic correctly:

- REST API (`https://api.leadmagic.io`, `X-API-Key`)
- Enrichments (email, people, company, mobile, …)
- Bulk jobs / CSV uploaders (`POST /bulk/submit`, …)
- Hosted MCP (`https://mcp.leadmagic.io/mcp`)
- Credits, auth, and safe integration patterns

This repo does **not** document how LeadMagic’s own apps are built.

## Skill map

| Skill | Purpose |
|-------|---------|
| `leadmagic` | Entry router — load this first when the goal is unclear |
| `api-auth-credits` | Keys & credits |
| `email-enrichment` | Email find/validate / B2B Profile |
| `people-search` | V3 people search |
| `people-enrichment` | B2B Profile / mobile / role |
| `company-enrichment` | Company / funding |
| `bulk-jobs` | Async bulk + uploaders |
| `mcp-integration` | MCP setup |

## Editing rules

1. **No secrets** — examples use `$LEADMAGIC_API_KEY` or `YOUR_API_KEY` only.
2. **No customer PII** or raw enrichment payloads in references.
3. **Docs are source of truth** — [leadmagic.io/docs](https://leadmagic.io/docs). Credit tables here are typical; confirm on the docs site.
4. **Frontmatter:** `name` matches folder; `description` required (what + when); `SKILL.md` ≤ 500 lines; put tags under `metadata.tags`.
5. Install path is `skills/*` only.
6. Prefer **B2B Profile** wording over third-party brand names in skill copy.
7. Follow [Claude skill authoring best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices).

## Related public repos

- [LeadMagic/leadmagic-openapi](https://github.com/LeadMagic/leadmagic-openapi)
- [LeadMagic/leadmagic-cursor-plugin](https://github.com/LeadMagic/leadmagic-cursor-plugin)

## Workspace context

When editing skills from the `all-repos` workspace, product toolchain pins live in [`../leadmagic/STACK.md`](../leadmagic/STACK.md) and [`../../docs/00-overview/stack-policy.md`](../../docs/00-overview/stack-policy.md). This skills repo does not pin pnpm/Next — keep examples API/MCP-focused.
