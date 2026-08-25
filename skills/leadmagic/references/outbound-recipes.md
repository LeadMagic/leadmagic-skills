# LeadMagic — Outbound system recipes

Composable, credit-aware recipes for building outbound systems with the REST API or hosted MCP. Every recipe starts with a free preflight (`GET /v1/credits`) and states its cost model. `$LM` = `-H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json"`.

## 1 · ICP list build (search → reveal → export)

**Goal:** a clean CSV of people matching an ICP. **Cost:** 1 credit/row revealed (free on Professional/Ultimate Search API).

1. Size it free: `POST /v3/search/stats` with your filters → match count.
2. Reveal pages: `POST /v3/people/search` with `company_filters` + `people_filters`, `per_page: 25`, walk `page` from 1.
3. Dedupe on `person_uid` / profile URL; write CSV.
4. Feed the CSV to recipe 3 (waterfall) or 4 (bulk enrich).

```bash
curl -sS -X POST "https://api.leadmagic.io/v3/people/search" $LM -d '{
  "company_filters": {"company_industry": ["Computer Software"], "company_sizes": ["51-200"]},
  "people_filters":  {"contact_job_function": ["Sales"], "contact_job_level": ["Director","VP"]},
  "page": 1, "per_page": 25
}'
```

## 2 · Account brief (one company, full context)

**Goal:** everything a rep needs before touching an account. **Cost:** ~8–12 credits/account.

`company-search` (1) → `company-funding` (4) → `technographics` (1) → `GET /v1/jobs/companies/{domain}/hiring-signals` (1) → `company posts-search` (1) → optional `competitors-search` (5). MCP shortcut: `account_intel` does the composite in one call.

## 3 · Waterfall contact enrichment (cheapest-first)

**Goal:** one reachable channel per contact, minimum spend. **Cost:** 0.25–5 typical.

1. Have an email? `email-validation` (0.25). Valid → done.
2. Have name+company? `email-finder` (1; free on miss).
3. Have profile URL only? `b2b-profile-email` (5; free on miss).
4. Still nothing and personal email is acceptable for your use case? `personal-email-finder` (2).
5. Phone channel needed? `mobile-finder` (5; free on miss) — last, it's the priciest common step.

Never run steps after the one that satisfied the channel you need. And never loop a finder result back into step 1 — every email a finder returns is already validated; validation is only for emails that arrived from outside LeadMagic.

## 4 · Bulk CSV enrichment (lists ≥ 50 rows)

**Goal:** enrich a list asynchronously, billed only on success.

1. `GET /v1/credits` + `POST /v1/batch/preview-cost` → confirm budget.
2. `POST /bulk/validate` (free) → check column mapping.
3. `POST /bulk/submit` with `{product, rows|csv|fileUrl, callback?}`.
4. Poll `GET /bulk/jobs/{jobId}` ≥45s apart (or take the `callback` webhook / `GET .../stream`).
5. `GET /bulk/jobs/{jobId}/download` → results; `/errors` → failed rows (free) for a retry pass.

Out of credits mid-job? The job can `pause`; top up, then `POST /bulk/jobs/{jobId}/resume`.

## 5 · List hygiene before every send

**Goal:** protect deliverability. **Cost:** 0.25/row (conclusive only).

Bulk `email_validation` over the send list → segment `valid` / `catch_all` / `unknown` / `invalid`. Send only valid (+ catch-all if you accept the risk); route invalids back through recipe 3. Cheap insurance: 1,000 rows = 250 credits max.

## 6 · Hiring-intent trigger sweep

**Goal:** rank target accounts by buying signal this week. **Cost:** 1/domain.

`POST /v1/jobs/bulk/hiring-signals` with `{domains:[≤100]}` → score by openings, velocity, function mix. For a specific thesis, use an intent lens per domain: `POST /v1/jobs/company-intent/{gtm|sales|marketing|revops|ai-adoption|security|expansion|...}`. Feed hot accounts to recipe 2 → recipe 7 → outreach with the job post as the opener.

## 7 · Decision-maker mapping

**Goal:** the 2–4 real buyers at an account. **Cost:** 2–6/account.

Fast path: `role-finder` (2) per target title. Wide path: `POST /v3/people/employees` or `employee-finder` (1) filtered by `contact_job_level: ["Director","VP","C-Team"]`, then pick. MCP shortcut: `find_decision_makers`. Then recipe 3 for channels.

## 8 · Job-change (champion tracking) loop

**Goal:** catch past champions landing in new buying seats. **Cost:** 3/contact checked.

Monthly over your CRM's champions list: `POST /v1/people/job-change-detector` `{profile_url, expected company}` → on change: `profile-search` (1) confirms new role → `email-finder` (1) at new domain → "congrats" sequence. Highest-converting trigger in outbound; budget = 3 × list size per sweep.

## 9 · Competitor ads monitor

**Goal:** know competitors' messaging and who they target. **Cost:** 1/search + 2/detail.

Weekly per competitor domain: `google-ads-search`, `meta-ads-search`, `b2b-ads-search` (1 each, pass `limit` to cap spend) → diff against last week → `b2b-ads-details` (2) only for new creatives worth dissecting.

## 10 · Lookalike expansion

**Goal:** turn best customers into net-new TAM. **Cost:** 5/seed + 1/row on expansion.

For each top customer domain: `POST /v3/companies/lookalike` (5) → merge & dedupe → optional filter pass through `/v3/companies/search` → recipe 6 to rank by intent → recipe 7 → recipe 3.

## 11 · TAM map

**Goal:** count and segment an entire market before spending on reveals.

Free sizing first: v3 stats/count surfaces with `company_filters` permutations (industry × size × geo). Then reveal only the segments you'll actually work (`/v3/companies/search`, 1/row). On Professional/Ultimate the whole sweep is credit-free — fan out within 5/10 RPS.

## 12 · Inbound speed-to-lead enrich

**Goal:** route + personalize inbound in seconds. **Cost:** ~2–4/lead.

On form submit: `email-validation` (0.25) → `b2b-profile` from email (10) *or* cheaper: extract domain → `company-search` (1) + `role-finder` (2) if you only need firmo + persona. Route by size/industry; personalize from profile + recent `posts-search` (1).

## 13 · Signal-stacked cold sequence (the full system)

Weekly pipeline that composes the above: **6** (intent sweep over TAM from **10/11**) → top decile → **2** (briefs) → **7** (buyers) → **3** (channels) → **5** (hygiene) → sequencer, with **8** running monthly and **9** feeding messaging angles. Track spend with free `GET /v1/analytics/usage` and found-rates with `/v1/analytics/found-rate`.

## Ops rules for every recipe

- Preflight credits; preview cost for anything ≥ 500 credits; report projected spend to the user before running.
- Respect 429 `Retry-After`; poll bulk jobs ≥45s apart; never tight-loop a 402.
- Not-found results on finders are free — but do not re-submit the same miss expecting a different answer.
- Log per-run: rows attempted, found, credits spent (from `/v1/analytics/day/{date}`).
