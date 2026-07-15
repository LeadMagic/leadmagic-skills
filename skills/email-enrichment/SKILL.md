---
name: email-enrichment
description: "LeadMagic email finder, validation, personal email, and B2B profile↔email. Use for work email lookup, catch-all detection, LinkedIn→email, or email→profile enrichment via REST or MCP."
argument-hint: "[find / validate / personal / LinkedIn email]"
license: MIT
version: 1.0.0
tags: [leadmagic, email-finder, email-validation, enrichment]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs"
publisher: "LeadMagic"
verified: true
---

# LeadMagic — Email enrichment

Auth: `X-API-Key: $LEADMAGIC_API_KEY` → `https://api.leadmagic.io`. Never echo the key.

## Which endpoint?

| Goal | Endpoint | Credits (typical) |
|------|----------|-------------------|
| Find work email from name + company | `POST /v1/people/email-finder` | 1 (free on null) |
| Validate an email | `POST /v1/people/email-validation` | 0.25 |
| Find personal email | `POST /v1/people/personal-email-finder` | 2 (free if not found) |
| LinkedIn URL → work email | `POST /v1/people/b2b-profile-email` | 5 (free if not found) |
| Email → B2B / LinkedIn profile | `POST /v1/people/b2b-profile` | 10 |

If you already have a LinkedIn URL and only need profile fields, prefer `profile-search` (1 credit) over `b2b-profile` (10).

## Examples

```bash
# Email Finder
curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","company_name":"acme.com"}'

# Email Validation
curl -sS -X POST "https://api.leadmagic.io/v1/people/email-validation" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email":"jane@acme.com"}'
```

## Bulk

For CSV / large lists use `POST /bulk/submit` with `product: "email_finder"` or `"email_validation"`. See skill `bulk-jobs`.

## MCP tools

- `find_work_email` → email-finder
- `validate_work_email` → email-validation
- `linkedin_profile_to_work_email` → b2b-profile-email

## Gotchas

- Placeholder domains like `example.com` may be rejected.
- Do not retry `null` aggressively — not found is free but rate limits still apply.
- For waterfall / multi-provider strategy questions that are not LeadMagic-specific, say so and keep this skill scoped to LeadMagic calls.
