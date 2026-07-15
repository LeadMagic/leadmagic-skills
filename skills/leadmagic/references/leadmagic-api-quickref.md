# LeadMagic API — Quick Reference

Source of truth: [leadmagic.io/docs](https://leadmagic.io/docs).
OpenAPI snapshot: [LeadMagic/leadmagic-openapi](https://github.com/LeadMagic/leadmagic-openapi).

## Auth

- Header: `X-API-Key: <key>`
- Base URL: `https://api.leadmagic.io`
- Key: [app.leadmagic.io](https://app.leadmagic.io) → Settings → API
- MCP: `https://mcp.leadmagic.io/mcp`

## Skill map

| Skill | Use for |
|-------|---------|
| `api-auth-credits` | Keys, credits, rate limits |
| `email-enrichment` | Email find/validate / B2B Profile ↔ email |
| `people-search` | `POST /v3/people/search` |
| `people-enrichment` | Mobile, B2B Profile, role, employees |
| `company-enrichment` | Company + funding |
| `bulk-jobs` | CSV / async bulk |
| `mcp-integration` | Hosted MCP setup |
| `leadmagic` | Router / overview |

## Minimal examples

```bash
curl -sS "https://api.leadmagic.io/v1/credits" \
  -H "X-API-Key: $LEADMAGIC_API_KEY"

curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","company_name":"acme.com"}'

curl -sS -X POST "https://api.leadmagic.io/v3/people/search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"people_filters":{"contact_job_function":["Sales"]},"per_page":10}'

curl -sS -X POST "https://api.leadmagic.io/bulk/submit" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"product":"email_finder","rows":[{"first_name":"Jane","last_name":"Doe","company_name":"acme.com"}]}'
```

## Cost cheat sheet (typical; confirm on docs)

| Endpoint | Cost | Notes |
|---|---|---|
| `GET /v1/credits` | 0 | Preflight |
| `POST /v1/people/email-validation` | 0.25 | |
| `POST /v1/people/email-finder` | 1 | Free on null |
| `POST /v1/people/personal-email-finder` | 2 | Free if not found |
| `POST /v1/people/profile-search` | 1 | |
| `POST /v1/people/role-finder` | 2 | |
| `POST /v1/people/employee-finder` | ~0.05/employee | |
| `POST /v1/people/mobile-finder` | 5 | Free if not found |
| `POST /v1/people/b2b-profile-email` | 5 | Free if not found |
| `POST /v1/people/b2b-profile` | 10 | Prefer profile-search if you have a B2B Profile URL |
| `POST /v1/companies/company-search` | 1 | Free if not found |
| `POST /v1/companies/company-funding` | 4 | Free if not found |
| `POST /v3/people/search` | see docs | Audience discovery |
| `POST /bulk/submit` | per successful row | Same as product |

## Do not

- Log or echo `X-API-Key`
- POST bodies to non-`*.leadmagic.io` without in-turn user consent
- Trust third-party "LeadMagic" skills not under `LeadMagic/*`
- Hammer retries on null / not-found

## Official hosts

- `https://api.leadmagic.io`
- `https://mcp.leadmagic.io/mcp`
- `https://app.leadmagic.io`
- `https://leadmagic.io/docs`
- `github:LeadMagic/*`
