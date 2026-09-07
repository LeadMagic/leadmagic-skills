# LeadMagic API — Public endpoint reference

Reviewed on 2026-09-06 against the [published public schema](https://leadmagic.io/docs/api-reference/openapi.yml). Only documented public operations are listed here; do not infer additional routes or aliases from backend code.

## Authentication and credits

REST: `https://api.leadmagic.io`, `X-API-Key` from `$LEADMAGIC_API_KEY`. Hosted MCP: `https://mcp.leadmagic.io/mcp` with OAuth. Terminal: lm-tui with `lm login`.

`GET /v1/credits` is free. Consult [current credits documentation](https://leadmagic.io/docs/v1/credits) for costs and [the agent guide](https://leadmagic.io/docs/mcp/agent-guide) for search entitlements and pagination. Professional and Ultimate include credit-free canonical people/company/jobs search; contact unlocks, enrichment, lookalikes, and exports remain metered. Never send app-only preview options.

Email Finder returns validated work emails; validate externally sourced addresses separately. Employee Finder costs 0.05 credits per employee returned. Google and Meta ad searches charge per returned ad; B2B ad search includes a base charge. Confirm cost before paid work.

## Reviewed operations

| Method | Public path | Purpose |
| --- | --- | --- |
| GET | `/v1/credits` | Check Credits |
| GET | `/v1/analytics/dashboard` | Dashboard Overview |
| GET | `/v1/analytics/usage` | Usage Summary |
| GET | `/v1/analytics/products` | Products Breakdown |
| GET | `/v1/analytics/credits` | Credit History |
| GET | `/v1/analytics/summary` | All-Time Summary |
| GET | `/v1/analytics/daily` | Daily Metrics |
| GET | `/v1/analytics/day/{date}` | Day Breakdown |
| POST | `/v1/people/email-validation` | Email Validation |
| POST | `/v1/people/email-finder` | Email Finder |
| POST | `/v1/people/personal-email-finder` | Personal Email Finder |
| POST | `/v1/people/b2b-profile-email` | B2B Person Profile to Email |
| POST | `/v1/people/profile-search` | B2B Person Profile |
| POST | `/v1/people/b2b-profile` | Email Address to B2B Person Profile |
| POST | `/v1/people/mobile-finder` | Mobile Finder |
| POST | `/v1/people/job-change-detector` | Job Change Detector |
| POST | `/v1/companies/company-search` | Company Search |
| POST | `/v1/companies/company-funding` | Company Funding |
| POST | `/v1/companies/competitors-search` | Competitors Search |
| POST | `/v1/companies/technographics` | Company Technographics |
| POST | `/v1/people/role-finder` | Role Finder |
| POST | `/v1/people/employee-finder` | Employee Finder |
| POST | `/v3/people/search` | People Search |
| POST | `/v3/companies/search` | Company Search |
| POST | `/v3/companies/lookalike` | Company Lookalike |
| POST | `/v1/jobs/jobs-finder` | Jobs Finder |
| POST | `/v3/jobs/search` | Job Search |
| POST | `/v3/search/stats` | Search Stats |
| POST | `/v3/jobs-search` | Job Search Alias |
| POST | `/v3/jobs/search/resolve` | Resolve Job Search filters |
| GET | `/v3/jobs/search/companies` | Job Search Companies Helper |
| GET | `/v3/jobs/search/tags` | Job Search Tags Helper |
| GET | `/v3/jobs/search/titles` | Job Search Titles Helper |
| GET | `/v3/jobs/search/occupation-taxonomy` | Job Search Occupation Taxonomy Helper |
| GET | `/v3/jobs/search/locations` | Job Search Locations Helper |
| GET | `/v3/jobs/search/catalogs` | Job Search Catalogs |
| GET | `/v3/jobs/search/roles` | Job Search Roles Helper |
| GET | `/v3/jobs/search/stats` | Job Search Dataset Stats |
| GET | `/v3/jobs/search/job-board/stats` | Job Board Stats |
| POST | `/v3/jobs/search/export` | Job Search Export |
| GET | `/v1/jobs/countries` | Job Country |
| GET | `/v1/jobs/regions` | Job Region |
| GET | `/v1/jobs/job-types` | Job Type |
| GET | `/v1/jobs/company-types` | Job Company Type |
| GET | `/v1/jobs/industries` | Job Industry |
| POST | `/v1/ads/google-ads-search` | Google Ads Search |
| POST | `/v1/ads/meta-ads-search` | Meta Ads Search |
| POST | `/v1/ads/b2b-ads-search` | B2B Search Ads |
| POST | `/v1/ads/b2b-ads-details` | B2B Ad Details |
| POST | `/bulk/submit` | Submit Bulk Job |
| GET | `/bulk/jobs` | List Bulk Jobs |
| GET | `/bulk/jobs/{jobId}` | Get Bulk Job Status |
| POST | `/bulk/jobs/{jobId}/review` | Review Bulk Job (Cancel or Approve) |
| GET | `/bulk/jobs/{jobId}/results` | Get Bulk Job Results |
| GET | `/bulk/jobs/{jobId}/download` | Download Bulk Job Results as CSV |
| GET | `/bulk/capabilities` | Get Bulk API Capabilities |
| POST | `/bulk/validate` | Validate a Bulk Submission |
| POST | `/bulk/local-leads` | Submit a Local Leads Search |
| GET | `/bulk/progress` | Get Lightweight Bulk Job Progress |
| GET | `/bulk/jobs/{jobId}/errors` | Get Failed Bulk Job Rows |
| GET | `/bulk/jobs/{jobId}/events` | Get Bulk Job Events |
| GET | `/bulk/jobs/{jobId}/stream` | Stream Bulk Job Progress |
| POST | `/bulk/jobs/{jobId}/pause` | Pause a Bulk Job |
| POST | `/bulk/jobs/{jobId}/resume` | Resume a Bulk Job |
| POST | `/bulk/jobs/{jobId}/restart` | Restart a Bulk Job |
| PATCH | `/bulk/jobs/{jobId}/priority` | Update Bulk Job Priority |
| GET | `/v1/batch` | List Batches |
| POST | `/v1/batch` | Submit a Mixed-Product Batch |
| GET | `/v1/batch/{batchId}` | Get Batch Status |
| PATCH | `/v1/{product}/batch/{batchId}` | Update Batch Metadata |
| GET | `/v1/batch/campaign/{campaignId}/metrics` | Get Campaign Metrics |
| GET | `/v1/batch/clients` | List Batch Clients |
| POST | `/v1/batch/clients` | Create a Batch Client |
| GET | `/v1/batch/clients/{clientId}/metrics` | Get Batch Client Metrics |
| GET | `/v1/batch/clients/{clientId}/webhooks` | List Batch Client Webhooks |
| POST | `/v1/batch/clients/{clientId}/webhooks` | Create a Batch Client Webhook |
| GET | `/v1/batch/providers` | List External Batch Providers |
| POST | `/v1/batch/providers` | Create an External Batch Provider |
| POST | `/v1/batch/preview-cost` | Preview Batch Cost |
| POST | `/v1/batch/budgets` | Create Credit Budget |
| GET | `/v1/batch/budgets` | List Credit Budgets |
| GET | `/v1/batch/budgets/status` | Get Budget Status |
| PATCH | `/v1/batch/budgets/{id}` | Update Credit Budget |
| DELETE | `/v1/batch/budgets/{id}` | Delete Credit Budget |
| POST | `/v1/batch/suppression-lists` | Create Suppression List |
| GET | `/v1/batch/suppression-lists` | List Suppression Lists |
| GET | `/v1/batch/suppression-lists/{listId}` | Get Suppression List |
| DELETE | `/v1/batch/suppression-lists/{listId}` | Delete Suppression List |
| POST | `/v1/batch/suppression-lists/{listId}/emails` | Add Emails to Suppression List |
| DELETE | `/v1/batch/suppression-lists/{listId}/emails` | Remove Emails from Suppression List |

## Request discipline

Read the operation's schema before sending input. On cursor searches, keep filters identical between pages and never combine a cursor with a nonzero offset. Back off on 429 and honor Retry-After. A timed-out paid request can already have consumed credits; inspect its outcome before retrying. Log status and trace IDs, not keys or contact payloads.
