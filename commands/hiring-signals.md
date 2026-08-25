---
description: Rank target accounts by hiring intent (bulk domain sweep)
argument-hint: [domains, or path to a CSV of domains] [optional: intent lens, e.g. security]
---

Run a hiring-intent sweep over: $ARGUMENTS

Follow `outbound-recipes` recipe 6 and the `jobs-hiring-intent` skill (1 credit/domain — state cost, confirm if > 100 domains):
1. `POST /v1/jobs/bulk/hiring-signals` in batches of ≤100 domains (or the named intent lens per domain: gtm/sales/marketing/revops at 1, ai-adoption/security/expansion/etc. at 2).
2. Score and rank: openings, hiring velocity, function mix relevant to what the user sells.
3. Return a ranked table with the evidence (which roles, how recent) and recommend the top accounts for /leadmagic:account-brief → /leadmagic:decision-makers, citing the job posts as openers.
