---
description: Expand TAM from your best customers via company lookalikes
argument-hint: [seed customer domains]
---

Find lookalikes for: $ARGUMENTS

Follow `outbound-recipes` recipe 10 (5/seed + 1/row on reveals — state cost, confirm):
1. `POST /v3/companies/lookalike` per seed domain; merge and dedupe results.
2. Optional filter pass (`/v3/companies/search` company_filters) to enforce size/geo/industry fit.
3. Recommend ranking the expansion set with /leadmagic:hiring-signals before spending on people. Output a companies CSV with the seed each match came from.
