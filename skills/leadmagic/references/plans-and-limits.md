# LeadMagic — Plans, credits & limits

Reviewed 2026-09-06. Verify [current credit costs](https://leadmagic.io/docs/v1/credits) before paid work. Employee Finder bills per returned employee (0.05 credits). Google/Meta ad searches bill per returned ad; B2B ad search includes a base charge.

Public pricing: [leadmagic.io/pricing](https://leadmagic.io/pricing?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills). Agents should read this before sizing any run so recommendations match what the customer's plan can actually do.

## Plan ladder

Current monthly and annual prices, included credits, and rollover terms are published on [leadmagic.io/pricing](https://leadmagic.io/pricing?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills) — read them there rather than from a copy.

| Plan | Search API |
|---|---|
| **Basic** | Metered (credits per search) |
| **Essential** | Metered; in-app Search included |
| **Growth** | Metered; in-app Search included |
| **Professional** | **Credit-free browse search at 5 req/s, fair-use cap** |
| **Ultimate** | **Credit-free browse search at 10 req/s, fair-use cap** |

Enterprise / custom plans exist — credits, rate, and Search API throughput are set per agreement; check `GET /v1/credits` and ask your account contact rather than assuming a tier.

## What "Search API" means

The v3 discovery surfaces — `POST /v3/people/search` (+variants), `POST /v3/companies/search` / `lookalike`, `POST /v3/jobs/search` — behave differently by plan:

- **Professional & Ultimate:** browse search requests do not consume credits, up to 5 / 10 requests per second, within a fair-use cap shared across People, Company and Jobs search ([leadmagic.io/unlimited](https://leadmagic.io/unlimited?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills)). Lookalikes and exports stay metered. Ideal for TAM mapping, list building at scale, and continuous monitoring.
- **All other plans:** every search bills the catalog cost (1 credit per returned row). Nobody is hard-blocked — searches just cost credits.
- Free on every plan: count/preview/stats helpers (`/v3/search/stats`, `/v3/jobs/search/stats`, catalogs, facets).

**Agent guidance:** on Basic–Growth, prefer narrow filters + small `per_page` and use free stats endpoints to size a query before revealing rows. On Professional/Ultimate, fan out within the RPS and fair-use caps.

## Enrichment credit costs (identical on every plan)

| Product | Credits | Not-found |
|---|---|---|
| Email Validation | 0.25 | Unknown/catch-all-unverifiable free |
| Email Finder | 1 | Free |
| Profile Search | 1 | — |
| Personal Email Finder | 2 | Free |
| Role Finder | 2 | — |
| Job Change Detector | 3 | Free when the profile URL does not resolve (`status: PROFILE_NOT_FOUND`) |
| Company Funding | 4 | Free |
| Mobile Finder | 5 | Free |
| B2B Profile → Email | 5 | Free |
| Company Lookalike / Competitors | 5 | — |
| Email → B2B Profile | 10 | — |
| Company Search / Technographics / Posts / Employee Finder / Jobs Finder / Ads Search | 1 | Company search free when not found |
| Hiring signals & intent lenses | 1–2 | — |
| B2B Ad Details | 2 | — |
| Credits, analytics, previews, catalogs, stats | 0 | — |

## Rate limits

Each product carries its own per-minute ceiling (per organization); representative defaults:

| Product family | Default RPM |
|---|---|
| Email finder / validation / personal email | 5,000 |
| Mobile finder | 25,000 |
| B2B profile ↔ email, ads, technographics, job change | 1,500 |
| Profile search, role finder, employee finder, company products, people search, jobs finder | 300 |
| Jobs search v3, intent lenses | 100–200 |
| Bulk intent, AI targeting | 50 |

Limits are identical across self-serve plans (Basic through Ultimate) — no tier carries a higher API or MCP lane; higher limits exist only on custom/enterprise agreements. The response headers and 429 `Retry-After` are authoritative. Sustained hammering after 429/402 triggers short escalating blocks (seconds to minutes); respect backoff and they never engage.

## Budgeting a run (do this before any large job)

1. `GET /v1/credits` → balance.
2. `POST /v1/batch/preview-cost` or multiply rows × per-product cost from the table.
3. Compare; if short, shrink the segment (filters, `per_page`, validation-first ordering) or ask the user to top up / upgrade.
4. For CSV jobs, submit via `/bulk/*` — bills only successful rows, so a low match rate costs proportionally less.

**Waterfall ordering that minimizes spend:** validate existing email (0.25) → find work email (1) → profile enrich (1) → personal email (2) → profile→email (5) → mobile (5) → email→profile (10). Stop at the first field that satisfies the outreach channel you actually need.

## 402 / 429 playbook

- **402** `credits_exhausted`: stop the run, report rows completed vs remaining, show balance from `/v1/credits`, and resume after top-up (bulk jobs can `pause`/`resume`).
- **429**: honor `Retry-After` exactly, then exponential backoff with jitter. Never tight-loop — on shared workflows (integration platforms and no-code automation tools) set the tool's native rate to below the product ceiling.
