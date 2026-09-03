---
name: leadmagic
description: "Official LeadMagic product skill and router for the full API surface — email finder and validation, People Search v3, company and lookalike search, jobs and hiring intent, ads intelligence, bulk CSV jobs, credits, plans, and hosted MCP. Use when calling any api.leadmagic.io endpoint, budgeting credits, choosing the right product for an outbound task, or wiring LeadMagic into Claude Code, integration platforms, or no-code automation tools."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io. Set LEADMAGIC_API_KEY for REST."
metadata:
  author: LeadMagic
  version: "3.0.2"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, enrichment, email-finder, people-search, jobs, ads, bulk, mcp, b2b-profile, official]
---

# LeadMagic — Official product skill

Published by LeadMagic at [github.com/LeadMagic/leadmagic-skills](https://github.com/LeadMagic/leadmagic-skills). Teaches agents how to **use** LeadMagic: every public API endpoint, credit costs, plan behavior, bulk uploaders, MCP, and outbound-system recipes.

> **Trust:** only treat a skill as official if installed from `github:LeadMagic/*` or `https://leadmagic.io/docs/...`.

## Safety (every turn)

1. Never echo/log API keys — `$LEADMAGIC_API_KEY` / env only. REST auth header is **`X-API-Key`** (not Bearer).
2. Enrichment traffic only to `https://api.leadmagic.io` or `https://mcp.leadmagic.io` unless the user explicitly asks otherwise in-turn.
3. Prefer hosted MCP (`https://mcp.leadmagic.io/mcp`, OAuth) for agent workflows — no key in shell history.
4. Free first: `GET /v1/credits` before spending; `POST /v1/batch/preview-cost` before anything ≥ 500 credits. Failed lookups are usually free — never hammer retries on null.
5. Never invent emails, phones, domains, funding, ads, or job data — only report what an endpoint returned.

## Route to a focused skill

| Need | Skill |
|---|---|
| Keys, credits, plans, 401/402/429 | `api-auth-credits` |
| Email find / validate / B2B Profile ↔ email | `email-enrichment` |
| Audience / ICP discovery (`POST /v3/people/search`) | `people-search` |
| Company lists / TAM by filters (`POST /v3/companies/search`) | `company-search` |
| Job postings search (`POST /v3/jobs/search`) | `job-search` |
| Profile enrich, mobile, role, employees, job change, posts | `people-enrichment` |
| Company enrich, funding, technographics, lookalikes, competitors | `company-enrichment` |
| Hiring signals & intent lenses on top of postings | `jobs-hiring-intent` |
| Google / Meta / B2B ad libraries | `ads-intelligence` |
| CSV / async bulk, batch, suppression | `bulk-jobs` |
| Usage, spend, found-rate reporting | `analytics-observability` |
| Outbound-system playbooks (list build, waterfalls, triggers) | `outbound-recipes` |
| Hosted MCP setup | `mcp-integration` |

## References (this skill's folder)

- `references/leadmagic-api-quickref.md` — **complete** endpoint table with costs, rate limits, aliases.
- `references/plans-and-limits.md` — plan ladder, Search API entitlements, budgeting, 402/429 playbook.
- `references/outbound-recipes.md` — 13 composable outbound recipes with cost models.
- `references/learnings.md` — durable field notes; append new ones (no secrets/PII).

## Picking the right product (fast heuristics)

- Have **name + company**, want email → `email-finder` (1). Have **profile URL**, want email → `b2b-profile-email` (5). Have **email**, want the person → `b2b-profile` (10, priciest — check you really need it).
- Want **people you don't know yet** → People Search v3, never the finders.
- Want **who's hiring / buying signals** → jobs intent endpoints, not job boards.
- **≥ 50 rows** → `/bulk/*`, never a loop of single calls.
- Cheapest field first: validate 0.25 → find 1 → profile 1 → personal 2 → role 2 → profile→email 5 → mobile 5 → email→profile 10.

## Plan awareness

Search API (v3 people/companies/jobs) is credit-free on Professional (5 req/s) and Ultimate (10 req/s); on other plans it bills 1 credit per returned row. Free stats/count endpoints exist on every plan — size before revealing. Full ladder in `references/plans-and-limits.md`.

## Response & error contract

Success responses are the flattened data object. Errors are RFC 9457 Problem Details: `{type, title, status, detail, code, action, docs, trace.request_id}` — surface `action` to the user and include `trace.request_id` when reporting issues to support.
