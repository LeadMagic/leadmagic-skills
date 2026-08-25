---
name: people-enrichment
description: "LeadMagic people enrichments beyond email — B2B Profile search, mobile finder, role finder, employee finder, job change detection, and posts or comments activity. Use when enriching a known person from a B2B Profile URL, finding a mobile number, finding who holds a role at a company, listing employees, or checking whether a contact changed jobs."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, mobile, b2b-profile, role-finder, job-change, enrichment]
---

# LeadMagic — People enrichment

For **finding people by ICP filters**, use `people-search`. For **email** find/validate, use `email-enrichment`.

## Endpoints

| Goal | Endpoint | Credits | Rate/min |
|---|---|---|---|
| Enrich from B2B Profile URL | `POST /v1/people/profile-search` | 1 | 300 |
| Find mobile number | `POST /v1/people/mobile-finder` | 5 (free on miss) | 25,000 |
| Person holding a role at a company | `POST /v1/people/role-finder` | 2 | 300 |
| List employees at a company | `POST /v1/people/employee-finder` | 1 | 300 |
| Did this person change jobs? | `POST /v1/people/job-change-detector` | 3 | 1,500 |
| Person's recent public posts | `POST /v1/people/posts-search` | 1 | 300 |
| Public comment activity | `POST /v1/people/comments-search` | 1 | 1,000 |

## Field contracts

- **profile-search / posts**: `{profile_url}` — common CRM synonym keys are accepted; full URL or bare `/in/{slug}`, normalized server-side. Company URLs are rejected (use Company Search).
- **mobile-finder**: any of `profile_url`, `work_email`, `personal_email`. Free when not found. For lawful business use; calling/texting compliance is the customer's responsibility.
- **role-finder**: `job_title` (required; aliases `role`, `title`, `jobTitle` map in) + one of `company_domain` / `company_name` / a B2B profile URL (a person URL resolves to their current company).
- **employee-finder**: company identifier; also mounted at `/v1/companies/employees`. For filtered employee lists (level/function), prefer `POST /v3/people/employees` (see `people-search`).
- **job-change-detector**: profile URL or work email, plus the expected company when known. Result is yes / no / inconclusive — treat inconclusive as "recheck next sweep", not a change.

```bash
curl -sS -X POST "https://api.leadmagic.io/v1/people/profile-search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"profile_url":"in/janedoe"}'

curl -sS -X POST "https://api.leadmagic.io/v1/people/role-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"job_title":"VP Sales","company_domain":"acme.com"}'
```

## Cost-order rules

- Profile fields from a URL you already hold → `profile-search` (1), never `b2b-profile` (10).
- Mobile last in any waterfall (5, priciest common step) and only when a phone channel is actually needed.
- Champion tracking: monthly `job-change-detector` sweep over CRM champions (3/contact) is the highest-converting outbound trigger — see `outbound-recipes` recipe 8.
- MCP equivalents: `search_profile`, `find_mobile_number`, `find_people_by_role`, `find_company_employees`, `detect_job_change`.
