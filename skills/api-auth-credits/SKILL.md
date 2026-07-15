---
name: api-auth-credits
description: "LeadMagic API auth, keys, credits, and rate limits. Use when setting LEADMAGIC_API_KEY, calling GET /v1/credits, rotating keys, budgeting enrichment spend, or debugging 401/402/429 responses."
argument-hint: "[auth, credits, rate limits, or key rotation]"
license: MIT
version: 1.0.0
tags: [leadmagic, api, auth, credits, rate-limits]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs"
publisher: "LeadMagic"
verified: true
---

# LeadMagic — API auth & credits

## Rules

1. Never echo or log `LEADMAGIC_API_KEY`. Read from env only.
2. REST auth header is **`X-API-Key`**, not `Authorization: Bearer`.
3. Prefer hosted MCP (`https://mcp.leadmagic.io/mcp`) for agent workflows — OAuth, no key in shell history.
4. Always preflight bulk or large runs with `GET /v1/credits`.

## Base URL & key

- **Base:** `https://api.leadmagic.io`
- **Key:** [app.leadmagic.io](https://app.leadmagic.io) → Settings → API
- **Rotate** if a key was pasted into chat, committed, or shared.

```bash
curl -sS "https://api.leadmagic.io/v1/credits" \
  -H "X-API-Key: $LEADMAGIC_API_KEY"
```

## Common status codes

| Code | Meaning | What to do |
|------|---------|------------|
| 401 | Missing/invalid key | Check header name (`X-API-Key`) and env var |
| 402 / insufficient credits | Balance too low | Top up or shrink the run |
| 429 | Rate limited | Back off; do not hammer null retries |
| 4xx validation | Bad body | Fix fields; do not retry identical payload |

## Credit behavior

- **Failed / not-found lookups are free** on most people/company endpoints — do not retry aggressively on `null`.
- Bulk jobs bill **per successful row** at the same rate as the matching single-request product.
- Basic plan credits may not roll over; Essential+ typically do (confirm on current pricing page).

## Docs

- [API docs](https://leadmagic.io/docs)
- OpenAPI snapshot: [LeadMagic/leadmagic-openapi](https://github.com/LeadMagic/leadmagic-openapi)
