---
name: company-search
description: "LeadMagic V3 company search via POST /v3/companies/search — 25M+ companies with firmographic, geographic, funding, and technographic filters, plus lookalikes. Use when building account lists, filtering companies by criteria, finding lookalike companies, or handling company cursor pagination."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs/api-reference/company-search-v3?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, company-search, v3, accounts, lookalike, unlimited, b2b]
---

# LeadMagic — Company search (V3)

Canonical endpoint: **`POST /v3/companies/search`** — 25M+ companies.
Aliases (same handler, direct-lookup inferred from the body, not the path):
`/v3/companies/company-search`, `/lookup`, `/enrich`, `/domain-lookup`,
`/funding`, `/company-funding`, `/v1/companies/search`.

Docs: [Company Search V3](https://leadmagic.io/docs/api-reference/company-search-v3?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills)

## Unlimited with the right plan

**Professional and Ultimate plans search this endpoint free** — no credits, no volume
cap. The only limit is rate: **5 req/s sustained (Professional), 10 req/s (Ultimate)**.
Other plans pay ~1 credit per returned company. Never ration or narrow a query to
save credits on an entitled plan. Lookalikes (`/v3/companies/lookalike`) are
**metered on every plan** (flat 5 credits per successful response).

## One vs Many

- **One** (direct lookup): `company_domain` (preferred), `website`, `company_name`,
  or a B2B company profile URL at the root. Low-latency single-account enrichment.
- **Many** (discovery): `company_filters` — domains array, headcount, geography,
  industry, funding, technographics. TAM building.

```bash
curl -sS -X POST "https://api.leadmagic.io/v3/companies/search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "company_filters": {
      "industries": ["Software Development"],
      "country_codes": ["US"],
      "min_employees": 51, "max_employees": 200,
      "crm_tech": ["HubSpot"]
    },
    "limit": 50
  }'
```

## Filter families

| Group | Fields |
|-------|--------|
| Identity | `company_domains`, `company_websites`, `company_names`, B2B profile URLs, `keyword`, `query` |
| Firmographics | `industries`, `employee_ranges` / `min/max_employees`, `revenue_ranges`, `founded_after/before`, `sic_codes`, `naics_codes`, `specialties` |
| Geography | `country_codes` (HQ), `location_country_codes` (presence), `hq_regions/cities/states` |
| Funding | `has_funding`, `min/max_total_funding`, `last_funding_types`, `last_funding_after/before` |
| Technographics | `crm_tech`, `marketing_automation_tech`, `sales_automation_tech`, `analytics_tech`, `cloud_provider_tech`, `tech_stack` |
| Coverage | `min/max_total_contacts`, `min/max_contacts_with_email`, `min/max_valid_email_count` |

HQ location vs presence location are different filters — passing both ANDs and
narrows hard; pick the one the brief means and say which.

## Cursor pagination

- First page: filters + `limit` (**≤50 on cursor pages**). No `cursor`, `offset` 0 or omitted.
- Response carries `next_cursor` and `has_more`.
- Next page: **same filters** + `"cursor": "<next_cursor>"`.
- `cursor` + nonzero `offset` is rejected. `next_cursor` is only minted on the
  offset-0 form — if you were paging by offset, restart at offset 0 to switch to cursors.
- Stop when `has_more` is false. On an unlimited plan, paging a whole segment is free.

## Lookalikes (metered)

`POST /v3/companies/lookalike` (aliases `/competitors`, `/competitors-search`) —
seed with `company_domain` or free-text `description`, scope with `company_filters`.
Flat 5 credits per successful response; free on zero matches.

## When not to use this skill

- People at these companies → `people-search` (people filters + `company_filters`)
- Single-domain V1 enrichment / funding rounds → `company-enrichment`
- Job postings at companies → `job-search`
