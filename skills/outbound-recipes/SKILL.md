---
name: outbound-recipes
description: "Composable LeadMagic recipes for building outbound systems — ICP list building, waterfall enrichment, bulk CSV pipelines, hiring-intent trigger sweeps, job-change champion tracking, competitor ad monitoring, lookalike expansion, TAM mapping, and list hygiene. Use when designing or running any multi-step outbound, prospecting, or GTM data workflow with LeadMagic."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, outbound, recipes, gtm, prospecting, workflows, official]
---

# LeadMagic — Outbound system recipes

Thirteen credit-aware, composable recipes live in the `leadmagic` skill's references — read **`skills/leadmagic/references/outbound-recipes.md`** for full request bodies and cost models. This skill is the index and the operating rules.

## Recipe index

| # | Recipe | Core endpoints | Cost model |
|---|--------|----------------|------------|
| 1 | ICP list build | `/v3/search/stats` (free) → `/v3/people/search` | 1/row (free on Pro/Ultimate) |
| 2 | Account brief | company-search + funding + tech + hiring-signals + posts | ~8–12/account |
| 3 | Waterfall contact enrichment | validate → find → profile→email → personal → mobile | 0.25–5, cheapest-first |
| 4 | Bulk CSV enrichment | `/bulk/validate` → `/bulk/submit` → poll → download | per successful row |
| 5 | List hygiene | bulk `email_validation` before every send | 0.25/row max |
| 6 | Hiring-intent trigger sweep | `/v1/jobs/bulk/hiring-signals` | 1/domain |
| 7 | Decision-maker mapping | role-finder or `/v3/people/employees` | 2–6/account |
| 8 | Job-change champion loop | job-change-detector → profile → email-finder | 3/contact/sweep |
| 9 | Competitor ads monitor | google/meta/b2b ads search → details | 1/search + 2/detail |
| 10 | Lookalike expansion | `/v3/companies/lookalike` → filter → rank | 5/seed + 1/row |
| 11 | TAM map | free stats permutations → selective reveal | ~0 to size |
| 12 | Speed-to-lead inbound enrich | validation + company-search + role-finder | ~2–4/lead |
| 13 | Signal-stacked cold sequence | composes 2/3/5/6/7/8/9/10 | budgeted per stage |

## Operating rules (every recipe)

1. **Preflight free:** `GET /v1/credits`; preview with `POST /v1/batch/preview-cost` when ≥ 500 credits; state projected spend before running.
2. **Plan-aware sizing:** on Basic–Growth, size searches with free stats endpoints first; on Professional/Ultimate, v3 searches are credit-free within 5/10 req/s.
3. **Cheapest-first:** never run a pricier product when a cheaper one satisfies the channel (`leadmagic` skill has the ladder).
4. **Bulk ≥ 50 rows.** Poll ≥45s. Misses are free — retry only *changed* inputs.
5. **Hygiene before send** (recipe 5) — always.
6. **Close the loop:** after a run, report actuals from free `/v1/analytics/day/{date}` vs the estimate.
7. Never invent emails, phones, funding, ads, or job data; only report endpoint results.
