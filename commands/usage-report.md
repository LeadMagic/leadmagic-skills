---
description: Credit spend + found-rate report from the free analytics endpoints
argument-hint: [optional: period, e.g. "this week"]
---

Build a LeadMagic usage report for: $ARGUMENTS (default: last 7 days).

Use the `analytics-observability` skill — every call is free: `/v1/analytics/summary`, `/credits`, `/products`, `/errors` (+ `/day/{date}` for specific days). Report: credits spent (by product), request volume, found/match rates only where returned by the documented response, notable error patterns with the fix from the error body's `action`, and pace vs the plan's monthly credit allowance (ladder in `api-auth-credits`).
