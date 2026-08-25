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

Canonical discovery endpoint: **`POST /v3/people/search`** — 400M+ people profiles.
Aliases (same handler and schema): `/v3/person/search`, `/v3/people/company-search`,
`/full-search`, `/mixed-search`, `/icp-search`, `/employees`, `/by-title`,
`/contacts-by-title`, `/lookalike`, plus legacy `/v1` and `/v2` prefixes.

Docs: [People Search](https://leadmagic.io/docs/api-reference/people-search)

## Unlimited with the right plan

**Professional and Ultimate plans browse this endpoint free** — no credits, no volume
cap. The only limit is rate: **5 req/s sustained (Professional), 10 req/s (Ultimate)**.
Other plans pay ~1 credit per returned person. Never ration or narrow a query to save
credits on an entitled plan — go broad, page the whole segment.

The free lane is **browse only**: base people records with `has_email` / `has_phone`
availability flags. Requesting raw contact details (`include_contact_details: true` /
`full_search: true`) is always credit-metered (+1/email, +5/mobile) — and returns 403
on RPS-only plans without credit metering. Size the audience free first; unlock
contact details last, on the final list only.

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

Company filter aliases (normalized server-side):

| Client alias | Canonical |
|--------------|-----------|
| `company_size` / `company_sizes` / `employee_count` | `employee_ranges` (+ `min_employees` / `max_employees`) |
| `employee_min` / `employee_max` | `min_employees` / `max_employees` |
| `company_industry` | canonical industry field (see docs) |
| `company_country` / `company_countries` | `hq_country_code` (ISO) |

Title matching: `"VP Sales"` is substring/FTS. Wrap in brackets for exact title equality — `"[VP of Sales]"` / `"[CEO]"` (Blitz-compatible). Mixed arrays are allowed.

For list totals like Blitz `total_results`, pass `include_total: true` (capped COUNT on supported paths).

Exact field names and enums: see the docs page above (source of truth).

## Cursor pagination

- First page: filters + `limit` (**≤50 on cursor pages**). No `cursor`; `offset` 0 or omitted.
- Response carries `next_cursor` (opaque, ≤4096 chars) and `has_more`.
- Next page: **same filters** + `"cursor": "<next_cursor>"`. Changing filters mid-cursor invalidates it.
- Never combine `cursor` with a nonzero `offset` — the API rejects it, and `next_cursor`
  is only minted on the offset-0 form. If you were paging by offset, restart at offset 0.
- Stop when `next_cursor` is null / `has_more` is false.

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
