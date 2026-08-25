---
name: bulk-jobs
description: "LeadMagic bulk enrichment jobs, CSV uploaders, and synchronous mini-batches. Use when enriching any list of 50+ rows, submitting POST /bulk/submit, uploading a CSV, polling job status, pausing or resuming a job, pulling error rows, configuring callbacks, or budgeting per-row credits for any product."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs/api-reference/bulk-jobs-submit
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, bulk, csv, uploader, batch, jobs]
---

# LeadMagic — Bulk jobs & uploaders

Async enrichment for lists. Bills **per successful row** at the same rate as the matching single-request product; failed rows are free. **Any list ≥ 50 rows belongs here — never a loop of single calls.**

## Workflow

1. Preflight: `GET /v1/credits` + `POST /v1/batch/preview-cost` (both free).
2. Validate mapping (free): `POST /bulk/validate`.
3. Submit: `POST /bulk/submit`.
4. Poll `GET /bulk/jobs/{jobId}` **≥45s apart**, or set a `callback` webhook, or stream `GET /bulk/jobs/{jobId}/stream`.
5. Fetch: `GET /bulk/jobs/{jobId}/download` (file) or `/results` / `/rows` (paged). Failed rows: `/errors` (free) — fix and resubmit only the misses.

## Submit shapes

| Variant | Body | When |
|---------|------|------|
| `POST /bulk/submit` | `rows` \| `csv` \| `fileUrl` | Auto-detect (recommended) |
| `POST /bulk/json` | `rows` | JSON array |
| `POST /bulk/csv` | `csv` | Inline CSV string |
| `POST /bulk/url` | `fileUrl` | Remote CSV/JSON/JSONL |
| `POST /bulk/file` | multipart | After `POST /bulk/upload-session` |

```bash
curl -sS -X POST "https://api.leadmagic.io/bulk/submit" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"product":"email_finder","rows":[{"first_name":"Jane","last_name":"Doe","domain":"acme.com"}]}'
```

## Product keys

`email_finder` · `email_validation` · `personal_email_finder` · `mobile_finder` · `b2b_profile_to_email` · `email_to_b2b_profile` · `profile_search` · `role_finder` · `company_finder` · `company_funding` · `job_change_detector` — same per-row cost and input columns as the single-request product (column aliases normalize the same way).

## Lifecycle & ops

- `GET /bulk/jobs?status=&product=&limit=&offset=` — list jobs.
- `POST /bulk/jobs/{jobId}/pause` · `/resume` · `/cancel` · `/restart`.
- Diagnostics: `GET /bulk/jobs/{jobId}/events`, `/logs`, `/metrics`.
- **Out of credits mid-job:** the job pauses rather than failing — top up, then `/resume`. Report rows done vs remaining.

## Rules

- Always preview cost and state projected spend before submitting; get user confirmation for large jobs.
- Poll ≥45s; prefer `callback` for jobs over a few thousand rows.
- Match rate matters: since misses are free, a conservative budget = rows × cost × expected match rate; a hard ceiling = rows × cost.
- Synchronous mini-batch for small arrays (no job overhead): `POST /v1/{product}/batch` or `POST /v1/batch` (mixed products). Suppression lists: `/v1/batch/suppression-lists`.
- MCP: `submit_bulk_job`, `submit_detected_bulk_job`, `process_attached_csv` (chat CSV uploads), `get_bulk_job_status`, `get_bulk_job_rows`, `get_bulk_job_errors`, `list_bulk_jobs`.
