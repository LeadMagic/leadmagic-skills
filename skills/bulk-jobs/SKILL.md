---
name: bulk-jobs
description: "LeadMagic bulk enrichment jobs and CSV uploaders. Use for POST /bulk/submit, JSON/CSV/fileUrl/scrape inputs, upload sessions, polling job status, callbacks, and budgeting per-row credits."
argument-hint: "[submit bulk job / poll status / CSV upload]"
license: MIT
version: 1.0.0
tags: [leadmagic, bulk, csv, uploader, enrichment]
github: "https://github.com/LeadMagic/leadmagic-skills"
homepage: "https://leadmagic.io"
docs: "https://leadmagic.io/docs/api-reference/bulk-jobs-submit"
publisher: "LeadMagic"
verified: true
---

# LeadMagic — Bulk jobs & uploaders

Async enrichment for lists. Bill **per successful row** at the same rate as the matching single-request product. Failed rows are free.

Docs: [Submit bulk job](https://leadmagic.io/docs/api-reference/bulk-jobs-submit)

## Workflow

1. Preflight: `GET /v1/credits`
2. Optional validate: docs bulk validate endpoint for field mapping
3. Submit: `POST /bulk/submit` (or typed `/bulk/json`, `/bulk/csv`, `/bulk/url`, `/bulk/scrape`, `/bulk/file`)
4. Poll: `GET /bulk/jobs/{jobId}` (and list jobs as needed)
5. Pull results / honor `callback` webhooks

## Submit shapes

| Variant | Body | When |
|---------|------|------|
| `POST /bulk/submit` | `rows` \| `csv` \| `fileUrl` \| `scrape` | Auto-detect (recommended) |
| `POST /bulk/json` | `rows` | JSON array |
| `POST /bulk/csv` | `csv` | Inline CSV string |
| `POST /bulk/url` | `fileUrl` | Remote CSV/JSON/JSONL |
| `POST /bulk/scrape` | `scrape` | Browser crawl config |
| `POST /bulk/file` | multipart | After upload-session |

## Product keys

`product` uses underscores, e.g.:

- `email_finder`, `email_validation`
- `mobile_finder`, `profile_search`
- `company_search`

```bash
curl -sS -X POST "https://api.leadmagic.io/bulk/submit" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "product": "email_finder",
    "rows": [
      {"first_name":"Jane","last_name":"Doe","company_name":"acme.com"}
    ]
  }'
```

Use `inputMapping` when CSV columns do not match expected field names.

## Agent rules

- Never put live API keys or customer CSV contents into skill files / learnings.
- Prefer chunking very large runs; check plan row limits (docs cite up to 500k/job).
- Do not busy-poll every second — use reasonable intervals or callbacks.
- Sync single-row debugging → use the matching people/company skill instead of bulk.
