---
name: company-enrichment
description: "LeadMagic company search, funding, technographics, and competitors. Use when enriching a domain or company name, researching an account, or pulling funding and tech-stack data via REST or MCP."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, company, funding, technographics, enrichment]
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
