# LeadMagic API — Complete endpoint reference

Source of truth: [leadmagic.io/docs](https://leadmagic.io/docs). This table is generated from the live API contract.

## Auth

- Header: `X-API-Key: <key>` (never `Authorization: Bearer`)
- Base URL: `https://api.leadmagic.io`
- Key: [app.leadmagic.io](https://app.leadmagic.io) → Settings → API
- MCP (OAuth, no key needed): `https://mcp.leadmagic.io/mcp`
- Errors: RFC 9457 Problem Details — `{type, title, status, detail, code, action, docs, trace}`. Read `action` first; it says how to fix the request.

## Credits & account (free)

| Endpoint | Method | Cost |
|---|---|---|
| `/v1/credits` | GET / POST | 0 |
| `/v1/analytics/usage` · `/products` · `/credits` · `/summary` · `/daily` · `/day/{date}` · `/requests` · `/quality` · `/errors` · `/found-rate` | GET | 0 |
| `/v1/batch/preview-cost` | POST | 0 |

## Email

| Endpoint | Cost | Rate/min | Notes |
|---|---|---|---|
| `POST /v1/people/email-finder` | 1 | 5,000 | Free when not found. Needs person (name **or** profile URL) + company (`domain`/`company_name`). Aliases: `/v1/email-finder`, `/v2/email-finder`, `/v1/email/find` |
| `POST /v1/people/email-validation` | 0.25 | 5,000 | Bills only conclusive results (valid/invalid); unknown & catch-all-unverifiable are free. Aliases: `/v1/email-validation`, `/verify-email`, `/validate-email` |
| `POST /v1/people/personal-email-finder` | 2 | 5,000 | Free when not found. Body: `{profile_url}` (CRM synonym keys accepted) |
| `POST /v1/people/b2b-profile-email` | 5 | 1,500 | B2B profile URL → work email. Free when not found. Aliases: `/b2b-profile-to-email`, `/profile-to-email`, `/social-to-email` |
| `POST /v1/people/b2b-profile` | 10 | 1,500 | Email → full B2B profile. Accepts `work_email`, `personal_email`, or plain `email`. Aliases: `/email-to-b2b-profile`, `/reverse-email` |

**Cost-order rule:** if you already have a profile URL and only need profile fields, `profile-search` (1) beats `b2b-profile` (10). Find work email (1) before personal email (2) before mobile (5).

## People

| Endpoint | Cost | Rate/min | Notes |
|---|---|---|---|
| `POST /v1/people/profile-search` | 1 | 300 | Enrich from B2B profile URL (`profile_url`; synonym keys accepted). Aliases: `/enrich`, `/lookup`, `/person/search` |
| `POST /v1/people/mobile-finder` | 5 | 25,000 | Free when not found. Any of `profile_url`, `work_email`, `personal_email` |
| `POST /v1/people/role-finder` | 2 | 300 | `job_title` (required) + one of `company_domain`/`company_name`/B2B profile URL |
| `POST /v1/people/employee-finder` | 1 | 300 | List employees at a company. Also `/v1/companies/employees` |
| `POST /v1/people/job-change-detector` | 3 | 1,500 | Did this person change jobs? Aliases: `/job-change`, `/detect-job-change` |
| `POST /v1/people/posts-search` | 1 | 300 | A person's recent public posts |
| `POST /v1/people/comments-search` | 1 | 1,000 | Public comment activity |

## People Search v3 (audience discovery)

Canonical: **`POST /v3/people/search`**. Body: `{company_filters: {...}, people_filters: {...}, page, per_page}`.
Variants (same body shape): `/v3/people/full-search`, `/mixed-search`, `/icp-search`, `/employees`, `/by-title`, `/contacts-by-title`, `/lookalike`.

- Billing: 1 credit per returned result row; count/preview surfaces are free.
- `people_filters`: `contact_job_title`, `contact_job_function`, `contact_job_level`, `contact_country_code`, `contact_first_name` / `contact_last_name` / `contact_full_name`, `contact_email_domain`, …
- `company_filters`: `company_domain`, `company_name`, `company_industry`, `company_size`/`company_sizes`, `company_country`/`company_countries`, …
- `contact_job_function` matches canonical labels after short-name expansion (`"Sales"` → `"Sales & Business Development"`).
- Plan note: Professional (5 req/s) and Ultimate (10 req/s) include credit-free Search API throughput; other plans bill catalog cost per search. See `plans-and-limits.md`.

## Companies

| Endpoint | Cost | Rate/min | Notes |
|---|---|---|---|
| `POST /v1/companies/company-search` | 1 | 300 | Enrich by `company_domain`, `company_name`, or `profile_url`. Free when not found |
| `POST /v3/companies/search` | 1/row | 300 | Filter search (typed filters). Aliases: `/v1/companies/search`, `/v3/companies/enrich` |
| `POST /v3/companies/lookalike` | 5 | 300 | Lookalikes from seed domain or description. Alias: `/v3/companies/competitors` |
| `POST /v1/companies/company-funding` | 4 | 300 | Funding rounds. Free when not found. Alias: `/v1/funding` |
| `POST /v1/companies/technographics` | 1 | 1,500 | Tech stack. Aliases: `/company-tech`, `/technology`, `/v1/technographics` |
| `POST /v1/companies/competitors-search` | 5 | 300 | Competitor list |
| `POST /v1/companies/posts-search` | 1 | 300 | Company's recent public posts |

## Jobs & hiring intent

Job search: **`POST /v3/jobs/search`** (1/row; 100/min) — filters + free helper GETs under `/v3/jobs/search/*`: `companies`, `tags`, `titles`, `roles`, `occupation-taxonomy`, `locations`, `catalogs`, `stats`, `job-board/stats` (all cost 0).
Bulk export: `POST /v3/jobs/search/export` — same filters, `limit` 1–5000, 1 credit per returned job on every plan, no cursor.
Legacy single search: `POST /v1/jobs` (Jobs Finder, 1 credit; catalogs: GET `/v1/jobs/countries`, `/regions`, `/industries`, `/company-types`, `/job-types` — free).

Company hiring signals (1 credit each, 200/min):

| Endpoint | Purpose |
|---|---|
| `GET /v1/jobs/companies/{domain}/hiring-signals` (or POST `/v1/jobs/companies/hiring-signals`) | Composite hiring-intent snapshot |
| `GET /v1/jobs/companies/{domain}/recent-jobs` | Recent openings |
| `GET /v1/jobs/companies/{domain}/tool-mentions` | Tools named in job posts (tech-stack intent) |
| `GET /v1/jobs/companies/{domain}/function-mix` | Hiring by function |
| `GET /v1/jobs/companies/{domain}/hiring-velocity` | Hiring rate over time |

Intent lenses — `POST /v1/jobs/company-intent/{intent}` where `{intent}` ∈ `gtm`, `sales`, `marketing`, `revops` (1 credit) or `ai-adoption`, `security`, `cloud-modernization`, `data-modernization`, `expansion`, `contraction` (2 credits). Plus dedicated: `/tool-stack` (2), `/lookalikes` (2), `/job-embedding-similarity` (2), `/target-title-similarity` (2). Body: `{company_domain}` or `{domains:[...]}` variants; `POST /v1/jobs/companies/expansion-signals`, `/salary-bands` (2), `/hiring-benchmark` (2).

Bulk intent (1 credit per domain, 50/min): `POST /v1/jobs/bulk/company-intent`, `/bulk/hiring-signals`, `/bulk/tool-mentions` — body `{domains: [up to 100]}`.

Free jobs metadata: `GET /v1/jobs/meta/freshness`, `GET /v1/jobs/tags`, `POST /v1/jobs/tags/facets`.

## Ads intelligence

| Endpoint | Cost | Rate/min |
|---|---|---|
| `POST /v1/ads/google-ads-search` | 1 | 1,500 |
| `POST /v1/ads/meta-ads-search` | 1 | 1,500 |
| `POST /v1/ads/b2b-ads-search` | 1 | 1,500 |
| `POST /v1/ads/b2b-ads-details` | 2 | 1,500 |

Pass `limit` to cap returned creatives (and spend). Legacy aliases `/google/searchads`, `/meta/searchads`, `/b2b/searchads`, `/b2b/ad-details` still resolve.

## Bulk & batch

Async bulk (CSV/lists) — under `/bulk/*`, billed per successful row at the single-request rate:

| Endpoint | Purpose |
|---|---|
| `POST /bulk/submit` | Auto-detect body: `rows` \| `csv` \| `fileUrl` (recommended) |
| `POST /bulk/json` · `/bulk/csv` · `/bulk/url` · `/bulk/file` | Typed variants (`/file` is multipart after `POST /bulk/upload-session`) |
| `POST /bulk/validate` | Free field-mapping / dry-run check |
| `GET /bulk/jobs` | List jobs (`status`, `product`, `limit`, `offset`) |
| `GET /bulk/jobs/{jobId}` | Status; poll ≥45s apart |
| `GET /bulk/jobs/{jobId}/results` · `/rows` · `/download` · `/errors` · `/events` · `/logs` · `/stream` | Results & diagnostics |
| `POST /bulk/jobs/{jobId}/pause` · `/resume` · `/cancel` · `/restart` | Lifecycle |

`product` keys = product ids: `email_finder`, `email_validation`, `mobile_finder`, `personal_email_finder`, `b2b_profile_to_email`, `email_to_b2b_profile`, `profile_search`, `role_finder`, `company_finder`, `company_funding`, `job_change_detector`, …

Synchronous mini-batch: `POST /v1/{product}/batch` and `POST /v1/batch` (mixed) for small arrays without job overhead. Suppression lists: `/v1/batch/suppression-lists`.

## Legacy (v0) paths

Unversioned paths from early docs (`POST /email-finder`, `/email-validate`, `/mobile-finder`, `/b2b-profile`, `/company-search`, `/jobs-finder`, `/google/searchads`, …) still work but new integrations should use versioned paths above.

## Status codes

| Code | Meaning | Do |
|---|---|---|
| 400 | Validation failed | Read `detail` + `action` — field names & fixes are spelled out |
| 401 | Bad/missing key | Header is `X-API-Key`; check env var |
| 402 | Out of credits | `GET /v1/credits`; top up or upgrade — do **not** retry-loop |
| 403 | Not entitled | Plan/add-on gate — see `plans-and-limits.md` |
| 404 | Not found (some products return 200 + null instead) | Not-found lookups are free on most finders; don't hammer retries |
| 429 | Rate limited | Honor `Retry-After`; back off exponentially. Sustained hammering escalates temporary blocks |
| 5xx | Transient | Retry once with backoff, then surface |
