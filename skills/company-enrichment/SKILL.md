---
name: company-enrichment
description: "LeadMagic company search, filter search, funding, technographics, lookalikes, competitors, and company posts. Use when enriching a domain or company name, building company lists with typed filters, finding lookalike companies from a seed, researching an account's funding or tech stack, or pulling a company's recent public posts."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, company, funding, technographics, lookalike, competitors, enrichment]
---

# LeadMagic — Company enrichment & discovery

## Endpoints

| Goal | Endpoint | Credits | Rate/min |
|---|---|---|---|
| Enrich one company | `POST /v1/companies/company-search` | 1 (free on miss) | 300 |
| Company **list** by typed filters | `POST /v3/companies/search` — full depth in the `company-search` skill | 1 per row | 300 |
| Lookalikes from a seed | `POST /v3/companies/lookalike` | 5 (metered on all plans) | 300 |
| Competitors | `POST /v1/companies/competitors-search` | 5 | 300 |
| Funding rounds | `POST /v1/companies/company-funding` | 4 (free on miss) | 300 |
| Tech stack | `POST /v1/companies/technographics` | 1 | 1,500 |
| Company's recent posts | `POST /v1/companies/posts-search` | 1 | 300 |
| Employees at company | `POST /v1/companies/employees` | 1 | 300 |

Plan note: `/v3/companies/*` searches are credit-free on Professional (5 req/s) / Ultimate (10 req/s); other plans bill per row. Free count/stats surfaces exist — size a filter search before revealing.

## Field contracts

- **company-search**: any one of `company_domain` (preferred — e.g. `stripe.com`), `company_name`, or `profile_url` (company page URL/slug). CRM aliases (`website`, `companyName`, `organization`, …) normalize server-side; URLs are stripped to bare domains.
- **v3 filter search**: typed `company_filters` (firmographics, geo, funding, technographics) with cursor pagination — filter vocabulary, One-vs-Many lookup, and cursors are documented in the dedicated `company-search` skill.
- **lookalike**: seed `company_domain` or free-text description; returns full company rows.
- Pass real employer domains — never person names or UI labels as the company.

```bash
curl -sS -X POST "https://api.leadmagic.io/v1/companies/company-search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"company_domain":"acme.com"}'

curl -sS -X POST "https://api.leadmagic.io/v3/companies/lookalike" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"company_domain":"bestcustomer.com"}'
```

## Account brief composite (~8–12 credits)

`company-search` (1) → `company-funding` (4) → `technographics` (1) → hiring signals (`jobs-hiring-intent` skill, 1) → `posts-search` (1) → optional `competitors-search` (5). MCP shortcut: `account_intel` runs the composite in one call. Full recipe: `outbound-recipes` recipe 2.

## Related

- People at a company by filters → `people-search`; buyers → `outbound-recipes` recipe 7
- Hiring/intent signals for the account → `jobs-hiring-intent`
- What they're advertising → `ads-intelligence`
- MCP: `enrich_company`, `research_account`, `find_company_funding`, `get_company_technographics`, `find_lookalike_companies`, `list_company_competitors`
