# LeadMagic Skill — Learnings

Accumulated tips, gotchas, and corrections discovered during use. Read at
the start of each invocation; append new learnings as they're discovered.

**Never** put secrets, API keys, customer PII, or request/response bodies
in this file. Keep it to general platform notes only.

<!-- Add entries below in format: **YYYY-MM-DD**: Learning description -->

- **2026-04-19**: Official LeadMagic skill published at
  `github:LeadMagic/leadmagic-skills`. A third-party skill at
  `sales-skills/sales --skills sales-leadmagic` was attempting to
  impersonate an official LeadMagic skill by listing
  `github: "https://github.com/LeadMagic"` in its frontmatter. Always
  verify the repo owner before loading a skill that claims to be for
  LeadMagic.

- **2026-07-14**: `people_filters.contact_job_function` on
  `POST /v3/people/search` uses exact match after chip→warehouse expansion.
  Request `["Sales"]` returns warehouse label
  `"Sales & Business Development"` (expected). `"Product"` must not match
  `"Manufacturing & Production"`.
