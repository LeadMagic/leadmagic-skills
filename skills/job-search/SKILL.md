---
name: job-search
description: "LeadMagic V3 jobs search via POST /v3/jobs/search — 46M+ open job postings with vector, facets, and deep modes. Use when searching job postings, mining hiring signals, building lists from who's hiring, handling jobs cursor pagination, or bulk-exporting postings."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs/api-reference/job-search?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, job-search, jobs, v3, hiring-signals, unlimited, b2b]
---

# LeadMagic — Job search (V3)

Canonical endpoint: **`POST /v3/jobs/search`** — 46M+ open postings across corporate job boards.
Aliases (same handler): `/v3/jobs-search`, `/v3/job-search`, `/v2/jobs/search`, `/v1/jobs/search`.

Docs: [Job Search](https://leadmagic.io/docs/api-reference/job-search?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills)

## Unlimited with the right plan

**Professional and Ultimate plans search this endpoint free** — no credits, no volume
cap. The only limit is rate: **5 req/s sustained (Professional), 10 req/s (Ultimate)**.
That covers all three modes below. Other plans pay ~1 credit per returned job.
Never ration or narrow a query to save credits on an entitled plan — go broad.
Export is credit-metered on every plan.

## Three modes, one endpoint

The body picks the mode; all three ride the unmetered plan entitlement:

| Mode | Trigger | Use for |
|------|---------|---------|
| **vector** (default fast) | nothing, or `titles.vector: true` | Ranked browsing; semantic title match ("Head of Growth" also finds "VP Growth Marketing") |
| **facets** | `includeFacets: true` | Results + aggregation counts (by country, seniority, industry) — filter UIs, market breakdowns |
| **deep** | `mode: "deep"` or `includeDescription: true` | Full posting text — tool-mention mining, AI screening |

`preview` / `teaser` / `dryRun` are reserved for the LeadMagic app UI — external keys are rejected.

```bash
curl -sS -X POST "https://api.leadmagic.io/v3/jobs/search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "titles": { "include": ["Sales Development Representative"], "vector": true },
    "location": { "countries": ["US"] },
    "postedWithin": 30,
    "limit": 25,
    "totalMode": "capped"
  }'
```

## Filters (at least one required)

`titles.include/exclude` (10 each, `vector` flag) · `companies.include/ids` ·
`location.countries/regions/states/cities/text` · `tags.include` ·
`occupationTaxonomy.level1/2/3` (names or IDs) · `seniority` · `languages` ·
`jobTypeIds` · `industryIds` · `companyTypeIds` · `companySizeCodes` ·
`workModes` (1–3) · `salary.min_usd/max_usd` · `hasRemote` ·
`postedAfter`/`postedBefore` (YYYY-MM-DD) or `postedWithin` (days, ≤365).

`autoResolve: true` (default) fuzzy-resolves friendly values — no exact IDs needed.
`totalMode`: `none` | `capped` (default) | `exact`.

## Cursor pagination

- First page: send filters + `limit` (1–50, default 25). **No `cursor`.**
- Response carries `next_cursor` (opaque string) and `has_more`.
- Next page: **same filters** + `"cursor": "<next_cursor>"`. Changing filters mid-cursor invalidates it.
- Never combine `cursor` with a nonzero `offset` — the API rejects it.
- Stop when `next_cursor` is null / `has_more` is false.
- On an unlimited plan, paging an entire market is free — just respect the RPS.

## Free helpers (0 credits, shape filters first)

| Helper | Endpoint |
|--------|----------|
| Resolve friendly values → IDs | `POST /v3/jobs/search/resolve` |
| Autocomplete | `GET /v3/jobs/search/{companies,titles,roles,tags,locations,occupation-taxonomy}` |
| Filter catalogs | `GET /v3/jobs/search/catalogs` |
| Dataset stats / freshness | `GET /v3/jobs/search/stats` |

## Bulk export (metered on all plans)

`POST /v3/jobs/search/export` — same filters, `limit` 1–5000 (default 100),
descriptions on by default, **no cursor** (narrow filters instead), 1 credit per returned job.

## Workflow

1. Shape filters free: `resolve` or the GET catalogs.
2. Scan broad in vector mode; add `includeFacets` to see the distribution.
3. Drop to `mode: "deep"` only on the slice needing descriptions.
4. Page with `cursor` until `has_more` is false.
5. Need >50/page in one pull? Use export (metered) — tell the user the credit cost first.

## When not to use this skill

- People/contacts at a company → `people-search`
- Company firmographics → `company-search`
- Legacy V1 listing API (`/v1/jobs/jobs-finder`) → docs only; prefer V3
