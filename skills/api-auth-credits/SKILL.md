---
name: api-auth-credits
description: "LeadMagic API authentication, API keys, credit balance, plans, and rate limits. Use when setting LEADMAGIC_API_KEY, calling GET /v1/credits, budgeting a run against a plan's credits, previewing bulk cost, or debugging 401, 402, 403, or 429 responses."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, api, auth, credits, plans, rate-limits, x-api-key]
---

# LeadMagic — API auth, credits & plans

## Rules

1. Never echo or log `LEADMAGIC_API_KEY`. Read from env only; rotate immediately if a key was pasted into chat or committed.
2. REST auth header is **`X-API-Key`**, not `Authorization: Bearer`.
3. Prefer hosted MCP (`https://mcp.leadmagic.io/mcp`) for agent workflows — OAuth, no key in shell history.
4. Preflight every run: `GET /v1/credits` (free). Preview anything ≥ 500 credits: `POST /v1/batch/preview-cost` (free).

## Base URL & key

- **Base:** `https://api.leadmagic.io`
- **Key:** [app.leadmagic.io](https://app.leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills) → Settings → API

```bash
curl -sS "https://api.leadmagic.io/v1/credits" -H "X-API-Key: $LEADMAGIC_API_KEY"
```

## Plans (what a run can afford)

Basic $49.99/mo · 2,000 credits (no rollover, 1 seat) → Essential $99 · 5,000 → Growth $249 · 20,000 → Professional $499 · 50,000 → Ultimate $849 · 100,000 (rollover on Essential+). Annual = 12× credits up front at ~2 months free. **Professional/Ultimate include credit-free Search API throughput (5/10 req/s)** — v3 searches cost 0 credits there and 1 credit/row elsewhere. Full ladder + budgeting: `leadmagic` skill → `references/plans-and-limits.md`.

## Status codes

| Code | Meaning | What to do |
|---|---|---|
| 400 | Validation | Error body names the field and the fix (`detail`, `action`) |
| 401 | Missing/invalid key | Check header name (`X-API-Key`) and env var; key may be revoked |
| 402 | Out of credits | Stop the run; report done/remaining; `GET /v1/credits`; resume after top-up. Never retry-loop |
| 403 | Plan/entitlement gate | Feature not on this plan — say which plan unlocks it |
| 429 | Rate limited | Honor `Retry-After`, exponential backoff + jitter. Sustained hammering escalates temporary blocks |
| 5xx | Transient | One retry with backoff, then surface with `trace.request_id` |

Errors are RFC 9457 Problem Details — `action` is the machine-suggested fix; `trace.request_id` is what support needs.

## Credit accounting facts

- Not-found results are **free** on the major finders (email, personal email, mobile, profile→email, company, funding).
- Email validation bills only conclusive outcomes (valid/invalid); unknown and unverifiable catch-all are free.
- Bulk jobs bill per **successful** row at single-request rates; failed rows free.
- Track spend with free `GET /v1/analytics/usage`, `/credits`, `/day/{date}` (see `analytics-observability`).
