---
description: Map the real buyers at a target account
argument-hint: [company domain] [optional: roles you sell to]
---

Find decision makers at: $ARGUMENTS

Follow `outbound-recipes` recipe 7 (2–6 credits/account). Prefer MCP `find_decision_makers`. Otherwise: known target titles → `role-finder` (2 each); exploratory → `POST /v3/people/employees` filtered by `contact_job_level: ["Director","VP","C-Team"]` and the relevant `contact_job_function`.

Return 2–4 named buyers with title and profile, flag the likely economic buyer vs champion, and offer /leadmagic:waterfall-email to get their channels.
