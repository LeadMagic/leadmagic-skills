---
name: company-enrichment
description: "LeadMagic company search, funding, technographics, and competitors. Use when enriching a domain/company, researching accounts, or pulling funding and tech stack via REST or MCP."
argument-hint: "[company search / funding / competitors / technographics]"
license: MIT
version: 1.0.0
tags: [leadmagic, company, funding, enrichment]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs"
publisher: "LeadMagic"
verified: true
---

# LeadMagic — Company enrichment

## Endpoints

| Goal | Endpoint | Credits (typical) |
|------|----------|-------------------|
| Company by domain / name | `POST /v1/companies/company-search` | 1 (free if not found) |
| Funding rounds | `POST /v1/companies/company-funding` | 4 (free if not found) |
| Technographics / competitors | Often via company search / MCP helpers | see docs |

```bash
curl -sS -X POST "https://api.leadmagic.io/v1/companies/company-search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"domain":"acme.com"}'

curl -sS -X POST "https://api.leadmagic.io/v1/companies/company-funding" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"domain":"acme.com"}'
```

## Related

- People at a company by filters → `people-search`
- Employees / role at company → `people-enrichment` (`role-finder`, `employee-finder`)
- Bulk company rows → `bulk-jobs` with `product: "company_search"`

## MCP

- `research_account`
- `list_company_competitors`
- `get_company_technographics`
