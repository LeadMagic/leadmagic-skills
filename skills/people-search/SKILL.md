---
name: people-search
description: "LeadMagic People Search v3 via POST /v3/people/search and its variants (employees, by-title, lookalike, ICP). Use when building audiences or ICP lists, filtering by job function, title, level, company, or geo, sizing a segment for free before revealing rows, or debugging empty or unexpected people search results."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs/api-reference/people-search
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, people-search, v3, audience, icp, lookalike, enrichment, b2b]
---

# LeadMagic — People Search (v3)

Canonical discovery endpoint: **`POST /v3/people/search`**. Same body shape on the variants: `/v3/people/company-search`, `/full-search`, `/mixed-search`, `/icp-search`, `/employees`, `/by-title`, `/contacts-by-title`, `/lookalike`.

Docs: [People Search](https://leadmagic.io/docs/api-reference/people-search)

## Billing & plan awareness

- 1 credit per returned result row. **Free** on Professional (≤5 req/s) and Ultimate (≤10 req/s) — their plans include credit-free Search API throughput.
- Size before revealing (free on every plan): `POST /v3/search/stats` with the same filters returns match counts. On Basic–Growth, always size first and keep `per_page` small.

## Request

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
| Company | `company_domain`, `company_name`, `company_industry`, `company_size`/`company_sizes`, `company_country`/`company_countries`, funding |
| Role | `contact_job_title`, `contact_job_function`, `contact_job_level`, `contact_persona`, `min_seniority` |
| Person | name fields, B2B Profile URL/username, headline, `contact_email_domain`, `has_email` / `has_phone` |

Company filter aliases (normalized server-side):

| Client alias | Canonical |
|--------------|-----------|
| `company_size` / `company_sizes` / `employee_count` | `employee_ranges` (+ `min_employees` / `max_employees`) |
| `employee_min` / `employee_max` | `min_employees` / `max_employees` |
| `company_country` / `company_countries` | `hq_country_code` (ISO) |

Title matching: `"VP Sales"` is substring/FTS. Wrap in brackets for exact title equality — `"[VP of Sales]"` / `"[CEO]"`. Mixed arrays allowed. For list totals, pass `include_total: true` (capped COUNT on supported paths).

## Cursor pagination

- First page: filters + `limit` (**≤50 on cursor pages**). No `cursor`; `offset` 0 or omitted.
- Response carries `next_cursor` (opaque, ≤4096 chars) and `has_more`.
- Next page: **same filters** + `"cursor": "<next_cursor>"`. Changing filters mid-cursor invalidates it.
- Never combine `cursor` with a nonzero `offset` — the API rejects it, and `next_cursor` is only minted on the offset-0 form. If you were paging by offset, restart at offset 0.
- Stop when `next_cursor` is null / `has_more` is false. Dedupe rows on `person_uid`.

## Job function (`contact_job_function`)

- Accepts **short names** (`Sales`, `Marketing`, `Product`) **or** full canonical labels (`Sales & Business Development`).
- Matching is **exact after short-name expansion** (not substring). `"Product"` does **not** match `"Manufacturing & Production"`.
- Response rows always return the **canonical label** (request `Sales` → response `Sales & Business Development`). Expected.

| Request | Label returned |
|---------|----------------|
| Sales | Sales & Business Development |
| Marketing | Advertising & Marketing |
| Product | Product Management |
| Engineering | Engineering |

## When not to use this skill

- Single-person email / mobile / profile lookup → `email-enrichment` or `people-enrichment`
- Company firmographics or company lists → `company-enrichment`
- CSV enrichment of known rows → `bulk-jobs`
- Full list-build recipe with dedupe + waterfall → `outbound-recipes`
