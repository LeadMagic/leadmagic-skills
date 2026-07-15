---
name: people-search
description: "LeadMagic V3 people search via POST /v3/people/search. Use when building audiences or ICPs, filtering by job function, title, level, company, or geo, or debugging empty or unexpected people search results."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs/api-reference/people-search
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, people-search, v3, audience, enrichment, b2b]
---

# LeadMagic — People search (V3)

Canonical discovery endpoint: **`POST /v3/people/search`**.

Docs: [People Search](https://leadmagic.io/docs/api-reference/people-search)

## Auth

```bash
curl -sS -X POST "https://api.leadmagic.io/v3/people/search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "company_filters": { "company_domain": ["acme.com"] },
    "people_filters": {
      "contact_job_function": ["Sales"],
      "contact_job_level": ["Director", "VP"]
    },
    "page": 1,
    "per_page": 25
  }'
```

## Filter families

| Family | Examples |
|--------|----------|
| Company | `company_domain`, company size, industry, geo, funding |
| Role | `contact_job_title`, `contact_job_function`, `contact_job_level`, `contact_persona`, `min_seniority` |
| Person | name, B2B Profile URL/username, headline, `has_email` / `has_phone` |

Exact field names and enums: see the docs page above (source of truth).

## Job function (`contact_job_function`)

- Accepts **short names** (`Sales`, `Marketing`, `Product`) **or** full canonical labels (`Sales & Business Development`).
- Matching is **exact after short-name expansion** (not substring). `"Product"` does **not** match `"Manufacturing & Production"`.
- Response rows always return the **canonical label** (e.g. request `Sales` → response `Sales & Business Development`). That is expected.

| Request | Label returned |
|---------|----------------|
| Sales | Sales & Business Development |
| Marketing | Advertising & Marketing |
| Product | Product Management |
| Engineering | Engineering |
| … | See [Job function](https://leadmagic.io/docs/api-reference/people-search#job-function) |

## When not to use this skill

- Single-person email / mobile / B2B Profile lookup → `email-enrichment` or `people-enrichment`
- Company firmographics only → `company-enrichment`
- CSV enrichment of known rows → `bulk-jobs`
