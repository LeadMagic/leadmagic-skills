---
name: email-enrichment
description: "LeadMagic email finder, email validation, personal email, and B2B Profile to email enrichment. Use when finding or validating a work email, finding a personal email, converting a B2B Profile URL to an email, or converting an email to a B2B Profile via REST or MCP."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, email-finder, email-validation, b2b-profile, enrichment]
---

# LeadMagic — Email enrichment

Auth: `X-API-Key: $LEADMAGIC_API_KEY` → `https://api.leadmagic.io`. Never echo the key.

## Which endpoint?

| Goal | Endpoint | Credits | Rate/min |
|---|---|---|---|
| Validate an email | `POST /v1/people/email-validation` | 0.25 (conclusive only) | 5,000 |
| Work email from name + company | `POST /v1/people/email-finder` | 1 (free on miss) | 5,000 |
| Personal email from profile URL | `POST /v1/people/personal-email-finder` | 2 (free on miss) | 5,000 |
| B2B Profile URL → work email | `POST /v1/people/b2b-profile-email` | 5 (free on miss) | 1,500 |
| Email → full B2B Profile | `POST /v1/people/b2b-profile` | 10 | 1,500 |

Cheapest-first waterfall: validate (0.25) → find (1) → personal (2) → profile→email (5) → email→profile (10). If you already hold a profile URL and only need profile *fields*, use `profile-search` (1) — not `b2b-profile` (10).

## Field contract (forgiving on purpose)

- **email-finder** needs the *person* (`first_name`+`last_name`, `full_name`, **or** a person `profile_url`) AND the *company* (`domain`/`company_domain`/`website`/`url` or `company_name`). CamelCase and common CRM aliases are accepted; `null` values are treated as omitted.
- **Profile-URL endpoints** take `profile_url` (common CRM synonym keys are accepted); full URL or bare slug — `/in/{username}` forms are normalized. Company pages (`/company/…`) are rejected here; use Company Search for those.
- **b2b-profile** accepts `work_email`, `personal_email`, or plain `email` (maps to work_email).
- Names are sanitized (credentials, emojis, trailing digits stripped) but multi-person strings, bios, and company names in name fields are rejected with a 400 explaining the fix.

## Examples

```bash
# Find
curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","domain":"acme.com"}'

# Validate
curl -sS -X POST "https://api.leadmagic.io/v1/people/email-validation" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"email":"jane.doe@acme.com"}'

# Profile URL → email
curl -sS -X POST "https://api.leadmagic.io/v1/people/b2b-profile-email" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"profile_url":"in/janedoe"}'
```

## Rules

- Validate before every send (recipe: `outbound-recipes` skill, "List hygiene"). Send only `valid` (+ `catch_all` at your own risk).
- A miss is free but final for that input — don't resubmit the identical request hoping for a different answer.
- Lists ≥ 50 rows → bulk (`bulk-jobs` skill) with `product: "email_finder"` / `"email_validation"`; billed per successful row.
- MCP equivalents: `find_work_email`, `validate_work_email`, `find_personal_email`, `b2b_profile_to_work_email`, `email_to_b2b_profile`.
