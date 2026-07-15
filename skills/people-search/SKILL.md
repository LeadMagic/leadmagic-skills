---
name: people-search
description: "LeadMagic V3 people search (POST /v3/people/search). Use for audience building, ICP filters, job function/title/level filters, company+people filters, and debugging empty or unexpected people search results."
argument-hint: "[people search filters or debugging]"
license: MIT
version: 1.0.0
tags: [leadmagic, people-search, v3, audience, enrichment]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs/api-reference/people-search"
publisher: "LeadMagic"
verified: true
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
| Person | name, LinkedIn URL/username, headline, `has_email` / `has_phone` |

Exact field names and enums: see the docs page above (source of truth).

## Job function (`contact_job_function`)

- Accepts **short chips** (`Sales`, `Marketing`, `Product`) **or** full warehouse labels (`Sales & Business Development`).
- Matching is **exact after chip expansion** (not substring). `"Product"` does **not** match `"Manufacturing & Production"`.
- Response rows always return the **warehouse label** (e.g. request `Sales` → response `Sales & Business Development`). That is expected, not a bug.

| Chip | Warehouse label returned |
|------|--------------------------|
| Sales | Sales & Business Development |
| Marketing | Advertising & Marketing |
| Product | Product Management |
| Engineering | Engineering |
| … | See docs Job function section |

## When not to use this skill

- Single-person email / mobile / profile lookup → `email-enrichment` or `people-enrichment`
- Company firmographics only → `company-enrichment`
- CSV enrichment of known rows → `bulk-jobs`

## Learnings

Append durable gotchas to `skills/leadmagic/references/learnings.md` (no secrets / PII).
