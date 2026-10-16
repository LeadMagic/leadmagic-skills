---
description: Map the real buyers at a target account
argument-hint: [company domain] [optional: roles you sell to]
---

Find decision makers at: $ARGUMENTS

Follow `outbound-recipes` recipe 7 (2–6 credits/account). Use Role Finder first for every known target title: MCP `find_decision_makers` (titles plus emails; it runs Role Finder per title) or `find_people_by_role`, otherwise `role-finder` (2 each, free on a miss). Only for titles it misses, or exploratory mapping → `POST /v3/people/employees` filtered by `contact_job_level: ["Director","VP","C-Team"]` and the relevant `contact_job_function`.

Return 2–4 named buyers with title and profile, flag the likely economic buyer vs champion, and offer /leadmagic:waterfall-email to get their channels.
