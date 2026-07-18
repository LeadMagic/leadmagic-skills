---
name: email-enrichment
description: "LeadMagic email finder, email validation, personal email, and B2B Profile to email enrichment. Use when finding or validating a work email, converting a B2B Profile URL to email, or converting an email to a B2B Profile via REST or MCP."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "1.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, email-finder, email-validation, b2b-profile, enrichment]
---

# LeadMagic — Email enrichment

Auth: `X-API-Key: $LEADMAGIC_API_KEY` → `https://api.leadmagic.io`. Never echo the key.

## Which endpoint?

| Goal | Endpoint | Credits (typical) |
|------|----------|-------------------|
| Find work email from name + company | `POST /v1/people/email-finder` | 1 (free on null) |
| Validate an email | `POST /v1/people/email-validation` | 0.25 |
| Find personal email (B2B fallback when work email unavailable) | `POST /v1/people/personal-email-finder` | 2 (free if not found) |
| B2B Profile URL → work email | `POST /v1/people/b2b-profile-email` | 5 (free if not found) |
| Email → B2B Profile | `POST /v1/people/b2b-profile` | 10 |

If you already have a B2B Profile URL and only need profile fields, prefer `profile-search` (1 credit) over `b2b-profile` (10).

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

# B2B Profile → work email
curl -sS -X POST "https://api.leadmagic.io/v1/people/b2b-profile-email" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"profile_url":"https://example.com/in/janedoe"}'
```

## Bulk

For CSV / large lists use `POST /bulk/submit` with `product: "email_finder"` or `"email_validation"`. See skill `bulk-jobs`.

## MCP tools

- `find_work_email` → email-finder
- `validate_work_email` → email-validation
- `linkedin_profile_to_work_email` → b2b-profile-email (B2B Profile URL → work email)

## Gotchas

- Prefer work email (`email-finder`) before personal email. Personal email is a lawful **B2B fallback** when work email is missing or undeliverable — not for consumer marketing or bypassing opt-outs.
- Placeholder domains like `example.com` may be rejected on some endpoints.
- Do not retry `null` aggressively — not found is free but rate limits still apply.
