---
description: Build an ICP prospect list with People Search v3 (sized free first)
argument-hint: [ICP description, e.g. "VP Sales at 51-200 US software companies"]
---

Build a prospect list for: $ARGUMENTS

Follow `outbound-recipes` recipe 1:
1. Translate the ICP into `company_filters` + `people_filters` (see `people-search` skill for filter names; `contact_job_function` is exact-match after short-name expansion).
2. Size it FREE first via search stats; report the match count and projected credit cost (1/row; free on Professional/Ultimate Search API).
3. On confirmation, page through `POST /v3/people/search` (`per_page` 25, cursor pagination), dedupe on `person_uid`, and write a CSV.
4. Offer next steps: waterfall enrichment (/leadmagic:waterfall-email) or bulk enrich (/leadmagic:enrich-csv).
