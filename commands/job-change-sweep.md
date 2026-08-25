---
description: Detect champions who changed jobs (highest-converting trigger)
argument-hint: [path to CSV of contacts with profile URLs or emails]
---

Run a job-change sweep over: $ARGUMENTS

Follow `outbound-recipes` recipe 8 (3 credits/contact — state total cost and confirm):
1. For each contact: `job-change-detector` with profile URL or work email + expected company. Results are yes / no / inconclusive — treat inconclusive as "recheck next sweep".
2. For confirmed changes: `profile-search` (1) to confirm the new role, then `email-finder` (1) at the new domain.
3. Output: a "movers" file with old company → new company + new role + fresh email, ready for a congrats sequence. Report credits spent and suggest scheduling this monthly.
