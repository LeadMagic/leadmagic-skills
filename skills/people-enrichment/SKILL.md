---
name: people-enrichment
description: "LeadMagic people enrichments beyond email: profile search, mobile finder, role finder, employee finder, job change. Use when enriching a known person or listing employees by role at a company."
argument-hint: "[profile / mobile / role / employees / job change]"
license: MIT
version: 1.0.0
tags: [leadmagic, mobile, profile, role-finder, enrichment]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs"
publisher: "LeadMagic"
verified: true
---

# LeadMagic — People enrichment

For **finding** people by ICP filters, use skill `people-search` (`POST /v3/people/search`).
For **email** find/validate, use skill `email-enrichment`.

## Endpoints

| Goal | Endpoint | Credits (typical) |
|------|----------|-------------------|
| Enrich LinkedIn / profile URL | `POST /v1/people/profile-search` | 1 |
| Find mobile | `POST /v1/people/mobile-finder` | 5 (free if not found) |
| Find person by role at company | `POST /v1/people/role-finder` | 2 |
| List employees | `POST /v1/people/employee-finder` | ~0.05 / employee |
| Job change detect | MCP `detect_job_change` / docs | varies |

```bash
curl -sS -X POST "https://api.leadmagic.io/v1/people/mobile-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"profile_url":"https://www.linkedin.com/in/janedoe"}'

curl -sS -X POST "https://api.leadmagic.io/v1/people/profile-search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"profile_url":"https://www.linkedin.com/in/janedoe"}'
```

## Budget tips

- Mobile is **5×** email finder — preflight `GET /v1/credits`.
- Prefer `profile-search` (1) over `b2b-profile` (10) when you already have the LinkedIn URL.
- Bulk: `product` values like `mobile_finder`, `profile_search` via `POST /bulk/submit` — see `bulk-jobs`.

## MCP

- `find_mobile_number`
- `find_people_by_role`
- `detect_job_change`
