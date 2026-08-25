---
name: jobs-hiring-intent
description: "LeadMagic job postings search and company hiring-intent signals — jobs search v3, hiring signals, hiring velocity, tool mentions, intent lenses (GTM, sales, security, AI adoption, expansion), salary bands, and bulk domain sweeps. Use when finding open roles, ranking accounts by hiring signals, detecting tool-stack or expansion intent, or building trigger-based outbound."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, jobs, hiring-intent, signals, triggers, outbound]
---

# LeadMagic — Jobs & hiring intent

Hiring activity is the strongest public buying signal. This surface turns job postings into rankable account intelligence.

## Job search

For **searching job postings themselves** (`POST /v3/jobs/search` — vector/facets/deep modes, cursors, export), use the dedicated **`job-search`** skill. This skill covers the *signal* layer built on top of postings.

Legacy single search still exists: `POST /v1/jobs` (Jobs Finder, 1 credit, 300/min) with filters `company_domain`/`company_name`, `job_title`, `keywords`, `location`, `experience_level` (accepts `entry|mid|senior|executive` and synonyms like `jr`, `vp`, `director`), `has_remote`, `min_employees`/`max_employees`, `posted_after`; free catalogs at `GET /v1/jobs/countries|regions|industries|company-types|job-types`. Free metadata: `GET /v1/jobs/meta/freshness`, `GET /v1/jobs/tags`, `POST /v1/jobs/tags/facets`.

## Per-company signals (1 credit each, 200/min)

| Signal | Endpoint |
|---|---|
| Composite hiring-intent snapshot | `GET /v1/jobs/companies/{domain}/hiring-signals` |
| Recent openings | `GET /v1/jobs/companies/{domain}/recent-jobs` |
| Tools named in job posts | `GET /v1/jobs/companies/{domain}/tool-mentions` |
| Hiring by function | `GET /v1/jobs/companies/{domain}/function-mix` |
| Hiring rate over time | `GET /v1/jobs/companies/{domain}/hiring-velocity` |

Options: `since_days`, `include_evidence`, `evidence_limit` (≤5).

## Intent lenses — `POST /v1/jobs/company-intent/{intent}`

Body `{"company_domain": "acme.com"}` (+ optional `filters`, `tools`, `tags`).

| 1 credit | 2 credits |
|---|---|
| `gtm`, `sales`, `marketing`, `revops` | `ai-adoption`, `security`, `cloud-modernization`, `data-modernization`, `expansion`, `contraction`, `tool-stack`, `lookalikes`, `job-embedding-similarity`, `target-title-similarity` |

Also: `POST /v1/jobs/companies/expansion-signals`, `/salary-bands` (2), `/hiring-benchmark` (2 — compare hiring vs `peer_domains`, ≤25).

## Bulk sweeps (1 credit per domain, 50/min)

`POST /v1/jobs/bulk/company-intent` · `/bulk/hiring-signals` · `/bulk/tool-mentions` — body `{"domains": ["a.com", …]}` (≤100). The cheapest way to rank a whole account list weekly.

```bash
curl -sS -X POST "https://api.leadmagic.io/v1/jobs/bulk/hiring-signals" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"domains":["acme.com","globex.com","initech.com"]}'
```

## Outbound patterns

- **Trigger sweep** (recipe 6): weekly bulk hiring-signals over TAM → top decile → account brief → decision makers → outreach citing the job post.
- **Tool-displacement**: `tool-mentions` for accounts naming a competitor's product → displacement sequence.
- **Expansion timing**: `expansion` lens + `hiring-velocity` → catch budget cycles as they open.
- **Sell-to-the-role**: `job-search` skill for titles you sell to → the hiring manager is the buyer → `role-finder` for the manager.
- MCP: `find_jobs`, `search_jobs`, `get_company_hiring_signals`, `get_job_search_catalogs`, `resolve_job_search_filters`.
