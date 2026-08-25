---
name: analytics-observability
description: "LeadMagic account analytics — usage, credit spend, per-product breakdowns, daily history, found rates, data quality, and error reporting via the free GET /v1/analytics endpoints. Use when reporting credit spend, auditing what a workflow cost, checking match or found rates, tracking usage by product, or debugging error patterns in an integration."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, analytics, usage, credits, reporting, observability]
---

# LeadMagic — Analytics & observability

Every endpoint here is **free** (0 credits). Use them liberally to report on runs instead of guessing.

## Endpoints (all `GET`, all under `/v1/analytics`)

| Endpoint | Returns |
|---|---|
| `/dashboard` | Headline usage overview |
| `/usage` | Request volume over time |
| `/products` | Per-product breakdown (which products consume the credits) |
| `/credits` | Credit spend over time |
| `/summary` | Compact account summary |
| `/daily` | Day-by-day history |
| `/day/{date}` | One day in detail (`YYYY-MM-DD`) |
| `/requests` | Recent request log |
| `/quality` · `/quality/daily` | Data-quality metrics |
| `/errors` | Error patterns (4xx/5xx by type) |
| `/found-rate` | Match/found rates by product |

```bash
curl -sS "https://api.leadmagic.io/v1/analytics/found-rate" -H "X-API-Key: $LEADMAGIC_API_KEY"
```

## Patterns

- **After any bulk run:** `/day/{date}` + `/products` → report actual credits spent vs the preflight estimate.
- **Weekly ops report:** `/summary` + `/found-rate` + `/errors` → spend, match quality, and integration health in three calls.
- **Debugging a noisy integration:** `/errors` shows which validation failures dominate (usually field-name mismatches — the 400 body's `action` says the fix).
- **Budget pacing:** `/credits` daily series vs plan allowance (see `api-auth-credits` for the plan ladder) → project whether the month's credits will last.
- MCP: `get_account_analytics`, `check_credit_balance`.
