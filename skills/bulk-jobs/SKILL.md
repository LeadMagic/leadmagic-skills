---
name: bulk-jobs
description: "LeadMagic bulk enrichment jobs, CSV uploaders, and synchronous mini-batches. Use when enriching any list of 50+ rows, submitting POST /bulk/submit, uploading a CSV, polling job status, pausing or resuming a job, pulling error rows, configuring callbacks, or budgeting per-row credits for any product."
license: MIT
compatibility: "Requires network access to api.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.1"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs/api-reference/bulk-jobs-submit?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, bulk, csv, uploader, batch, jobs]
---

# LeadMagic — Bulk jobs & uploaders

Async enrichment for lists. Bills **per successful row** at the same rate as the matching single-request product; failed rows are free. **Any list ≥ 50 rows belongs here — never a loop of single calls.**

## Workflow

1. Preflight: `GET /v1/credits` + `POST /v1/batch/preview-cost` (both free).
2. Validate mapping (free): `POST /bulk/validate`.
3. Save the exact ordered submitted rows and their original record IDs, then submit: `POST /bulk/submit`. Bind the saved manifest to the returned job ID.
4. Poll `GET /bulk/jobs/{jobId}` **≥45s apart**, or set a `callback` webhook, or stream `GET /bulk/jobs/{jobId}/stream`.
5. Fetch: `GET /bulk/jobs/{jobId}/download` (file) or `/results` / `/rows` (paged). Failed rows: `/errors` (free) — fix and resubmit only the misses.
6. Validate identity for the entire merge before writing. Follow the join contract below.

## Result identity and safe joins

- For ordinary one-input/one-result enrichment, `row_index` is **zero-based within that job's submitted data**. CSV headers and blank records are excluded. It is not the original spreadsheet row number or a result's position on a page.
- Keep an immutable manifest: `{job_id, product, rows}` with rows in exact submission order. Keep original record IDs alongside it, especially after filtering, sorting, batching, or retries. Each new job starts its own indices.
- Fetch all required pages from the manifest's job ID. `/results` returns `{rows, limit, offset}`. Status filters leave gaps in source indices. Never zip the returned array onto a CSV or use `offset + array_position` as the source index.
- Verify **every** `lm_input` identity against `manifest.rows[result.row_index]` before applying output. For profiles, also compare the returned profile identity when present. A changed profile URL may be an alias; quarantine it for review rather than silently treating it as the same person.
- Stop the merge on any mismatch, missing identity, invalid index, or ambiguous duplicate. Report counts and job ID; preserve the input file. Never guess an offset or overwrite another person's fields.
- A single source row can appear more than once in multi-product jobs. Local Leads is a fan-out product with display indices. Neither supports the simple one-result-per-source join below.

For a **single-product `profile_search`** job, the bundled checker validates all supplied pages before creating a new JSON file. It rejects duplicate indices, wrong-job manifests, and mismatched profile identities. It does not modify the input or contact the API:

```bash
python3 scripts/check-profile-results.py --manifest manifest.json \
  --job-id "$JOB_ID_USED_TO_FETCH" --results page-0.json page-1.json \
  --output checked-results.json
```

Run from this skill's directory (or use its absolute script path). `--job-id` must be captured from the actual fetch URL, not copied from an unrelated manifest. Each page is the unchanged `/results` JSON response. The output contains `{source, result}` pairs, with the source taken from the saved submission, and reports whether all input rows are present. A partial result set must not be represented as a complete job. Use the retained original record IDs to merge into a master file only after validation.

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
