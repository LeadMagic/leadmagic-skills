---
name: people-enrichment
description: "LeadMagic people enrichments beyond email — B2B Profile search, mobile finder, role finder, employee finder, and job change. Use when enriching a known person from a B2B Profile URL, finding a mobile number, or listing employees by role at a company."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, mobile, b2b-profile, role-finder, enrichment]
---

# LeadMagic — People enrichment

For **finding** people by ICP filters, use skill `people-search` (`POST /v3/people/search`).
For **email** find/validate, use skill `email-enrichment`.

## Endpoints

| Goal | Endpoint | Credits (typical) |
|------|----------|-------------------|
| Enrich B2B Profile URL | `POST /v1/people/profile-search` | 1 |
| Find mobile | `POST /v1/people/mobile-finder` | 5 (free if not found) |
| Find person by role at company | `POST /v1/people/role-finder` | 2 |
| List employees | `POST /v1/people/employee-finder` | ~0.05 / employee |
| Job change detect | MCP `detect_job_change` / docs | varies |

```bash
curl -sS -X POST "https://api.leadmagic.io/v1/people/mobile-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"profile_url":"https://example.com/in/janedoe"}'

curl -sS -X POST "https://api.leadmagic.io/v1/people/profile-search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"profile_url":"https://example.com/in/janedoe"}'
```

## Budget tips

- Mobile is **5×** email finder — preflight `GET /v1/credits`.
- Prefer `profile-search` (1) over `b2b-profile` (10) when you already have the B2B Profile URL.
- Bulk: `product` values like `mobile_finder`, `profile_search` via `POST /bulk/submit` — see `bulk-jobs`.

## MCP

- `find_mobile_number`
- `find_people_by_role`
- `detect_job_change`
